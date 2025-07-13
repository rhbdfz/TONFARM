import 'package:darttonconnect_plus/darttonconnect_plus.dart';

class TonConnectService {
  static final TonConnectService _instance = TonConnectService._internal();
  factory TonConnectService() => _instance;
  TonConnectService._internal();

  late TonConnectManager _tonConnectManager;
  bool _isInitialized = false;

  String? get walletAddress => _tonConnectManager.connectedWalletInfo?.account?.address;
  bool get isConnected => _tonConnectManager.isConnected;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _tonConnectManager = TonConnectManager('https://your-app.com/tonconnect-manifest.json');
      await _tonConnectManager.connector.restoreConnection();
      _isInitialized = true;
    } catch (e) {
      print('TonConnect initialization error: $e');
    }
  }

  Future<bool> connectWallet() async {
    try {
      await initialize();
      final wallets = await _tonConnectManager.getWallets();
      if (wallets != null && wallets.isNotEmpty) {
        await _tonConnectManager.connect(wallets.first);
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
      await _tonConnectManager.disconnect();
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
      
      final result = await _tonConnectManager.sendTransaction(transaction);
      return result?.toString();
    } catch (e) {
      print('Transaction error: $e');
      return null;
    }
  }

  Future<BigInt> getBalance(String address) async {
    try {
      await initialize();
      final balance = await _tonConnectManager.getBalance(address);
      return BigInt.parse(balance);
    } catch (e) {
      print('Balance error: $e');
      return BigInt.zero;
    }
  }

  Future<dynamic> callContract(String address, String method, List<dynamic> params) async {
    try {
      await initialize();
      return await _tonConnectManager.runGetMethod(address: address, method: method, params: params);
    } catch (e) {
      print('Contract call error: $e');
      return null;
    }
  }
} 