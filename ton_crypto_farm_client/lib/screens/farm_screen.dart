import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tool_nft.dart';
import '../models/land_nft.dart';
import '../services/game_api.dart';
import '../services/ton_connect_service.dart';
import '../utils/helpers.dart';
import '../widgets/tool_card.dart';
import '../widgets/land_card.dart';

/// Провайдер инструментов и земель
final farmDataProvider = FutureProvider<FarmData>((ref) async {
  final addr = TonConnectService().walletAddress!;
  final tools = await GameAPI().getPlayerTools(addr);
  final lands = await GameAPI().getPlayerLands(addr);
  return FarmData(tools: tools, lands: lands);
});

class FarmData {
  final List<ToolNFT> tools;
  final List<LandNFT> lands;
  FarmData({required this.tools, required this.lands});
}

/// Экран фарма ресурсов
class FarmScreen extends ConsumerStatefulWidget {
  const FarmScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FarmScreen> createState() => _FarmScreenState();
}

class _FarmScreenState extends ConsumerState<FarmScreen> {
  ToolNFT? _selectedTool;
  LandNFT? _selectedLand;

  @override
  Widget build(BuildContext context) {
    final farmAsync = ref.watch(farmDataProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Фарм'), backgroundColor: const Color(0xFF40A6FF)),
      body: farmAsync.when(
        data: (data) => _buildFarm(content: data),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _selectedTool == null
            ? null
            : () => _startHarvest(context),
        label: const Text('Собрать'),
        icon: const Icon(Icons.agriculture),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildFarm({required FarmData content}) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Выберите инструмент и землю'),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: content.tools.length,
            itemBuilder: (_, i) {
              final t = content.tools[i];
              return GestureDetector(
                onTap: () => setState(() => _selectedTool = t),
                child: Opacity(
                  opacity: _selectedTool == t ? 1 : 0.6,
                  child: ToolCard(tool: t),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: content.lands.length,
            itemBuilder: (_, i) {
              final l = content.lands[i];
              return GestureDetector(
                onTap: () => setState(() => _selectedLand = l),
                child: Opacity(
                  opacity: _selectedLand == l ? 1 : 0.6,
                  child: LandCard(land: l),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _startHarvest(BuildContext context) async {
    final addr = TonConnectService().walletAddress!;
    final estimate = await GameAPI().calculateHarvestEstimate(
      toolId: _selectedTool!.id,
      landId: _selectedLand?.id,
      playerAddress: addr,
    );
    // Показ анимации/диалога
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Подтвердите сбор'),
        content: Text(
          'Добыча: ${estimate.finalAmount} ${estimate.resourceType}\n'
              'Стоимость энергии: ${estimate.energyCost}',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final prep = await GameAPI().prepareFarmTransaction(
                toolId: _selectedTool!.id,
                landId: _selectedLand?.id,
                playerAddress: addr,
              );
              await TonConnectService().sendTransaction(prep.contractAddress, prep.message);
            },
            child: const Text('Начать'),
          ),
        ],
      ),
    );
  }
}
