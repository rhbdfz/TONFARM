import 'package:flutter_telegram_miniapp/flutter_telegram_miniapp.dart';



class TelegramService {
  static WebApp? _webApp;

  static Future<void> init() async {
    try {
      _webApp = WebApp();
      _webApp!.init();
      _setupUI();
    } catch (e) {
      print('Telegram initialization error: $e');
    }
  }

  static TelegramUser? getCurrentUser() {
    try {
      return _webApp?.initDataUnsafe.user;
    } catch (e) {
      print('Get user error: $e');
      return null;
    }
  }

  static void _setupUI() {
    if (_webApp == null) return;

    try {
      _webApp!.setHeaderColor('#4CAF50');
      _webApp!.enableClosingConfirmation();
      _webApp!.expand();
    } catch (e) {
      print('UI setup error: $e');
    }
  }

  static void showMainButton(String text, Function() onPressed) {
    if (_webApp == null) return;

    try {
      _webApp!.showMainButton(text: text);
      _webApp!.eventHandler.mainButtonClicked.listen((_) => onPressed());
    } catch (e) {
      print('Main button error: $e');
    }
  }

  static void hideMainButton() {
    if (_webApp == null) return;

    try {
      _webApp!.hideMainButton();
    } catch (e) {
      print('Hide button error: $e');
    }
  }

  static void showAlert(String message) {
    if (_webApp == null) return;

    try {
      _webApp!.showAlert(message);
    } catch (e) {
      print('Show alert error: $e');
    }
  }

  static void close() {
    if (_webApp == null) return;

    try {
      _webApp!.close();
    } catch (e) {
      print('Close error: $e');
    }
  }
}
