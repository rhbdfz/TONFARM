import 'package:ton_dart/ton_dart.dart';

class TonService {
  static late TonProvider _provider;
  static const String _tonCenterUrl = 'https://toncenter.com/api/v2/jsonRPC';

  // Адреса контрактов (заглушки)
  static const String craftingContractAddress = 'EQCraftingContract...';
  static const String farmingContractAddress = 'EQFarmingContract...';
  static const String energyContractAddress = 'EQEnergyContract...';
  static const String foodJettonAddress = 'EQFoodToken...';
  static const String woodJettonAddress = 'EQWoodToken...';
  static const String goldJettonAddress = 'EQGoldToken...';

  static Future<void> init() async {
    try {
      _provider = TonProvider(TonApiProvider(apiUrl: _tonCenterUrl));
      print('TON Service initialized successfully');
    } catch (e) {
      print('TON Service initialization error: $e');
      rethrow;
    }
  }

  static Future<BigInt> getJettonBalance(
      String playerAddress,
      String jettonMaster,
      ) async {
    try {
      final walletAddress = await _calculateJettonWalletAddress(
        playerAddress,
        jettonMaster,
      );

      final result = await _provider.request(
        TonCenterRunGetMethod(
          address: walletAddress,
          methodName: 'get_wallet_data',
          stack: [],
        ),
      );

      if (result.stack.isNotEmpty) {
        return BigInt.parse(result.stack.first.toString());
      }
      return BigInt.zero;
    } catch (e) {
      print('Error getting jetton balance: $e');
      return BigInt.zero;
    }
  }

  static Future<int> getPlayerEnergy(String playerAddress) async {
    try {
      final result = await _provider.request(
        TonCenterRunGetMethod(
          address: energyContractAddress,
          methodName: 'get_energy',
          stack: [playerAddress],
        ),
      );

      if (result.stack.isNotEmpty) {
        return int.parse(result.stack.first.toString());
      }
      return 100; // Начальная энергия
    } catch (e) {
      print('Error getting player energy: $e');
      return 100;
    }
  }

  static Future<Map<String, dynamic>> createCraftMessage(
      String playerAddress,
      int toolType,
      int level,
      Map<String, int> recipe,
      ) async {
    try {
      // Создание данных для крафта
      final craftData = beginCell()
          .storeUint(toolType, 8)
          .storeUint(level, 8)
          .storeCoins(BigInt.from(recipe['food']!))
          .storeCoins(BigInt.from(recipe['wood']!))
          .storeCoins(BigInt.from(recipe['gold']!))
          .endCell();

      // Создание основного сообщения
      final message = beginCell()
          .storeUint(0xCAFEBABE, 32) // op code для крафта
          .storeUint(DateTime.now().millisecondsSinceEpoch, 64) // query_id
          .storeAddress(TonAddress(playerAddress))
          .storeRef(craftData)
          .endCell();

      return {
        'to': craftingContractAddress,
        'value': '50000000', // 0.05 TON
        'data': message.toBoc(),
      };
    } catch (e) {
      throw Exception('Failed to create craft message: $e');
    }
  }

  static Future<Map<String, dynamic>> createFarmMessage(
      String playerAddress,
      int toolType,
      int toolLevel,
      int? landLevel,
      ) async {
    try {
      // Создание данных для фарма
      final farmData = beginCell()
          .storeUint(toolType, 8)
          .storeUint(toolLevel, 8)
          .storeUint(landLevel ?? 0, 8)
          .endCell();

      // Создание основного сообщения
      final message = beginCell()
          .storeUint(0xDEADBEEF, 32) // op code для фарма
          .storeUint(DateTime.now().millisecondsSinceEpoch, 64) // query_id
          .storeAddress(TonAddress(playerAddress))
          .storeRef(farmData)
          .endCell();

      return {
        'to': farmingContractAddress,
        'value': '50000000', // 0.05 TON
        'data': message.toBoc(),
      };
    } catch (e) {
      throw Exception('Failed to create farm message: $e');
    }
  }

  static Future<String> _calculateJettonWalletAddress(
      String ownerAddress,
      String jettonMaster,
      ) async {
    // Упрощенная реализация - в реальности нужен правильный расчет
    return ownerAddress;
  }

  static String getJettonAddress(String tokenType) {
    switch (tokenType) {
      case 'food':
        return foodJettonAddress;
      case 'wood':
        return woodJettonAddress;
      case 'gold':
        return goldJettonAddress;
      default:
        throw Exception('Unknown token type: $tokenType');
    }
  }
}
