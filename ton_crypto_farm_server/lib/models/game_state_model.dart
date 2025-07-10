enum ToolType { fishingRod, axe, pickaxe }
enum LandType { lake, forest, mountain }

class GameState {
  final ResourceBalances resources;
  final int energy;
  final List<ToolNFT> tools;
  final List<LandNFT> lands;
  final DateTime lastUpdate;

  GameState({
    required this.resources,
    required this.energy,
    required this.tools,
    required this.lands,
    required this.lastUpdate,
  });

  factory GameState.initial() {
    return GameState(
      resources: ResourceBalances(food: 500, wood: 300, gold: 100),
      energy: 100,
      tools: [],
      lands: [],
      lastUpdate: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'resources': resources.toMap(),
      'energy': energy,
      'tools': tools.map((tool) => tool.toMap()).toList(),
      'lands': lands.map((land) => land.toMap()).toList(),
      'lastUpdate': lastUpdate.toIso8601String(),
    };
  }

  factory GameState.fromMap(Map<String, dynamic> map) {
    return GameState(
      resources: ResourceBalances.fromMap(map['resources'] as Map<String, dynamic>),
      energy: map['energy'] as int,
      tools: (map['tools'] as List).map((tool) => ToolNFT.fromMap(tool as Map<String, dynamic>)).toList(),
      lands: (map['lands'] as List).map((land) => LandNFT.fromMap(land as Map<String, dynamic>)).toList(),
      lastUpdate: DateTime.parse(map['lastUpdate'] as String),
    );
  }

  bool hasEnoughResources(Map<String, int> recipe) {
    return resources.food >= (recipe['food'] ?? 0) &&
        resources.wood >= (recipe['wood'] ?? 0) &&
        resources.gold >= (recipe['gold'] ?? 0);
  }

  GameState updateBalances({
    required int food,
    required int wood,
    required int gold,
    required int energy,
  }) {
    return GameState(
      resources: ResourceBalances(food: food, wood: wood, gold: gold),
      energy: energy,
      tools: tools,
      lands: lands,
      lastUpdate: DateTime.now(),
    );
  }

  GameState addTool(ToolNFT tool) {
    return GameState(
      resources: resources,
      energy: energy,
      tools: [...tools, tool],
      lands: lands,
      lastUpdate: DateTime.now(),
    );
  }

  GameState addLand(LandNFT land) {
    return GameState(
      resources: resources,
      energy: energy,
      tools: tools,
      lands: [...lands, land],
      lastUpdate: DateTime.now(),
    );
  }

  GameState updateEnergy(int newEnergy) {
    return GameState(
      resources: resources,
      energy: newEnergy,
      tools: tools,
      lands: lands,
      lastUpdate: DateTime.now(),
    );
  }
}

class ResourceBalances {
  final int food;
  final int wood;
  final int gold;

  ResourceBalances({
    required this.food,
    required this.wood,
    required this.gold,
  });

  Map<String, dynamic> toMap() {
    return {
      'food': food,
      'wood': wood,
      'gold': gold,
    };
  }

  factory ResourceBalances.fromMap(Map<String, dynamic> map) {
    return ResourceBalances(
      food: map['food'] as int,
      wood: map['wood'] as int,
      gold: map['gold'] as int,
    );
  }

  int getTotalValue() {
    return food + wood + gold;
  }

  ResourceBalances subtract(Map<String, int> costs) {
    return ResourceBalances(
      food: food - (costs['food'] ?? 0),
      wood: wood - (costs['wood'] ?? 0),
      gold: gold - (costs['gold'] ?? 0),
    );
  }

  ResourceBalances add(Map<String, int> gains) {
    return ResourceBalances(
      food: food + (gains['food'] ?? 0),
      wood: wood + (gains['wood'] ?? 0),
      gold: gold + (gains['gold'] ?? 0),
    );
  }
}

class ToolNFT {
  final String id;
  final ToolType type;
  final int level;
  final int durability;
  final String owner;
  final DateTime createdAt;

  ToolNFT({
    required this.id,
    required this.type,
    required this.level,
    required this.durability,
    required this.owner,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.index,
      'level': level,
      'durability': durability,
      'owner': owner,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ToolNFT.fromMap(Map<String, dynamic> map) {
    return ToolNFT(
      id: map['id'] as String,
      type: ToolType.values[map['type'] as int],
      level: map['level'] as int,
      durability: map['durability'] as int,
      owner: map['owner'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  bool needsRepair() {
    return durability < 20;
  }

  bool isBroken() {
    return durability <= 0;
  }

  ToolNFT decreaseDurability(int amount) {
    return ToolNFT(
      id: id,
      type: type,
      level: level,
      durability: (durability - amount).clamp(0, 100),
      owner: owner,
      createdAt: createdAt,
    );
  }

  ToolNFT repair() {
    return ToolNFT(
      id: id,
      type: type,
      level: level,
      durability: 100,
      owner: owner,
      createdAt: createdAt,
    );
  }
}

class LandNFT {
  final String id;
  final LandType type;
  final int level;
  final String owner;
  final DateTime createdAt;

  LandNFT({
    required this.id,
    required this.type,
    required this.level,
    required this.owner,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.index,
      'level': level,
      'owner': owner,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory LandNFT.fromMap(Map<String, dynamic> map) {
    return LandNFT(
      id: map['id'] as String,
      type: LandType.values[map['type'] as int],
      level: map['level'] as int,
      owner: map['owner'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  double getBoost() {
    switch (level) {
      case 1: return 1.5;
      case 2: return 2.0;
      case 3: return 2.7;
      case 4: return 3.5;
      default: return 1.0;
    }
  }

  bool isCompatibleWith(ToolType toolType) {
    switch (type) {
      case LandType.lake:
        return toolType == ToolType.fishingRod;
      case LandType.forest:
        return toolType == ToolType.axe;
      case LandType.mountain:
        return toolType == ToolType.pickaxe;
    }
  }
}
