import 'package:darttonconnect/ton_connect.dart';
import 'package:darttonconnect/exceptions.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:async' show Timer;
import 'ton_connect_utils.dart';

class TonConnectService {
  static final TonConnectService _instance = TonConnectService._internal();
  factory TonConnectService() => _instance;
  TonConnectService._internal();

  late TonConnect _tonConnect;
  bool _isInitialized = false;
  Timer? _connectionCheckTimer;

  // Getters
  String? get walletAddress => _tonConnect.account?.address;
  bool get isConnected => _tonConnect.account != null;
  bool get isInitialized => _isInitialized;
  TonConnect get tonConnect => _tonConnect;

  // Event streams for UI updates
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();
  final StreamController<String?> _walletAddressController = StreamController<String?>.broadcast();
  final StreamController<String> _errorController = StreamController<String>.broadcast();

  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;
  Stream<String?> get walletAddressStream => _walletAddressController.stream;
  Stream<String> get errorStream => _errorController.stream;

  /// Initialize TON Connect with proper manifest URL
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Use the correct manifest URL - should point to your actual domain
      const manifestUrl = 'https://your-app.com/tonconnect-manifest.json';
      
      _tonConnect = TonConnect(manifestUrl);
      
      // Set up event listeners
      _setupEventListeners();
      
      // Restore connection if previously connected
      await _tonConnect.restoreConnection();
      
      _isInitialized = true;
      debugPrint('TON Connect initialized successfully');
    } catch (e) {
      debugPrint('TON Connect initialization error: $e');
      _errorController.add('Failed to initialize TON Connect: $e');
      rethrow;
    }
  }

  /// Set up event listeners for connection status and wallet info
  void _setupEventListeners() {
    // Note: The actual darttonconnect API may have different stream names
    // This is a simplified implementation that should be updated based on the actual API
    
    // For now, we'll set up a periodic check for connection status
    _connectionCheckTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_isInitialized) {
        final isConnected = _tonConnect.account != null;
        _connectionStatusController.add(isConnected);
        
        if (isConnected) {
          _walletAddressController.add(_tonConnect.account?.address);
        } else {
          _walletAddressController.add(null);
        }
      }
    });
  }

  /// Get available wallets
  Future<List<dynamic>> getAvailableWallets() async {
    try {
      await initialize();
      final wallets = await _tonConnect.getWallets();
      debugPrint('Available wallets: ${wallets.length}');
      
      // Log wallet information for debugging
      for (final wallet in wallets) {
        debugPrint('Wallet: ${TonConnectUtils.getWalletDisplayName(wallet)}');
        debugPrint('Features: ${TonConnectUtils.getWalletFeatures(wallet)}');
      }
      
      return wallets;
    } catch (e) {
      debugPrint('Error getting wallets: $e');
      _errorController.add('Failed to get wallets: $e');
      return [];
    }
  }

  /// Connect to a specific wallet
  Future<bool> connectWallet([dynamic? wallet]) async {
    try {
      await initialize();
      
      List<Wallet> wallets;
      if (wallet != null) {
        wallets = [wallet];
      } else {
        wallets = await _tonConnect.getWallets();
      }
      
      if (wallets.isEmpty) {
        debugPrint('No wallets available');
        _errorController.add('No wallets available');
        return false;
      }

      // Connect to the first available wallet or specified wallet
      final targetWallet = wallet ?? wallets.first;
      await _tonConnect.connect(targetWallet);
      
      debugPrint('Connected to wallet: ${TonConnectUtils.getWalletDisplayName(targetWallet)}');
      return true;
    } catch (e) {
      debugPrint('Wallet connection error: $e');
      _errorController.add('Failed to connect wallet: $e');
      return false;
    }
  }

  /// Disconnect from wallet
  Future<void> disconnect() async {
    try {
      await _tonConnect.disconnect();
      debugPrint('Disconnected from wallet');
    } catch (e) {
      debugPrint('Wallet disconnection error: $e');
      _errorController.add('Failed to disconnect: $e');
    }
  }

  /// Send a transaction
  Future<String?> sendTransaction({
    required String contractAddress,
    required String amount,
    String? payload,
    String? stateInit,
  }) async {
    try {
      if (!isConnected) {
        throw Exception('Wallet not connected');
      }

      // Validate address format
      if (!TonConnectUtils.isValidAddress(contractAddress)) {
        throw ArgumentError('Invalid contract address: $contractAddress');
      }

      final message = TonConnectUtils.createMessage(
        address: contractAddress,
        amount: amount,
        payload: payload,
        stateInit: stateInit,
      );

      final transaction = TonConnectUtils.createTransactionRequest(
        messages: [message],
      );

      final result = await _tonConnect.sendTransaction(transaction);
      debugPrint('Transaction sent successfully: ${result?.toString()}');
      return result?.toString();
    } catch (e) {
      debugPrint('Transaction error: $e');
      _errorController.add('Transaction failed: $e');
      return null;
    }
  }

  /// Send multiple transactions in a batch
  Future<String?> sendBatchTransaction({
    required List<dynamic> messages,
  }) async {
    try {
      if (!isConnected) {
        throw Exception('Wallet not connected');
      }

      // Validate all addresses
      for (final message in messages) {
        if (!TonConnectUtils.isValidAddress(message.address)) {
          throw ArgumentError('Invalid address in batch: ${message.address}');
        }
      }

      final transaction = TonConnectUtils.createTransactionRequest(
        messages: messages,
      );

      final result = await _tonConnect.sendTransaction(transaction);
      debugPrint('Batch transaction sent successfully: ${result?.toString()}');
      return result?.toString();
    } catch (e) {
      debugPrint('Batch transaction error: $e');
      _errorController.add('Batch transaction failed: $e');
      return null;
    }
  }

  /// Get account balance using TON API
  Future<BigInt> getBalance(String address) async {
    try {
      // This would typically use a TON API service
      // For now, return zero as placeholder
      debugPrint('Getting balance for address: $address');
      return BigInt.zero;
    } catch (e) {
      debugPrint('Balance error: $e');
      _errorController.add('Failed to get balance: $e');
      return BigInt.zero;
    }
  }

  /// Call a smart contract method
  Future<dynamic> callContract({
    required String address,
    required String method,
    List<dynamic> params = const [],
  }) async {
    try {
      if (!isConnected) {
        throw Exception('Wallet not connected');
      }

      // This would typically use a TON API service for contract calls
      debugPrint('Calling contract method: $method on address: $address');
      return null;
    } catch (e) {
      debugPrint('Contract call error: $e');
      _errorController.add('Contract call failed: $e');
      return null;
    }
  }

  /// Get current account information
  dynamic getCurrentAccount() {
    return _tonConnect.account;
  }

  /// Check if wallet supports a specific feature
  bool supportsFeature(String feature) {
    try {
      // Note: This method may need to be updated based on the actual darttonconnect API
      // For now, we'll return false as a safe default
      debugPrint('Feature check not implemented in current version');
      return false;
    } catch (e) {
      debugPrint('Feature check error: $e');
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    _connectionCheckTimer?.cancel();
    _connectionStatusController.close();
    _walletAddressController.close();
    _errorController.close();
    _isInitialized = false;
  }
} 