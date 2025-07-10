import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/tool_nft.dart';
import '../models/land_nft.dart';
import '../models/game_state.dart';
import '../services/game_api.dart';
import '../widgets/tool_card.dart';
import '../widgets/land_card.dart';
import '../utils/helpers.dart';

/// Провайдер для инвентаря игрока
final inventoryProvider = FutureProvider<InventoryData>((ref) async {
  final api = GameAPI();
  final currentPlayer = ref.watch(currentPlayerProvider);

  final tools = await api.getPlayerTools(currentPlayer.walletAddress);
  final lands = await api.getPlayerLands(currentPlayer.walletAddress);

  return InventoryData(tools: tools, lands: lands);
});

/// Модель данных инвентаря
class InventoryData {
  final List<ToolNFT> tools;
  final List<LandNFT> lands;

  InventoryData({required this.tools, required this.lands});
}

/// Экран инвентаря с NFT инструментами и землями
class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventory = ref.watch(inventoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Инвентарь'),
        backgroundColor: const Color(0xFF2E8B57), // Зеленый цвет фермы
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(
              icon: Icon(Icons.build),
              text: 'Инструменты',
            ),
            Tab(
              icon: Icon(Icons.landscape),
              text: 'Земли',
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('Все'),
              ),
              const PopupMenuItem(
                value: 'level_1',
                child: Text('Уровень 1'),
              ),
              const PopupMenuItem(
                value: 'level_2',
                child: Text('Уровень 2'),
              ),
              const PopupMenuItem(
                value: 'level_3',
                child: Text('Уровень 3'),
              ),
              const PopupMenuItem(
                value: 'level_4',
                child: Text('Уровень 4'),
              ),
              const PopupMenuItem(
                value: 'needs_repair',
                child: Text('Нужен ремонт'),
              ),
            ],
          ),
        ],
      ),
      body: inventory.when(
        data: (data) => _buildInventoryContent(data),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Ошибка загрузки инвентаря',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(inventoryProvider),
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/marketplace'),
        backgroundColor: const Color(0xFF2E8B57),
        child: const Icon(Icons.shopping_cart),
      ),
    );
  }

  Widget _buildInventoryContent(InventoryData data) {
    return Column(
      children: [
        // Статистика инвентаря
        _buildInventoryStats(data),

        // Основной контент с вкладками
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildToolsTab(data.tools),
              _buildLandsTab(data.lands),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryStats(InventoryData data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.green.shade200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.build,
            label: 'Инструменты',
            value: data.tools.length.toString(),
            color: Colors.blue,
          ),
          _buildStatItem(
            icon: Icons.landscape,
            label: 'Земли',
            value: data.lands.length.toString(),
            color: Colors.green,
          ),
          _buildStatItem(
            icon: Icons.warning,
            label: 'Ремонт',
            value: data.tools.where((t) => t.needsRepair()).length.toString(),
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildToolsTab(List<ToolNFT> tools) {
    final filteredTools = _filterTools(tools);

    if (filteredTools.isEmpty) {
      return _buildEmptyState(
        icon: Icons.build,
        title: 'Нет инструментов',
        subtitle: 'Создайте или купите инструменты для начала фарма',
        actionText: 'Перейти к крафту',
        onAction: () => context.go('/crafting'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.refresh(inventoryProvider);
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: filteredTools.length,
        itemBuilder: (context, index) {
          final tool = filteredTools[index];
          return ToolCard(
            tool: tool,
            onTap: () => _showToolDetails(tool),
          );
        },
      ),
    );
  }

  Widget _buildLandsTab(List<LandNFT> lands) {
    if (lands.isEmpty) {
      return _buildEmptyState(
        icon: Icons.landscape,
        title: 'Нет земель',
        subtitle: 'Купите земли для увеличения эффективности фарма',
        actionText: 'Перейти к маркету',
        onAction: () => context.go('/marketplace'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.refresh(inventoryProvider);
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: lands.length,
        itemBuilder: (context, index) {
          final land = lands[index];
          return LandCard(
            land: land,
            onTap: () => _showLandDetails(land),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.add),
            label: Text(actionText),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E8B57),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  List<ToolNFT> _filterTools(List<ToolNFT> tools) {
    switch (_selectedFilter) {
      case 'level_1':
        return tools.where((t) => t.level == 1).toList();
      case 'level_2':
        return tools.where((t) => t.level == 2).toList();
      case 'level_3':
        return tools.where((t) => t.level == 3).toList();
      case 'level_4':
        return tools.where((t) => t.level == 4).toList();
      case 'needs_repair':
        return tools.where((t) => t.needsRepair()).toList();
      default:
        return tools;
    }
  }

  void _showToolDetails(ToolNFT tool) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ToolDetailsBottomSheet(tool: tool),
    );
  }

  void _showLandDetails(LandNFT land) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => LandDetailsBottomSheet(land: land),
    );
  }
}

/// Детали инструмента
class ToolDetailsBottomSheet extends StatelessWidget {
  final ToolNFT tool;

  const ToolDetailsBottomSheet({Key? key, required this.tool}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок
              Row(
                children: [
                  Icon(
                    _getToolIcon(tool.type),
                    size: 32,
                    color: _getToolColor(tool.type),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getToolName(tool.type),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          'Уровень ${tool.level}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Прочность
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Прочность',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: tool.durability / 100,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getDurabilityColor(tool.durability),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('${tool.durability}%'),
                    ],
                  ),
                ),
              ),

              // Статистика
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Характеристики',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _buildStatRow('Базовая добыча', '${GameCalculator.getBaseHarvest(tool.level)}'),
                      _buildStatRow('Множитель', '${GameCalculator.getToolMultiplier(tool.level)}x'),
                      _buildStatRow('Создан', FormatHelper.formatDate(tool.createdAt)),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Кнопки действий
              Row(
                children: [
                  if (tool.needsRepair()) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _repairTool(context, tool),
                        icon: const Icon(Icons.build),
                        label: const Text('Починить'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _sellTool(context, tool),
                      icon: const Icon(Icons.sell),
                      label: const Text('Продать'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E8B57),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  IconData _getToolIcon(ToolType type) {
    switch (type) {
      case ToolType.fishingRod:
        return Icons.catching_pokemon;
      case ToolType.axe:
        return Icons.park;
      case ToolType.pickaxe:
        return Icons.construction;
    }
  }

  Color _getToolColor(ToolType type) {
    switch (type) {
      case ToolType.fishingRod:
        return Colors.blue;
      case ToolType.axe:
        return Colors.brown;
      case ToolType.pickaxe:
        return Colors.grey;
    }
  }

  String _getToolName(ToolType type) {
    switch (type) {
      case ToolType.fishingRod:
        return 'Удочка';
      case ToolType.axe:
        return 'Топор';
      case ToolType.pickaxe:
        return 'Кирка';
    }
  }

  Color _getDurabilityColor(int durability) {
    if (durability > 60) return Colors.green;
    if (durability > 20) return Colors.orange;
    return Colors.red;
  }

  void _repairTool(BuildContext context, ToolNFT tool) {
    // Переход к экрану ремонта
    Navigator.of(context).pop();
    // Показать диалог ремонта
  }

  void _sellTool(BuildContext context, ToolNFT tool) {
    // Переход к маркетплейсу для продажи
    Navigator.of(context).pop();
    context.go('/marketplace');
  }
}

/// Детали земли
class LandDetailsBottomSheet extends StatelessWidget {
  final LandNFT land;

  const LandDetailsBottomSheet({Key? key, required this.land}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок
              Row(
                children: [
                  Icon(
                    _getLandIcon(land.type),
                    size: 32,
                    color: _getLandColor(land.type),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getLandName(land.type),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          'Уровень ${land.level}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Характеристики
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Характеристики',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _buildStatRow('Бонус добычи', '${GameCalculator.getLandBoost(land.level)}x'),
                      _buildStatRow('Создана', FormatHelper.formatDate(land.createdAt)),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Кнопка продажи
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _sellLand(context, land),
                  icon: const Icon(Icons.sell),
                  label: const Text('Продать'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E8B57),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  IconData _getLandIcon(LandType type) {
    switch (type) {
      case LandType.fishingGround:
        return Icons.water;
      case LandType.forest:
        return Icons.forest;
      case LandType.mine:
        return Icons.landscape;
    }
  }

  Color _getLandColor(LandType type) {
    switch (type) {
      case LandType.fishingGround:
        return Colors.blue;
      case LandType.forest:
        return Colors.green;
      case LandType.mine:
        return Colors.grey;
    }
  }

  String _getLandName(LandType type) {
    switch (type) {
      case LandType.fishingGround:
        return 'Рыбное место';
      case LandType.forest:
        return 'Лес';
      case LandType.mine:
        return 'Шахта';
    }
  }

  void _sellLand(BuildContext context, LandNFT land) {
    Navigator.of(context).pop();
    context.go('/marketplace');
  }
}
