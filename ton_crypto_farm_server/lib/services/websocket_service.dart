import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  static final Map<String, WebSocketSink> _connections = {};
  static final Map<String, Timer> _heartbeats = {};

  static void handleConnection(WebSocketSink webSocket, String playerId) {
    print('WebSocket connection established for player: $playerId');

    _connections[playerId] = webSocket;
    _setupHeartbeat(playerId);

    // Отправляем приветственное сообщение
    sendToPlayer(playerId, {
      'type': 'connected',
      'playerId': playerId,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Настройка обработки закрытия соединения
    webSocket.done.then((_) {
      _removeConnection(playerId);
    }).catchError((error) {
      print('WebSocket error for player $playerId: $error');
      _removeConnection(playerId);
    });
  }

  static void sendToPlayer(String playerId, Map<String, dynamic> message) {
    final connection = _connections[playerId];
    if (connection != null) {
      try {
        connection.add(jsonEncode(message));
      } catch (e) {
        print('Error sending message to player $playerId: $e');
        _removeConnection(playerId);
      }
    }
  }

  static void broadcastToAll(Map<String, dynamic> message) {
    final messageJson = jsonEncode(message);
    for (final entry in _connections.entries) {
      try {
        entry.value.add(messageJson);
      } catch (e) {
        print('Error broadcasting to player ${entry.key}: $e');
        _removeConnection(entry.key);
      }
    }
  }

  static void notifyGameStateUpdate(String playerId, Map<String, dynamic> gameState) {
    sendToPlayer(playerId, {
      'type': 'game_state_update',
      'data': gameState,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static void notifyResourceUpdate(String playerId, Map<String, int> resources) {
    sendToPlayer(playerId, {
      'type': 'resources_changed',
      'resources': resources,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static void notifyEnergyUpdate(String playerId, int energy) {
    sendToPlayer(playerId, {
      'type': 'energy_changed',
      'energy': energy,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static void notifyTransactionConfirmed(String playerId, String transactionHash) {
    sendToPlayer(playerId, {
      'type': 'transaction_confirmed',
      'transactionHash': transactionHash,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static void notifyError(String playerId, String error) {
    sendToPlayer(playerId, {
      'type': 'error',
      'message': error,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static void _setupHeartbeat(String playerId) {
    _heartbeats[playerId] = Timer.periodic(
      const Duration(seconds: 30),
          (timer) {
        sendToPlayer(playerId, {
          'type': 'ping',
          'timestamp': DateTime.now().toIso8601String(),
        });
      },
    );
  }

  static void _removeConnection(String playerId) {
    print('Removing WebSocket connection for player: $playerId');

    _connections.remove(playerId);
    _heartbeats[playerId]?.cancel();
    _heartbeats.remove(playerId);
  }

  static int get activeConnections => _connections.length;

  static List<String> get connectedPlayers => _connections.keys.toList();
}
