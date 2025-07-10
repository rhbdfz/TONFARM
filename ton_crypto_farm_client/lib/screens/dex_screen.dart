import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/exchange_rate.dart';
import '../models/resource_balance.dart';
import '../services/game_api.dart';
import '../services/ton_connect_service.dart';

class DexScreen extends ConsumerStatefulWidget {
  const DexScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DexScreen> createState() => _DexScreenState();
}

class _DexScreenState extends ConsumerState<DexScreen> {
  String _from = 'food', _to = 'wood';
  double _amount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DEX'), backgroundColor: const Color(0xFF40A6FF)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDropdowns(),
            TextField(
              decoration: const InputDecoration(labelText: 'Сумма'),
              keyboardType: TextInputType.number,
              onChanged: (v) => _amount = double.tryParse(v) ?? 0,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _amount <= 0 ? null : () => _swap(context),
              child: const Text('Обменять'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdowns() {
    return Row(
      children: [
        Expanded(child: _buildDropdown(_from, (v) => setState(() => _from = v))),
        const SizedBox(width: 16),
        Expanded(child: _buildDropdown(_to, (v) => setState(() => _to = v))),
      ],
    );
  }

  Widget _buildDropdown(String val, ValueChanged<String> onChanged) {
    return DropdownButtonFormField<String>(
      value: val,
      items: const [
        DropdownMenuItem(value: 'food', child: Text('Еда')),
        DropdownMenuItem(value: 'wood', child: Text('Дерево')),
        DropdownMenuItem(value: 'gold', child: Text('Золото')),
      ],
      onChanged: onChanged,
      decoration: const InputDecoration(border: OutlineInputBorder()),
    );
  }

  Future<void> _swap(BuildContext context) async {
    final rate = await GameAPI().getExchangeRate(_from, _to);
    final output = rate.rate * _amount;
    final addr = TonConnectService().walletAddress!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Подтвердите обмен'),
        content: Text('Вы получите ${output.toStringAsFixed(2)} $_to\nКомиссия: ${rate.fee * 100}%'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final resp = await GameAPI().prepareSwap(
                fromToken: _from,
                toToken: _to,
                inputAmount: _amount,
                playerAddress: addr,
              );
              await TonConnectService().sendTransaction(resp.contractAddress, resp.message);
            },
            child: const Text('Обменять'),
          ),
        ],
      ),
    );
  }
}
