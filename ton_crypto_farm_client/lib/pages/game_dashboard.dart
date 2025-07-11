import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../conponents/energy_bar.dart';
import '../conponents/resource_display.dart';
import '../conponents/tool_inventory.dart';
import '../providers/game_provider.dart';
import '../core/models/game_models.dart';

class GameDashboard extends StatelessWidget {
  const GameDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TON Farm'),
        actions: [
          Consumer<GameProvider>(
            builder: (context, gameProvider, child) {
              return IconButton(
                icon: Icon(
                  gameProvider.player?.walletAddress != null
                      ? Icons.account_balance_wallet
                      : Icons.account_balance_wallet_outlined,
                  color: gameProvider.player?.walletAddress != null
                      ? Colors.green
                      : null,
                ),
                onPressed: gameProvider.isLoading
                    ? null
                    : () => gameProvider.connectWallet(),
              );
            },
          ),
        ],
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          if (gameProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final gameState = gameProvider.gameState;
          if (gameState == null) {
            return const Center(child: Text('Loading game state...'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Можно добавить метод refresh в GameProvider
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ResourceDisplay(resources: gameState.resources),
                  const SizedBox(height: 16),
                  EnergyBar(energy: gameState.energy),
                  const SizedBox(height: 16),
                  ToolInventory(tools: gameState.tools),
                  const SizedBox(height: 24),
                  _buildActionButtons(context, gameProvider),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildActionButtons(BuildContext context, GameProvider gameProvider) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to crafting screen
                },
                icon: const Icon(Icons.build),
                label: const Text('Крафт'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to farming screen
                },
                icon: const Icon(Icons.agriculture),
                label: const Text('Фарм'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to marketplace
                },
                icon: const Icon(Icons.store),
                label: const Text('Маркет'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to inventory
                },
                icon: const Icon(Icons.inventory),
                label: const Text('Инвентарь'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Главная',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.agriculture),
          label: 'Фарм',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.build),
          label: 'Крафт',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.store),
          label: 'Маркет',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Профиль',
        ),
      ],
      currentIndex: 0,
      onTap: (index) {
        // Handle navigation
      },
    );
  }
}
