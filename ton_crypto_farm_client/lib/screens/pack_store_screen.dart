import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pack_info.dart';
import '../models/pack_result.dart';
import '../services/game_api.dart';
import '../services/ton_connect_service.dart';
import '../widgets/pack_card.dart';

/// Провайдер информации о паках
final packInfoProvider = FutureProvider<List<PackInfo>>((ref) async {
  return await GameAPI().getPackInfo();
});

/// Экран магазина паков
class PackStoreScreen extends ConsumerWidget {
  const PackStoreScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(packInfoProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Паки'), backgroundColor: const Color(0xFF40A6FF)),
      body: async.when(
        data: (packs) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: packs.length,
          itemBuilder: (_, i) => PackCard(
            pack: packs[i],
            onBuy: () => _buyPack(context, packs[i]),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
      ),
    );
  }

  Future<void> _buyPack(BuildContext context, PackInfo pack) async {
    final addr = TonConnectService().walletAddress!;
    final resp = await GameAPI().purchasePack(
      packType: pack.type,
      playerId: '', // передать текущий playerId
      playerAddress: addr,
    );
    await TonConnectService().sendTransaction(resp.contractAddress, resp.message);

    // Получить результат и показать
    final result = await GameAPI().getPackResult(resp.packId);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Вы открыли пак'),
        content: Text(
          'Получено: ${result.result.level}-ур. ${result.result.nftType}',
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }
}
