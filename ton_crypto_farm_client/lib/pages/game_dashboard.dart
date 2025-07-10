import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../conponents/energy_bar.dart';
import '../conponents/resource_display.dart';
import '../conponents/tool_inventory.dart';
import '../providers/game_provider.dart';
import '../core/models/game_models.dart';

class GameDashboard extends StatelessWidget {
  const GameDashboard({Key? key}) : super(key: key);

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
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: gameProvider.isLoading
                              ? null
                              : () => _showHarvestDialog(context, gameProvider),
                          icon: const Icon(Icons.agriculture),
                          label: const Text('Farm'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: gameProvider.isLoading
                              ? null
                              : () => _showCraftDialog(context, gameProvider),
                          icon: const Icon(Icons.build),
                          label: const Text('Craft'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      // Navigate to marketplace
                    },
                    icon: const Icon(Icons.store),
                    label: const Text('Marketplace'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showHarvestDialog(BuildContext context, GameProvider gameProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Harvest Resources'),
        content: const Text('Select a tool to harvest resources'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          if (gameProvider.gameState?.tools.isNotEmpty ?? false)
            TextButton(
              onPressed: () {
                final firstTool = gameProvider.gameState!.tools.first;
                gameProvider.harvestResources(firstTool.id, null);
                Navigator.pop(context);
              },
              child: const Text('Harvest'),
            ),
        ],
      ),
    );
  }

  void _showCraftDialog(BuildContext context, GameProvider gameProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Craft Tool'),
        content: const Text('Choose a tool to craft'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              gameProvider.craftTool(ToolType.fishingRod, 1);
              Navigator.pop(context);
            },
            child: const Text('Craft Fishing Rod'),
          ),
        ],
      ),
    );
  }
}
