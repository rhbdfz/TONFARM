import 'package:darttonconnect/ton_connect.dart';

import 'package:ton_dart/ton_dart.dart';

class TonService {
  static late TonConnector _tonConnect;
  static late TonProvider _tonProvider;

  static Future<void> init() async {
    try {
      _tonConnect = TonConnector(
        'https://your-app.com/tonconnect-manifest.json',
      );

      _tonProvider = TonProvider(
        HTTPProvider(
          tonApiUrl: "https://tonapi.io",
          tonCenterUrl: "https://toncenter.com/api/v2/jsonRPC",
        ),
      );
    } catch (e) {
      print('TON Service initialization error: $e');
    }
  }

  Future<WalletConnectionResult?> connectWallet() async {
    try {
      final wallets = await _tonConnect.getWallets();
      if (wallets.isNotEmpty) {
        return await _tonConnect.connect(wallets.first);
      }
      return null;
    } catch (e) {
      print('Wallet connection error: $e');
      return null;
    }
  }

  Future<String?> sendTransaction(Map<String, dynamic> transaction) async {
    try {
      final result = await _tonConnect.sendTransaction(transaction);
      return result;
    } catch (e) {
      print('Transaction error: $e');
      return null;
    }
  }

  Future<BigInt> getBalance(String address) async {
    try {
      final balance = await _tonProvider.request(
        TonCenterGetAddressBalance(address),
      );
      return balance;
    } catch (e) {
      print('Balance error: $e');
      return BigInt.zero;
    }
  }

  Future<dynamic> callContract(
      String address,
      String method,
      List<dynamic> params,
      ) async {
    try {
      return await _tonProvider.request(
        TonCenterRunGetMethod(address, method, params),
      );
    } catch (e) {
      print('Contract call error: $e');
      return null;
    }
  }

  Future<BigInt> getJettonBalance(String playerAddress, String jettonMaster) async {
    try {
      final walletAddress = await _calculateJettonWalletAddress(
        playerAddress,
        jettonMaster,
      );

      final result = await _tonProvider.request(
        TonCenterRunGetMethod(walletAddress, 'get_wallet_data', []),
      );

      if (result != null && result.stack.isNotEmpty) {
        return result.stack.first.readBigNumber();
      }
      return BigInt.zero;
    } catch (e) {
      print('Jetton balance error: $e');
      return BigInt.zero;
    }
  }

  Future<String> _calculateJettonWalletAddress(
      String ownerAddress,
      String jettonMaster,
      ) async {
    // Реализация расчета адреса Jetton кошелька
    final ownerAddr = TonAddress(ownerAddress);
    final masterAddr = TonAddress(jettonMaster);

    // Здесь должна быть логика расчета адреса кошелька
    // Для упрощения возвращаем ownerAddress
    return ownerAddress;
  }
}
