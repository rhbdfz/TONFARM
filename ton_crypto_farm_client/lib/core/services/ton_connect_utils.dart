

/// Utility class for TON Connect operations
class TonConnectUtils {
  // TON Connect constants
  static const String mainnetEndpoint = 'https://toncenter.com/api/v2/jsonRPC';
  static const String testnetEndpoint = 'https://testnet.toncenter.com/api/v2/jsonRPC';
  
  // Common TON addresses
  static const String tonCoinAddress = 'EQD4FPq-PRDieyQKkizFTRtSDyucUIqrj0v_zXJmqaDp6_0t';
  
  // Transaction constants
  static const int defaultGasLimit = 10000000; // 0.01 TON
  static const int defaultTimeout = 300; // 5 minutes
  
  /// Convert TON amount to nano TON (1 TON = 1,000,000,000 nano TON)
  static String tonToNano(String tonAmount) {
    try {
      final amount = double.parse(tonAmount);
      final nanoAmount = (amount * 1000000000).toInt();
      return nanoAmount.toString();
    } catch (e) {
      throw ArgumentError('Invalid TON amount: $tonAmount');
    }
  }
  
  /// Convert nano TON to TON
  static String nanoToTon(String nanoAmount) {
    try {
      final nano = BigInt.parse(nanoAmount);
      final ton = nano / BigInt.from(1000000000);
      final remainder = nano % BigInt.from(1000000000);
      final remainderStr = remainder.toString().padLeft(9, '0');
      return '$ton.$remainderStr';
    } catch (e) {
      throw ArgumentError('Invalid nano TON amount: $nanoAmount');
    }
  }
  
  /// Format address for display (show first 6 and last 4 characters)
  static String formatAddress(String address) {
    if (address.length < 10) return address;
    final start = address.substring(0, 6);
    final end = address.substring(address.length - 4);
    return '$start...$end';
  }
  
  /// Validate TON address format
  static bool isValidAddress(String address) {
    // Basic TON address validation
    return address.startsWith('EQ') && address.length == 48;
  }
  
    /// Create a simple transaction message
  static dynamic createMessage({
    required String address,
    required String amount,
    String? payload,
    String? stateInit,
  }) {
    // Note: This should be updated with the actual darttonconnect API
    // For now, return a map with the required fields
    return {
      'address': address,
      'amount': amount,
      'payload': payload,
      'stateInit': stateInit,
    };
  }

  /// Create a transaction request with default settings
  static dynamic createTransactionRequest({
    required List<dynamic> messages,
    int? validUntil,
  }) {
    // Note: This should be updated with the actual darttonconnect API
    // For now, return a map with the required fields
    return {
      'validUntil': validUntil ?? 
        DateTime.now().add(const Duration(minutes: 5)).millisecondsSinceEpoch,
      'messages': messages,
    };
  }
  
    /// Get wallet display name
  static String getWalletDisplayName(dynamic wallet) {
    return wallet.name?.isNotEmpty == true ? wallet.name : 'Unknown Wallet';
  }

  /// Check if wallet supports a specific feature
  static bool walletSupportsFeature(dynamic wallet, String feature) {
    return wallet.features?.contains(feature) ?? false;
  }

  /// Get supported features for a wallet
  static List<String> getWalletFeatures(dynamic wallet) {
    return wallet.features ?? [];
  }
  
  /// Create a comment payload for transactions
  static String createCommentPayload(String comment) {
    // Convert comment to hex format for TON transactions
    final bytes = comment.codeUnits;
    final hex = bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    return '0x$hex';
  }
  
  /// Parse comment from transaction payload
  static String? parseCommentFromPayload(String payload) {
    try {
      if (payload.startsWith('0x')) {
        final hex = payload.substring(2);
        final bytes = <int>[];
        for (int i = 0; i < hex.length; i += 2) {
          bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
        }
        return String.fromCharCodes(bytes);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
} 