import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:dotenv/dotenv.dart';
import 'package:ton_crypto_farm_server/controllers/game_controller.dart';
import 'package:ton_crypto_farm_server/controllers/player_controller.dart';
import 'package:ton_crypto_farm_server/services/firebase_service.dart';
import 'package:ton_crypto_farm_server/services/ton_service.dart';
import 'package:ton_crypto_farm_server/services/websocket_service.dart';
import 'package:ton_crypto_farm_server/middleware/auth_middleware.dart';

void main() async {
  // Загрузка переменных окружения
  final env = DotEnv()..load();

  // Инициализация сервисов
  await FirebaseService.init();
  await TonService.init();

  // Создание контроллеров
  final playerController = PlayerController();
  final gameController = GameController();

  // Создание роутера
  final router = Router();

  // Маршруты для игроков
  router.post('/api/players/register', playerController.register);
  router.get('/api/players/<playerId>/state', playerController.getState);
  router.post('/api/players/<playerId>/link-wallet', playerController.linkWallet);

  // Маршруты для игры
  router.post('/api/craft/prepare', gameController.prepareCraft);
  router.post('/api/farm/prepare', gameController.prepareFarm);
  router.get('/api/balance/<address>/<token>', gameController.getBalance);

  // WebSocket для реального времени
  router.get('/ws/<playerId>', webSocketHandler((webSocket, request) {
    final params = request.params;
    final playerId = params?['playerId'] ?? '';
    WebSocketService.handleConnection(webSocket, playerId);
  }));

  // Middleware
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(authMiddleware)
      .addHandler(router.call);

  // Запуск сервера
  final port = int.parse(env['PORT'] ?? '8080');
  final server = await io.serve(handler, 'localhost', port);

  print('Server running on http://localhost:$port');

  // Graceful shutdown
  ProcessSignal.sigint.watch().listen((_) async {
    print('\nShutting down server...');
    await server.close();
    exit(0);
  });
}
