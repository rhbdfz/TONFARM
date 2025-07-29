import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ton_crypto_farm/components/wallet_connect_widget.dart';
import 'core/services/api_service.dart';
import 'core/services/telegram_service.dart';
import 'providers/game_provider.dart';

import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация Telegram Mini App
  await TelegramService.init();

  runApp(const TONFarmApp());
}

class TONFarmApp extends StatelessWidget {
  const TONFarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
        Provider(create: (_) => ApiService()),
      ],
      child: MaterialApp(
        title: 'TON Farm',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const WalletConnectWidget(), //InitializationScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
