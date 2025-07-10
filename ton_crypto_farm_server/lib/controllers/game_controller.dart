import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'dart:convert';
import '../services/firebase_service.dart';
import '../services/ton_service.dart';
import '../models/game_state_model.dart';
import '../utils/recipe_calculator.dart';

class GameController {
  Future<Response> prepareCraft(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final playerId = data['playerId'] as String;
      // Accept both string and int for toolType
      int toolTypeIndex;
      if (data['toolType'] is int) {
        toolTypeIndex = data['toolType'];
      } else if (data['toolType'] is String) {
        toolTypeIndex = ToolType.values.indexWhere((e) => e.toString().split('.').last == data['toolType']);
        if (toolTypeIndex == -1) throw Exception('Invalid toolType value');
      } else {
        throw Exception('Invalid toolType type');
      }
      final level = data['level'] as int;
      final playerAddress = data['playerAddress'] as String;

      // Получение рецепта
      final recipe = RecipeCalculator.getRecipe(toolTypeIndex, level);

      // Проверка ресурсов игрока
      final gameStateData = await FirebaseService.getGameState(playerId);
      if (gameStateData == null) {
        return Response.notFound(
          jsonEncode({'error': 'Player not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final gameState = GameState.fromMap(gameStateData);
      if (!gameState.hasEnoughResources(recipe)) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Insufficient resources'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Создание сообщения для контракта
      final craftMessage = await TonService.createCraftMessage(
        playerAddress,
        toolTypeIndex,
        level,
        recipe,
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'contractAddress': craftMessage['to'],
          'message': craftMessage,
          'requirements': recipe, // Use 'requirements' instead of 'recipe'
          'estimatedFee': '0.05',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> prepareFarm(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final playerId = data['playerId'] as String;
      final toolId = data['toolId'] as String;
      final landId = data['landId'] as String?;
      final playerAddress = data['playerAddress'] as String;

      // Получение состояния игры
      final gameStateData = await FirebaseService.getGameState(playerId);
      if (gameStateData == null) {
        return Response.notFound(
          jsonEncode({'error': 'Player not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final gameState = GameState.fromMap(gameStateData);

      // Проверка энергии
      if (gameState.energy < 10) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Insufficient energy'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Получение данных инструмента
      final tool = gameState.tools.firstWhere(
            (t) => t.id == toolId,
        orElse: () => throw Exception('Tool not found'),
      );

      final land = landId != null
          ? gameState.lands.firstWhere(
            (l) => l.id == landId,
        orElse: () => throw Exception('Land not found'),
      )
          : null;

      // Расчет добычи
      final harvestAmount = RecipeCalculator.calculateHarvest(
        tool.type.index,
        tool.level,
        land?.level,
      );

      // Создание сообщения для контракта
      final farmMessage = await TonService.createFarmMessage(
        playerAddress,
        tool.type.index,
        tool.level,
        land?.level,
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'contractAddress': farmMessage['to'],
          'message': farmMessage,
          'harvestAmount': harvestAmount,
          'energyCost': 10,
          'estimatedFee': '0.05',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> getBalance(Request request) async {
    try {
      final address = request.params['address']!;
      final token = request.params['token']!;

      BigInt balance = BigInt.zero;

      switch (token) {
        case 'food':
        case 'wood':
        case 'gold':
          balance = await TonService.getJettonBalance(
            address,
            TonService.getJettonAddress(token),
          );
          break;
        case 'energy':
          final energyInt = await TonService.getPlayerEnergy(address);
          balance = BigInt.from(energyInt);
          break;
        default:
          return Response.badRequest(
            body: jsonEncode({'error': 'Unknown token type'}),
            headers: {'Content-Type': 'application/json'},
          );
      }

      return Response.ok(
        jsonEncode({
          'address': address,
          'token': token,
          'balance': balance.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
