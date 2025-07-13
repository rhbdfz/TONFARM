import 'package:darttonconnect_plus/darttonconnect_plus.dart';

class TonConnectService {
  static final TonConnectService _instance = TonConnectService._internal();
  factory TonConnectService() => _instance;
  TonConnectService._internal();

  late TonConnect _tonConnect;
  bool _isInitialized = false;

  String? get walletAddress => _tonConnect.wallet?.account.address;
  bool get isConnected => _tonConnect.wallet != null;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _tonConnect = TonConnect(manifestUrl: 'https://your-app.com/tonconnect-manifest.json');
      await _tonConnect.restoreConnection();
      _isInitialized = true;
    } catch (e) {
      print('TonConnect initialization error: $e');
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
      print('Wallet connection error: $e');
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      await _tonConnect.disconnect();
    } catch (e) {
      print('Wallet disconnection error: $e');
    }
  }

  Future<String?> sendTransaction(String contractAddress, String message) async {
    try {
      final transaction = {
        'validUntil': DateTime.now().add(const Duration(minutes: 5)).millisecondsSinceEpoch,
        'messages': [
          {
            'address': contractAddress,
            'amount': '0',
            'payload': message,
          }
        ]
      };
      
      final result = await _tonConnect.sendTransaction(transaction);
      return result?.toString();
    } catch (e) {
      print('Transaction error: $e');
      return null;
    }
  }

  Future<BigInt> getBalance(String address) async {
    try {
      await initialize();
      final balance = await _tonConnect.getBalance(address);
      return BigInt.parse(balance);
    } catch (e) {
      print('Balance error: $e');
      return BigInt.zero;
    }
  }

  Future<dynamic> callContract(String address, String method, List<dynamic> params) async {
    try {
      await initialize();
      return await _tonConnect.runGetMethod(address: address, method: method, params: params);
    } catch (e) {
      print('Contract call error: $e');
      return null;
    }
  }
} 