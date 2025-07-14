import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import '../core/services/api_service.dart';
import '../core/services/ton_connect_service.dart';
import '../core/services/telegram_service.dart';
import '../core/models/game_models.dart';

class GameProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  Player? _player;
  GameState? _gameState;
  bool _isLoading = false;
  String? _error;
  WebSocketChannel? _wsChannel;

  // Getters
  Player? get player => _player;
  GameState? get gameState => _gameState;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initializeGame() async {
    _setLoading(true);
    _clearError();

    try {
      final telegramUser = TelegramService.getCurrentUser();
      if (telegramUser == null) {
        throw Exception('Telegram user not found');
      }

      await registerPlayer(telegramUser['id'].toString(), telegramUser['username'] ?? 'Unknown');
      await _setupWebSocket();
    } catch (e) {
      _setError('Initialization error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> registerPlayer(String telegramId, String username) async {
    try {
      _player = await _apiService.registerPlayer(telegramId, username);
      await _loadGameState();
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  Future<void> _loadGameState() async {
    if (_player == null) return;

    try {
      _gameState = await _apiService.getGameState(_player!.id);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load game state: $e');
    }
  }

  Future<void> connectWallet() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await TonConnectService().connectWallet();
      if (result && _player != null) {
        final walletAddress = TonConnectService().walletAddress;
        if (walletAddress != null) {
          await _apiService.linkWallet(_player!.id, walletAddress);
          _player = Player(
            id: _player!.id,
            telegramId: _player!.telegramId,
            username: _player!.username,
            walletAddress: walletAddress,
            createdAt: _player!.createdAt,
          );
          notifyListeners();
        }
      }
    } catch (e) {
      _setError('Wallet connection failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> craftTool(ToolType toolType, int level) async {
    if (_player == null || _gameState == null) return;

    _setLoading(true);
    _clearError();

    try {
      final craftRequest = CraftRequest(
        playerId: _player!.id,
        toolType: toolType,
        level: level,
        playerAddress: _player!.walletAddress ?? '',
      );

      final craftTransaction = await _apiService.prepareCraftTransaction(craftRequest);

      final txResult = await TonConnectService().sendTransaction(
        craftTransaction.contractAddress,
        craftTransaction.message['data'],
      );

      if (txResult != null) {
        await _loadGameState();
        TelegramService.showAlert('Tool crafted successfully!');
      } else {
        throw Exception('Transaction failed');
      }
    } catch (e) {
      _setError('Craft failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> harvestResources(String toolId, String? landId) async {
    if (_player == null || _gameState == null) return;

    _setLoading(true);
    _clearError();

    try {
      final harvestRequest = HarvestRequest(
        playerId: _player!.id,
        toolId: toolId,
        landId: landId,
        playerAddress: _player!.walletAddress ?? '',
      );

      final harvestTransaction = await _apiService.prepareHarvestTransaction(harvestRequest);

      final txResult = await TonConnectService().sendTransaction(
        harvestTransaction.contractAddress,
        harvestTransaction.message['data'],
      );

      if (txResult != null) {
        await _loadGameState();
        TelegramService.showAlert('Resources harvested!');
      } else {
        throw Exception('Transaction failed');
      }
    } catch (e) {
      _setError('Harvest failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _setupWebSocket() async {
    if (_player == null) return;

    try {
      _wsChannel = WebSocketChannel.connect(
        Uri.parse('ws://localhost:8080/ws/${_player!.id}'),
      );

      _wsChannel!.stream.listen(
            (data) {
          try {
            final update = GameUpdate.fromJson(jsonDecode(data));
            _handleGameUpdate(update);
          } catch (e) {
            debugPrint('WebSocket parse error: $e');
          }
        },
        onError: (error) {
          debugPrint('WebSocket error: $error');
        },
        onDone: () {
          debugPrint('WebSocket connection closed');
        },
      );
    } catch (e) {
      debugPrint('WebSocket setup error: $e');
    }
  }

  void _handleGameUpdate(GameUpdate update) {
    switch (update.type) {
      case UpdateType.resourcesChanged:
        if (update.resources != null) {
          _gameState = _gameState?.copyWith(resources: update.resources);
          notifyListeners();
        }
        break;
      case UpdateType.energyChanged:
        if (update.energy != null) {
          _gameState = _gameState?.copyWith(energy: update.energy);
          notifyListeners();
        }
        break;
      case UpdateType.toolReceived:
        if (update.tool != null && _gameState != null) {
          final newTools = [..._gameState!.tools, update.tool!];
          _gameState = _gameState?.copyWith(tools: newTools);
          notifyListeners();
        }
        break;
      case UpdateType.transactionConfirmed:
        _loadGameState();
        break;
      case UpdateType.error:
        if (update.message != null) {
          _setError(update.message!);
        }
        break;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _wsChannel?.sink.close();
    _apiService.dispose();
    super.dispose();
  }
}
