import 'package:shelf/shelf.dart';

Middleware get authMiddleware {
  return (Handler innerHandler) {
    return (Request request) async {
      // Пропускаем OPTIONS запросы для CORS
      if (request.method == 'OPTIONS') {
        return await innerHandler(request);
      }

      // Пропускаем публичные эндпоинты
      final publicPaths = [
        '/api/players/register',
        '/ws/',
      ];

      final isPublicPath = publicPaths.any(
            (path) => request.url.path.startsWith(path),
      );

      if (isPublicPath) {
        return await innerHandler(request);
      }

      // Здесь можно добавить проверку авторизации
      // Например, проверка JWT токена или других механизмов

      return await innerHandler(request);
    };
  };
}
