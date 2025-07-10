class RecipeCalculator {
  static final Map<int, Map<int, Map<String, int>>> _recipes = {
    // Удочка (60% еда, 30% дерево, 10% золото)
    0: {
      1: {'food': 843, 'wood': 263, 'gold': 59},
      2: {'food': 2693, 'wood': 842, 'gold': 187},
      3: {'food': 7111, 'wood': 2222, 'gold': 494},
      4: {'food': 18086, 'wood': 5652, 'gold': 1256},
    },
    // Топор (20% еда, 60% дерево, 20% золото)
    1: {
      1: {'food': 281, 'wood': 527, 'gold': 117},
      2: {'food': 898, 'wood': 1683, 'gold': 374},
      3: {'food': 2370, 'wood': 4444, 'gold': 988},
      4: {'food': 6029, 'wood': 11304, 'gold': 2512},
    },
    // Кирка (10% еда, 30% дерево, 60% золото)
    2: {
      1: {'food': 140, 'wood': 263, 'gold': 351},
      2: {'food': 449, 'wood': 842, 'gold': 1122},
      3: {'food': 1185, 'wood': 2222, 'gold': 2963},
      4: {'food': 3014, 'wood': 5652, 'gold': 7536},
    },
  };

  static final Map<int, double> _toolMultipliers = {
    1: 1.0,
    2: 1.75,
    3: 2.8,
    4: 4.5,
  };

  static final Map<int, double> _landMultipliers = {
    1: 1.5,
    2: 2.0,
    3: 2.7,
    4: 3.5,
  };

  static const int _baseHarvest = 120;

  static Map<String, int> getRecipe(int toolType, int level) {
    return _recipes[toolType]?[level] ?? {};
  }

  static int calculateHarvest(int toolType, int toolLevel, int? landLevel) {
    final toolMultiplier = _toolMultipliers[toolLevel] ?? 1.0;
    final landMultiplier = landLevel != null
        ? (_landMultipliers[landLevel] ?? 1.0)
        : 1.0;

    return (_baseHarvest * toolMultiplier * landMultiplier).round();
  }

  static Map<String, int> calculateRepairCost(
      int toolType,
      int level,
      int currentDurability,
      ) {
    final originalCost = getRecipe(toolType, level);
    final durabilityLoss = 100 - currentDurability;
    final repairRatio = durabilityLoss * 0.0005;

    return {
      'food': (originalCost['food']! * repairRatio).round(),
      'wood': (originalCost['wood']! * repairRatio).round(),
      'gold': (originalCost['gold']! * repairRatio).round(),
    };
  }
}
