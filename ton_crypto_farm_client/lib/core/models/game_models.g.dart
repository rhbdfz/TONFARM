// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Player _$PlayerFromJson(Map<String, dynamic> json) => Player(
      id: json['id'] as String,
      telegramId: json['telegramId'] as String,
      username: json['username'] as String,
      walletAddress: json['walletAddress'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$PlayerToJson(Player instance) => <String, dynamic>{
      'id': instance.id,
      'telegramId': instance.telegramId,
      'username': instance.username,
      'walletAddress': instance.walletAddress,
      'createdAt': instance.createdAt.toIso8601String(),
    };

GameState _$GameStateFromJson(Map<String, dynamic> json) => GameState(
      resources:
          ResourceBalances.fromJson(json['resources'] as Map<String, dynamic>),
      energy: (json['energy'] as num).toInt(),
      tools: (json['tools'] as List<dynamic>)
          .map((e) => ToolNFT.fromJson(e as Map<String, dynamic>))
          .toList(),
      lands: (json['lands'] as List<dynamic>)
          .map((e) => LandNFT.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastUpdate: DateTime.parse(json['lastUpdate'] as String),
    );

Map<String, dynamic> _$GameStateToJson(GameState instance) => <String, dynamic>{
      'resources': instance.resources,
      'energy': instance.energy,
      'tools': instance.tools,
      'lands': instance.lands,
      'lastUpdate': instance.lastUpdate.toIso8601String(),
    };

ResourceBalances _$ResourceBalancesFromJson(Map<String, dynamic> json) =>
    ResourceBalances(
      food: (json['food'] as num).toInt(),
      wood: (json['wood'] as num).toInt(),
      gold: (json['gold'] as num).toInt(),
    );

Map<String, dynamic> _$ResourceBalancesToJson(ResourceBalances instance) =>
    <String, dynamic>{
      'food': instance.food,
      'wood': instance.wood,
      'gold': instance.gold,
    };

ToolNFT _$ToolNFTFromJson(Map<String, dynamic> json) => ToolNFT(
      id: json['id'] as String,
      type: toolTypeFromJson(json['type']),
      level: (json['level'] as num).toInt(),
      durability: (json['durability'] as num).toInt(),
      owner: json['owner'] as String,
    );

Map<String, dynamic> _$ToolNFTToJson(ToolNFT instance) => <String, dynamic>{
      'id': instance.id,
      'type': _$ToolTypeEnumMap[instance.type]!,
      'level': instance.level,
      'durability': instance.durability,
      'owner': instance.owner,
    };

const _$ToolTypeEnumMap = {
  ToolType.fishingRod: 'fishingRod',
  ToolType.axe: 'axe',
  ToolType.pickaxe: 'pickaxe',
};

LandNFT _$LandNFTFromJson(Map<String, dynamic> json) => LandNFT(
      id: json['id'] as String,
      type: landTypeFromJson(json['type']),
      level: (json['level'] as num).toInt(),
      owner: json['owner'] as String,
    );

Map<String, dynamic> _$LandNFTToJson(LandNFT instance) => <String, dynamic>{
      'id': instance.id,
      'type': _$LandTypeEnumMap[instance.type]!,
      'level': instance.level,
      'owner': instance.owner,
    };

const _$LandTypeEnumMap = {
  LandType.lake: 'lake',
  LandType.forest: 'forest',
  LandType.mountain: 'mountain',
};

CraftRequest _$CraftRequestFromJson(Map<String, dynamic> json) => CraftRequest(
      playerId: json['playerId'] as String,
      toolType: $enumDecode(_$ToolTypeEnumMap, json['toolType']),
      level: (json['level'] as num).toInt(),
      playerAddress: json['playerAddress'] as String,
    );

Map<String, dynamic> _$CraftRequestToJson(CraftRequest instance) =>
    <String, dynamic>{
      'playerId': instance.playerId,
      'toolType': _$ToolTypeEnumMap[instance.toolType]!,
      'level': instance.level,
      'playerAddress': instance.playerAddress,
    };

CraftTransaction _$CraftTransactionFromJson(Map<String, dynamic> json) =>
    CraftTransaction(
      contractAddress: json['contractAddress'] as String,
      message: json['message'] as Map<String, dynamic>,
      estimatedFee: json['estimatedFee'] as String,
      requirements: Map<String, int>.from(json['requirements'] as Map),
    );

Map<String, dynamic> _$CraftTransactionToJson(CraftTransaction instance) =>
    <String, dynamic>{
      'contractAddress': instance.contractAddress,
      'message': instance.message,
      'estimatedFee': instance.estimatedFee,
      'requirements': instance.requirements,
    };

HarvestRequest _$HarvestRequestFromJson(Map<String, dynamic> json) =>
    HarvestRequest(
      playerId: json['playerId'] as String,
      toolId: json['toolId'] as String,
      landId: json['landId'] as String?,
      playerAddress: json['playerAddress'] as String,
    );

Map<String, dynamic> _$HarvestRequestToJson(HarvestRequest instance) =>
    <String, dynamic>{
      'playerId': instance.playerId,
      'toolId': instance.toolId,
      'landId': instance.landId,
      'playerAddress': instance.playerAddress,
    };

HarvestTransaction _$HarvestTransactionFromJson(Map<String, dynamic> json) =>
    HarvestTransaction(
      contractAddress: json['contractAddress'] as String,
      message: json['message'] as Map<String, dynamic>,
      estimatedFee: json['estimatedFee'] as String,
      harvestAmount: (json['harvestAmount'] as num).toInt(),
      energyCost: (json['energyCost'] as num).toInt(),
    );

Map<String, dynamic> _$HarvestTransactionToJson(HarvestTransaction instance) =>
    <String, dynamic>{
      'contractAddress': instance.contractAddress,
      'message': instance.message,
      'estimatedFee': instance.estimatedFee,
      'harvestAmount': instance.harvestAmount,
      'energyCost': instance.energyCost,
    };

GameUpdate _$GameUpdateFromJson(Map<String, dynamic> json) => GameUpdate(
      type: $enumDecode(_$UpdateTypeEnumMap, json['type']),
      resources: json['resources'] == null
          ? null
          : ResourceBalances.fromJson(
              json['resources'] as Map<String, dynamic>),
      energy: (json['energy'] as num?)?.toInt(),
      tool: json['tool'] == null
          ? null
          : ToolNFT.fromJson(json['tool'] as Map<String, dynamic>),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$GameUpdateToJson(GameUpdate instance) =>
    <String, dynamic>{
      'type': _$UpdateTypeEnumMap[instance.type]!,
      'resources': instance.resources,
      'energy': instance.energy,
      'tool': instance.tool,
      'message': instance.message,
    };

const _$UpdateTypeEnumMap = {
  UpdateType.resourcesChanged: 'resourcesChanged',
  UpdateType.energyChanged: 'energyChanged',
  UpdateType.toolReceived: 'toolReceived',
  UpdateType.transactionConfirmed: 'transactionConfirmed',
  UpdateType.error: 'error',
};
