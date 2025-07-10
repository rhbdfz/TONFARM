import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/game_models.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080/api';

  final http.Client _client = http.Client();

  Future<Player> registerPlayer(String telegramId, String username) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/players/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'telegramId': telegramId,
          'username': username,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Player.fromJson(data['player']);
      } else {
        throw Exception('Failed to register player: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API Error: $e');
    }
  }

  Future<GameState> getGameState(String playerId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/players/$playerId/state'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return GameState.fromJson(data['gameState']);
      } else {
        throw Exception('Failed to get game state: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API Error: $e');
    }
  }

  Future<CraftTransaction> prepareCraftTransaction(CraftRequest request) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/craft/prepare'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CraftTransaction.fromJson(data);
      } else {
        throw Exception('Failed to prepare craft: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API Error: $e');
    }
  }

  Future<HarvestTransaction> prepareHarvestTransaction(HarvestRequest request) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/farm/prepare'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return HarvestTransaction.fromJson(data);
      } else {
        throw Exception('Failed to prepare harvest: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API Error: $e');
    }
  }

  Future<void> linkWallet(String playerId, String walletAddress) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/players/$playerId/link-wallet'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'walletAddress': walletAddress,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to link wallet: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API Error: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}
