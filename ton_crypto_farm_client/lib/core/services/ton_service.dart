
import 'package:darttonconnect_plus/darttonconnect_plus.dart';

class TonService {
  static late TonConnectManager _tonConnectManager;

  static Future<void> init() async {
    try {
      _tonConnectManager = TonConnectManager('https://your-app.com/tonconnect-manifest.json');

      // darttonconnect_plus handles provider internally if needed
    } catch (e) {
      print('TON Service initialization error: $e');
    }
  }

  Future<dynamic> connectWallet() async {
    try {
      final wallets = await _tonConnectManager.getWallets();
      if (wallets != null && wallets.isNotEmpty) {
        return await _tonConnectManager.connect(wallets.first);
      }
      return null;
    } catch (e) {
      print('Wallet connection error: $e');
      return null;
    }
  }

  Future<String?> sendTransaction(Map<String, dynamic> transaction) async {
    try {
      final result = await _tonConnectManager.sendTransaction(transaction);
      return result?.toString();
    } catch (e) {
      print('Transaction error: $e');
      return null;
    }
  }

  Future<BigInt> getBalance(String address) async {
    try {
      final balance = await _tonConnectManager.getBalance(address);
      return BigInt.parse(balance);
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
      return await _tonConnectManager.runGetMethod(address: address, method: method, params: params);
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
      final result = await _tonConnectManager.runGetMethod(address: walletAddress, method: 'get_wallet_data', params: []);
      if (result != null && result.isNotEmpty) {
        final firstItem = result[0];
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
