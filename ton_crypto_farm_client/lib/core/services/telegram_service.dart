import 'package:flutter_telegram_miniapp/flutter_telegram_miniapp.dart';
import 'dart:convert';

class TelegramService {

  static final TelegramMiniApp _tg = TelegramMiniApp.instance;

  static Future<void> init() async {
    try {
      if (_tg.isSupported) {
        _tg.ready();
        Future.delayed(const Duration(seconds: 1), _tg.expand);
        _setupUI();
      }
    } catch (e) {
      print('Telegram initialization error: $e');
    }
  }

  /// Returns a map with user info or null if not available
  static Map<String, dynamic>? getCurrentUser() {
    try {
      final unsafe = _tg.initDataUnsafe;
      if (unsafe != null && unsafe['user'] != null) {
        return Map<String, dynamic>.from(unsafe['user']);
      }
      return null;
    } catch (e) {
      print('Get user error: $e');
      return null;
    }
  }

  static void _setupUI() {
    try {
      _tg.setHeaderColor('#4CAF50');
      _tg.enableClosingConfirmation();
      _tg.expand();
    } catch (e) {
      print('UI setup error: $e');
    }
  }

  static void showMainButton(String text, Function() onPressed) {
    try {
      _tg.MainButton.text = text;
      _tg.MainButton.show();
      _tg.onEvent('mainButtonClicked', (_) => onPressed());
    } catch (e) {
      print('Main button error: $e');
    }
  }

  static void hideMainButton() {
    try {
      _tg.MainButton.hide();
    } catch (e) {
      print('Hide button error: $e');
    }
  }

  static void showAlert(String message) {
    try {
      _tg.showAlert(message);
    } catch (e) {
      print('Show alert error: $e');
    }
  }

  static void close() {
    try {
      _tg.close();
    } catch (e) {
      print('Close error: $e');
    }
  }
}
