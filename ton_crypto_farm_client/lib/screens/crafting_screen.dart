import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/game_api.dart';
import '../services/ton_connect_service.dart';


/// Провайдер списка рецептов
final recipesProvider = FutureProvider<List<Recipe>>((ref) async {
  return await GameAPI().getRecipes();
});

/// Экран крафта инструментов
class CraftingScreen extends ConsumerWidget {
  const CraftingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(recipesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Крафт'),
        backgroundColor: const Color(0xFF40A6FF),
      ),
      body: recipesAsync.when(
        data: (recipes) => _buildRecipesList(context, recipes),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка загрузки рецептов: $e')),
      ),
    );
  }

  Widget _buildRecipesList(BuildContext context, List<Recipe> recipes) {
    return RefreshIndicator(
      onRefresh: () async {
        // Перезагрузка провайдера
        context.refresh(recipesProvider);
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: recipes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => RecipeCard(
          recipe: recipes[i],
          onCraft: () => _onCraftPressed(context, recipes[i]),
        ),
      ),
    );
  }

  Future<void> _onCraftPressed(BuildContext context, Recipe r) async {
    final prep = await GameAPI().prepareCraftTransaction(
      toolType: r.toolType,
      level: r.level,
      playerAddress: TonConnectService().walletAddress!,
    );
    // Переход к экрану подтверждения (диалог)
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Подтвердить крафт'),
        content: Text(
          'Ресурсы: Еда ${r.requirements.food}, Дерево ${r.requirements.wood}, Золото ${r.requirements.gold}\n'
              'Комиссия: ${prep.commission}',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await TonConnectService().sendTransaction(
                prep.contractAddress,
                prep.message,
              );
            },
            child: const Text('Крафтить'),
          ),
        ],
      ),
    );
  }
}
