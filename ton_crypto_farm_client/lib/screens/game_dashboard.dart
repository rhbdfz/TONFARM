import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../services/game_api.dart';
import '../services/ton_connect_service.dart';
import '../widgets/resource_bar.dart';
import '../widgets/energy_bar.dart';
import '../widgets/tool_card.dart';

/// Провайдер состояния игры
final gameStateProvider = FutureProvider<GameState?>((ref) async {
  final tonConnect = TonConnectService();
  if (tonConnect.walletAddress == null) {
    return null;
  }

  final api = GameAPI();
  return await api.getPlayerState(tonConnect.walletAddress!);
});

/// Главный экран дашборда игры
class GameDashboardScreen extends ConsumerStatefulWidget {
  const GameDashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<GameDashboardScreen> createState() => _GameDashboardScreenState();
}

class _GameDashboardScreenState extends ConsumerState<GameDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  /// Инициализация игры
  Future<void> _initializeGame() async {
    final tonConnect = TonConnectService();

    // Проверка подключения кошелька
    if (!tonConnect.isConnected) {
      _showWalletConnectionDialog();
    }
  }

  /// Диалог подключения кошелька
  void _showWalletConnectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Подключите кошелек'),
        content: const Text('Для игры необходимо подключить TON кошелек'),
        actions: [
          TextButton(
            onPressed: () async {
              final result = await TonConnectService().connectWallet();
              if (result.isSuccess) {
                Navigator.of(context).pop();
                setState(() {});
              }
            },
            child: const Text('Подключить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TON Crypto Farm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: gameState.when(
        data: (state) {
          if (state == null) {
            return const Center(
              child: Text('Подключите кошелек для начала игры'),
            );
          }

          return _buildGameContent(state);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Ошибка: $error'),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  /// Основной контент игры
  Widget _buildGameContent(GameState gameState) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.refresh(gameStateProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ресурсы и энергия
            ResourceBar(resources: gameState.resources),
            const SizedBox(height: 16),
            EnergyBar(
              currentEnergy: gameState.resources.energy,
              maxEnergy: gameState.resources.maxEnergy,
            ),
            const SizedBox(height: 24),

            // Быстрые действия
            _buildQuickActions(gameState),
            const SizedBox(height: 24),

            // Инструменты
            const Text(
              'Ваши инструменты',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildToolsGrid(gameState.tools),
            const SizedBox(height: 24),

            // Статистика
            _buildStats(gameState),
          ],
        ),
      ),
    );
  }

  /// Быстрые действия
  Widget _buildQuickActions(GameState gameState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Быстрые действия',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/farm'),
                icon: const Icon(Icons.agriculture),
                label: const Text('Фарм'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/crafting'),
                icon: const Icon(Icons.build),
                label: const Text('Крафт'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/marketplace'),
                icon: const Icon(Icons.store),
                label: const Text('Маркет'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/packs'),
                icon: const Icon(Icons.card_giftcard),
                label: const Text('Паки'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Сетка инструментов
  Widget _buildToolsGrid(List tools) {
    if (tools.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(
            child: Text('У вас пока нет инструментов'),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: tools.length,
      itemBuilder: (context, index) {
        return ToolCard(tool: tools[index]);
      },
    );
  }

  /// Статистика игрока
  Widget _buildStats(GameState gameState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Статистика',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Уровень:'),
                Text('${gameState.player.level}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Опыт:'),
                Text('${gameState.player.experience}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Инструментов:'),
                Text('${gameState.tools.length}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Земель:'),
                Text('${gameState.lands.length}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Нижняя навигация
  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Дашборд',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory),
          label: 'Инвентарь',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.agriculture),
          label: 'Фарм',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.store),
          label: 'Маркет',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.swap_horiz),
          label: 'DEX',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
          // Уже на главном экране
            break;
          case 1:
            Navigator.pushNamed(context, '/inventory');
            break;
          case 2:
            Navigator.pushNamed(context, '/farm');
            break;
          case 3:
            Navigator.pushNamed(context, '/marketplace');
            break;
          case 4:
            Navigator.pushNamed(context, '/dex');
            break;
        }
      },
    );
  }
}
