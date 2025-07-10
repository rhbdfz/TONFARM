import '../models/game_state_model.dart';

class RecipeRepository {
  static final Map<ToolType, Map<int, Recipe>> _recipes = {
    ToolType.fishingRod: {
      1: Recipe(food: 843, wood: 263, gold: 59, foodRatio: 0.6, woodRatio: 0.3, goldRatio: 0.1),
      2: Recipe(food: 2693, wood: 842, gold: 187, foodRatio: 0.6, woodRatio: 0.3, goldRatio: 0.1),
      3: Recipe(food: 7111, wood: 2222, gold: 494, foodRatio: 0.6, woodRatio: 0.3, goldRatio: 0.1),
      4: Recipe(food: 18086, wood: 5652, gold: 1256, foodRatio: 0.6, woodRatio: 0.3, goldRatio: 0.1),
    },
    ToolType.axe: {
      1: Recipe(food: 281, wood: 527, gold: 117, foodRatio: 0.2, woodRatio: 0.6, goldRatio: 0.2),
      2: Recipe(food: 898, wood: 1683, gold: 374, foodRatio: 0.2, woodRatio: 0.6, goldRatio: 0.2),
      3: Recipe(food: 2370, wood: 4444, gold: 988, foodRatio: 0.2, woodRatio: 0.6, goldRatio: 0.2),
      4: Recipe(food: 6029, wood: 11304, gold: 2512, foodRatio: 0.2, woodRatio: 0.6, goldRatio: 0.2),
    },
    ToolType.pickaxe: {
      1: Recipe(food: 140, wood: 263, gold: 351, foodRatio: 0.1, woodRatio: 0.3, goldRatio: 0.6),
      2: Recipe(food: 449, wood: 842, gold: 1122, foodRatio: 0.1, woodRatio: 0.3, goldRatio: 0.6),
      3: Recipe(food: 1185, wood: 2222, gold: 2963, foodRatio: 0.1, woodRatio: 0.3, goldRatio: 0.6),
      4: Recipe(food: 3014, wood: 5652, gold: 7536, foodRatio: 0.1, woodRatio: 0.3, goldRatio: 0.6),
    },
  };

  static Recipe getRecipe(ToolType toolType, int level) {
    final toolRecipes = _recipes[toolType];
    if (toolRecipes == null) {
      throw Exception('Unknown tool type: $toolType');
    }

    final recipe = toolRecipes[level];
    if (recipe == null) {
      throw Exception('Unknown level $level for tool $toolType');
    }

    return recipe;
  }

  static Map<String, int> getRecipeMap(ToolType toolType, int level) {
    final recipe = getRecipe(toolType, level);
    return {
      'food': recipe.food,
      'wood': recipe.wood,
      'gold': recipe.gold,
    };
  }

  static List<Recipe> getAllRecipesForTool(ToolType toolType) {
    final toolRecipes = _recipes[toolType];
    if (toolRecipes == null) return [];

    return toolRecipes.values.toList();
  }

  static int getTotalCost(ToolType toolType, int level) {
    final recipe = getRecipe(toolType, level);
    return recipe.totalCost;
  }
}

class Recipe {
  final int food;
  final int wood;
  final int gold;
  final double foodRatio;
  final double woodRatio;
  final double goldRatio;

  Recipe({
    required this.food,
    required this.wood,
    required this.gold,
    required this.foodRatio,
    required this.woodRatio,
    required this.goldRatio,
  });

  int get totalCost => food + wood + gold;

  Map<String, int> toMap() {
    return {
      'food': food,
      'wood': wood,
      'gold': gold,
    };
  }

  Map<String, double> getRatios() {
    return {
      'food': foodRatio,
      'wood': woodRatio,
      'gold': goldRatio,
    };
  }
}
