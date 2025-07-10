import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'dart:convert';
import '../services/firebase_service.dart';
import '../services/ton_service.dart';
import '../models/player_model.dart';
import '../models/game_state_model.dart';
import '../utils/recipe_calculator.dart';

class PlayerController {
  Future<Response> register(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final telegramId = data['telegramId'] as String;
      final username = data['username'] as String;

      // Проверяем, существует ли уже игрок
      final existingPlayerId = await FirebaseService.findPlayerByTelegramId(telegramId);

      if (existingPlayerId != null) {
        final playerData = await FirebaseService.getPlayer(existingPlayerId);
        final gameStateData = await FirebaseService.getGameState(existingPlayerId);

        return Response.ok(
          jsonEncode({
            'success': true,
            'player': playerData,
            'gameState': gameStateData,
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Создание нового игрока
      final player = Player(
        telegramId: telegramId,
        username: username,
        walletAddress: null,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      final playerId = await FirebaseService.createPlayer(player.toMap());

      // Инициализация игрового состояния
      final gameState = GameState.initial();
      await FirebaseService.saveGameState(playerId, gameState.toMap());

      return Response.ok(
        jsonEncode({
          'success': true,
          'player': player.toMap()..['id'] = playerId,
          'gameState': gameState.toMap(),
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

  Future<Response> getState(Request request) async {
    try {
      final playerId = request.params['playerId']!;

      final playerData = await FirebaseService.getPlayer(playerId);
      final gameStateData = await FirebaseService.getGameState(playerId);

      if (playerData == null || gameStateData == null) {
        return Response.notFound(
          jsonEncode({'error': 'Player not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final player = Player.fromMap(playerData);
      final gameState = GameState.fromMap(gameStateData);

      // Обновление балансов из блокчейна если кошелек подключен
      if (player.walletAddress != null) {
        try {
          final foodBalance = await TonService.getJettonBalance(
            player.walletAddress!,
            TonService.getJettonAddress('food'),
          );
          final woodBalance = await TonService.getJettonBalance(
            player.walletAddress!,
            TonService.getJettonAddress('wood'),
          );
          final goldBalance = await TonService.getJettonBalance(
            player.walletAddress!,
            TonService.getJettonAddress('gold'),
          );
          final energy = await TonService.getPlayerEnergy(player.walletAddress!);

          final updatedGameState = gameState.updateBalances(
            food: foodBalance.toInt(),
            wood: woodBalance.toInt(),
            gold: goldBalance.toInt(),
            energy: energy,
          );

          // Сохраняем обновленное состояние
          await FirebaseService.saveGameState(playerId, updatedGameState.toMap());

          return Response.ok(
            jsonEncode({
              'player': player.toMap()..['id'] = playerId,
              'gameState': updatedGameState.toMap(),
            }),
            headers: {'Content-Type': 'application/json'},
          );
        } catch (e) {
          print('Error updating balances from blockchain: $e');
          // Возвращаем cached данные если блокчейн недоступен
        }
      }

      return Response.ok(
        jsonEncode({
          'player': player.toMap()..['id'] = playerId,
          'gameState': gameState.toMap(),
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

  Future<Response> linkWallet(Request request) async {
    try {
      final playerId = request.params['playerId']!;
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final walletAddress = data['walletAddress'] as String;

      // Обновление адреса кошелька
      await FirebaseService.updatePlayer(playerId, {
        'walletAddress': walletAddress,
        'linkedAt': DateTime.now().toIso8601String(),
      });

      // Загрузка балансов из блокчейна
      final balances = await _loadBalances(walletAddress);

      return Response.ok(
        jsonEncode({
          'success': true,
          'walletAddress': walletAddress,
          'balances': balances,
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

  Future<Map<String, int>> _loadBalances(String walletAddress) async {
    try {
      final foodBalance = await TonService.getJettonBalance(
        walletAddress,
        TonService.getJettonAddress('food'),
      );
      final woodBalance = await TonService.getJettonBalance(
        walletAddress,
        TonService.getJettonAddress('wood'),
      );
      final goldBalance = await TonService.getJettonBalance(
        walletAddress,
        TonService.getJettonAddress('gold'),
      );
      final energy = await TonService.getPlayerEnergy(walletAddress);

      return {
        'food': foodBalance.toInt(),
        'wood': woodBalance.toInt(),
        'gold': goldBalance.toInt(),
        'energy': energy,
      };
    } catch (e) {
      print('Error loading balances: $e');
      return {
        'food': 500,
        'wood': 300,
        'gold': 100,
        'energy': 100,
      };
    }
  }
}
