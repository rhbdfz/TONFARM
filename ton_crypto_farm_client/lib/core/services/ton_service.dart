
import 'package:darttonconnect/ton_connect.dart';

import 'package:ton_dart/ton_dart.dart';

class TonService {
  static late TonConnect _tonConnect;
  static late TonProvider _tonProvider;

  static Future<void> init() async {
    try {
      _tonConnect = TonConnect('https://your-app.com/tonconnect-manifest.json');

      _tonProvider = TonProvider(
        TonCenterProvider(
          apiUrl: "https://toncenter.com/api/v2/jsonRPC",
        ),
      );
    } catch (e) {
      print('TON Service initialization error: $e');
    }
  }

  Future<dynamic> connectWallet() async {
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
        TonCenterRunGetMethod(address: address, methodName: method, stack: params),
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
        TonCenterRunGetMethod(address: walletAddress, methodName: 'get_wallet_data', stack: []),
      );

      if (result != null && result.stack.isNotEmpty) {
        // Convert the first stack item to BigInt
        final firstItem = result.stack.first;
        if (firstItem is String) {
          return BigInt.parse(firstItem);
        } else if (firstItem is int) {
          return BigInt.from(firstItem);
        }
        return BigInt.zero;
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
    // Implementation for calculating Jetton wallet address
    // For simplification, returning ownerAddress
    return ownerAddress;
  }
}
