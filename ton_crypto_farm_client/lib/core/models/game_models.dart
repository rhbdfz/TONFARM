import 'package:json_annotation/json_annotation.dart';

part 'game_models.g.dart';

@JsonSerializable()
class Player {
  final String id;
  final String telegramId;
  final String username;
  final String? walletAddress;
  final DateTime createdAt;

  Player({
    required this.id,
    required this.telegramId,
    required this.username,
    this.walletAddress,
    required this.createdAt,
  });

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerToJson(this);
}

@JsonSerializable()
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

  factory GameState.fromJson(Map<String, dynamic> json) => _$GameStateFromJson(json);
  Map<String, dynamic> toJson() => _$GameStateToJson(this);

  GameState copyWith({
    ResourceBalances? resources,
    int? energy,
    List<ToolNFT>? tools,
    List<LandNFT>? lands,
    DateTime? lastUpdate,
  }) {
    return GameState(
      resources: resources ?? this.resources,
      energy: energy ?? this.energy,
      tools: tools ?? this.tools,
      lands: lands ?? this.lands,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }
}

@JsonSerializable()
class ResourceBalances {
  final int food;
  final int wood;
  final int gold;

  ResourceBalances({
    required this.food,
    required this.wood,
    required this.gold,
  });

  factory ResourceBalances.fromJson(Map<String, dynamic> json) => _$ResourceBalancesFromJson(json);
  Map<String, dynamic> toJson() => _$ResourceBalancesToJson(this);
}

enum ToolType { fishingRod, axe, pickaxe }
enum LandType { lake, forest, mountain }

ToolType toolTypeFromJson(dynamic value) {
  if (value is int) return ToolType.values[value];
  if (value is String) return ToolType.values.firstWhere((e) => e.toString().split('.').last == value);
  throw Exception('Invalid ToolType value: $value');
}

LandType landTypeFromJson(dynamic value) {
  if (value is int) return LandType.values[value];
  if (value is String) return LandType.values.firstWhere((e) => e.toString().split('.').last == value);
  throw Exception('Invalid LandType value: $value');
}

@JsonSerializable()
class ToolNFT {
  final String id;
  final ToolType type;
  final int level;
  final int durability;
  final String owner;

  ToolNFT({
    required this.id,
    required this.type,
    required this.level,
    required this.durability,
    required this.owner,
  });

  factory ToolNFT.fromJson(Map<String, dynamic> json) => ToolNFT(
    id: json['id'] as String,
    type: toolTypeFromJson(json['type']),
    level: json['level'] as int,
    durability: json['durability'] as int,
    owner: json['owner'] as String,
  );
  Map<String, dynamic> toJson() => _$ToolNFTToJson(this);
}

@JsonSerializable()
class LandNFT {
  final String id;
  final LandType type;
  final int level;
  final String owner;

  LandNFT({
    required this.id,
    required this.type,
    required this.level,
    required this.owner,
  });

  factory LandNFT.fromJson(Map<String, dynamic> json) => LandNFT(
    id: json['id'] as String,
    type: landTypeFromJson(json['type']),
    level: json['level'] as int,
    owner: json['owner'] as String,
  );
  Map<String, dynamic> toJson() => _$LandNFTToJson(this);
}

enum ResourceType { food, wood, gold }

@JsonSerializable()
class CraftRequest {
  final String playerId;
  final ToolType toolType;
  final int level;
  final String playerAddress;

  CraftRequest({
    required this.playerId,
    required this.toolType,
    required this.level,
    required this.playerAddress,
  });

  factory CraftRequest.fromJson(Map<String, dynamic> json) => _$CraftRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CraftRequestToJson(this);
}

@JsonSerializable()
class CraftTransaction {
  final String contractAddress;
  final Map<String, dynamic> message;
  final String estimatedFee;
  final Map<String, int> requirements;

  CraftTransaction({
    required this.contractAddress,
    required this.message,
    required this.estimatedFee,
    required this.requirements,
  });

  factory CraftTransaction.fromJson(Map<String, dynamic> json) => _$CraftTransactionFromJson(json);
  Map<String, dynamic> toJson() => _$CraftTransactionToJson(this);

  Map<String, dynamic> toTonTransaction() {
    return {
      'to': contractAddress,
      'value': estimatedFee,
      'data': message['data'],
    };
  }
}

@JsonSerializable()
class HarvestRequest {
  final String playerId;
  final String toolId;
  final String? landId;
  final String playerAddress;

  HarvestRequest({
    required this.playerId,
    required this.toolId,
    this.landId,
    required this.playerAddress,
  });

  factory HarvestRequest.fromJson(Map<String, dynamic> json) => _$HarvestRequestFromJson(json);
  Map<String, dynamic> toJson() => _$HarvestRequestToJson(this);
}

@JsonSerializable()
class HarvestTransaction {
  final String contractAddress;
  final Map<String, dynamic> message;
  final String estimatedFee;
  final int harvestAmount;
  final int energyCost;

  HarvestTransaction({
    required this.contractAddress,
    required this.message,
    required this.estimatedFee,
    required this.harvestAmount,
    required this.energyCost,
  });

  factory HarvestTransaction.fromJson(Map<String, dynamic> json) => _$HarvestTransactionFromJson(json);
  Map<String, dynamic> toJson() => _$HarvestTransactionToJson(this);

  Map<String, dynamic> toTonTransaction() {
    return {
      'to': contractAddress,
      'value': estimatedFee,
      'data': message['data'],
    };
  }
}

@JsonSerializable()
class GameUpdate {
  final UpdateType type;
  final ResourceBalances? resources;
  final int? energy;
  final ToolNFT? tool;
  final String? message;

  GameUpdate({
    required this.type,
    this.resources,
    this.energy,
    this.tool,
    this.message,
  });

  factory GameUpdate.fromJson(Map<String, dynamic> json) => _$GameUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$GameUpdateToJson(this);
}

enum UpdateType {
  resourcesChanged,
  energyChanged,
  toolReceived,
  transactionConfirmed,
  error,
}
