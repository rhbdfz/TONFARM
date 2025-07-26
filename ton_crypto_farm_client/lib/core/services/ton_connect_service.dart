import 'package:darttonconnect/ton_connect.dart';
import 'package:darttonconnect/exceptions.dart';
import 'package:darttonconnect/logger.dart';
import 'package:flutter/foundation.dart';

class TonConnectService {
  static final TonConnectService _instance = TonConnectService._internal();
  factory TonConnectService() => _instance;
  TonConnectService._internal();

  late TonConnect _tonConnect;
  bool _isInitialized = false;

  String? get walletAddress => _tonConnect.account?.address;
  bool get isConnected => _tonConnect.account != null;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      _tonConnect = TonConnect('https://your-app.com/tonconnect-manifest.json');
      await _tonConnect.restoreConnection();
      _isInitialized = true;
    } catch (e) {
      debugPrint('TonConnect initialization error: $e');
    }
  }

  Future<bool> connectWallet() async {
    try {
      await initialize();
      final wallets = await _tonConnect.getWallets();
      if (wallets.isNotEmpty) {
        await _tonConnect.connect(wallets.first);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Wallet connection error: $e');
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      await _tonConnect.disconnect();
    } catch (e) {
      debugPrint('Wallet disconnection error: $e');
    }
  }

  Future<String?> sendTransaction(String contractAddress, String message) async {
    try {
      final transaction = TonConnectSendTransactionRequest(
        validUntil: DateTime.now().add(const Duration(minutes: 5)).millisecondsSinceEpoch,
        messages: [
          TonConnectSendTransactionMessage(
            address: contractAddress,
            amount: '0',
            payload: message,
          ),
        ],
      );
      final result = await _tonConnect.sendTransaction(transaction);
      return result?.toString();
    } catch (e) {
      debugPrint('Transaction error: $e');
      return null;
    }
  }

  // The following methods are placeholders, as the SDK may not provide them directly
  Future<BigInt> getBalance(String address) async {
    try {
      await initialize();
      // Use a separate TON API for balance if needed
      return BigInt.zero;
    } catch (e) {
      debugPrint('Balance error: $e');
      return BigInt.zero;
    }
  }

  Future<dynamic> callContract(String address, String method, List<dynamic> params) async {
    try {
      await initialize();
      // Use a separate TON API for contract calls if needed
      return null;
    } catch (e) {
      debugPrint('Contract call error: $e');
      return null;
    }
  }
} 