# TON Connect Service Guide

This guide documents the improved TON Connect service implementation for the TON Farm application, following the best practices from the [TON Connect tutorial](https://dev.to/roma_i_m/how-to-authorize-the-ton-blockchain-on-dart-using-a-wallet-via-ton-connect-edo).

## Overview

The TON Connect service has been completely rewritten to provide:
- Proper error handling and validation
- Event-driven architecture with streams
- Utility functions for common operations
- Better connection management
- Comprehensive logging and debugging

## Files Structure

```
lib/core/services/
├── ton_connect_service.dart      # Main TON Connect service
├── ton_connect_utils.dart        # Utility functions
└── ...

lib/components/
└── wallet_connect_widget.dart    # Example UI widget

web/
└── tonconnect-manifest.json      # TON Connect manifest
```

## Key Improvements

### 1. Event-Driven Architecture

The service now provides streams for real-time updates:

```dart
// Listen to connection status changes
tonConnectService.connectionStatusStream.listen((isConnected) {
  print('Connection status: $isConnected');
});

// Listen to wallet address changes
tonConnectService.walletAddressStream.listen((address) {
  print('Wallet address: $address');
});

// Listen to errors
tonConnectService.errorStream.listen((error) {
  print('Error: $error');
});
```

### 2. Proper Error Handling

All methods now include comprehensive error handling:

```dart
try {
  final result = await tonConnectService.connectWallet();
  if (result) {
    print('Wallet connected successfully');
  } else {
    print('Failed to connect wallet');
  }
} catch (e) {
  print('Connection error: $e');
}
```

### 3. Utility Functions

The `TonConnectUtils` class provides helper functions:

```dart
// Convert TON to nano TON
String nanoAmount = TonConnectUtils.tonToNano('1.5');

// Format address for display
String formatted = TonConnectUtils.formatAddress('EQD4FPq-PRDieyQKkizFTRtSDyucUIqrj0v_zXJmqaDp6_0t');
// Result: "EQD4FP...p6_0t"

// Validate address
bool isValid = TonConnectUtils.isValidAddress(address);

// Create transaction message
final message = TonConnectUtils.createMessage(
  address: contractAddress,
  amount: '1000000000', // 1 TON in nano
  payload: '0x123456',
);
```

## Usage Examples

### Basic Wallet Connection

```dart
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final TonConnectService _tonConnect = TonConnectService();
  bool _isConnected = false;
  String? _walletAddress;

  @override
  void initState() {
    super.initState();
    _setupListeners();
    _initialize();
  }

  void _setupListeners() {
    _tonConnect.connectionStatusStream.listen((connected) {
      setState(() {
        _isConnected = connected;
      });
    });

    _tonConnect.walletAddressStream.listen((address) {
      setState(() {
        _walletAddress = address;
      });
    });
  }

  Future<void> _initialize() async {
    try {
      await _tonConnect.initialize();
      await _loadWallets();
    } catch (e) {
      print('Initialization error: $e');
    }
  }

  Future<void> _loadWallets() async {
    final wallets = await _tonConnect.getAvailableWallets();
    print('Available wallets: ${wallets.length}');
  }

  Future<void> _connectWallet() async {
    try {
      final result = await _tonConnect.connectWallet();
      if (result) {
        print('Wallet connected!');
      }
    } catch (e) {
      print('Connection failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Connected: $_isConnected'),
        if (_walletAddress != null)
          Text('Address: ${TonConnectUtils.formatAddress(_walletAddress!)}'),
        ElevatedButton(
          onPressed: _isConnected ? null : _connectWallet,
          child: Text(_isConnected ? 'Connected' : 'Connect Wallet'),
        ),
      ],
    );
  }
}
```

### Sending Transactions

```dart
Future<void> sendTransaction() async {
  try {
    // Send a simple transaction
    final result = await _tonConnect.sendTransaction(
      contractAddress: 'EQD4FPq-PRDieyQKkizFTRtSDyucUIqrj0v_zXJmqaDp6_0t',
      amount: TonConnectUtils.tonToNano('0.1'), // 0.1 TON
      payload: TonConnectUtils.createCommentPayload('Hello TON!'),
    );

    if (result != null) {
      print('Transaction sent: $result');
    } else {
      print('Transaction failed');
    }
  } catch (e) {
    print('Transaction error: $e');
  }
}

// Send batch transaction
Future<void> sendBatchTransaction() async {
  try {
    final messages = [
      TonConnectUtils.createMessage(
        address: 'EQD4FPq-PRDieyQKkizFTRtSDyucUIqrj0v_zXJmqaDp6_0t',
        amount: TonConnectUtils.tonToNano('0.1'),
        payload: TonConnectUtils.createCommentPayload('First message'),
      ),
      TonConnectUtils.createMessage(
        address: 'EQD4FPq-PRDieyQKkizFTRtSDyucUIqrj0v_zXJmqaDp6_0t',
        amount: TonConnectUtils.tonToNano('0.05'),
        payload: TonConnectUtils.createCommentPayload('Second message'),
      ),
    ];

    final result = await _tonConnect.sendBatchTransaction(messages: messages);
    print('Batch transaction result: $result');
  } catch (e) {
    print('Batch transaction error: $e');
  }
}
```

### Using the Wallet Connect Widget

```dart
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('TON Farm')),
      body: WalletConnectWidget(
        onWalletConnected: (address) {
          print('Wallet connected: $address');
          // Update your app state
        },
        onWalletDisconnected: () {
          print('Wallet disconnected');
          // Update your app state
        },
      ),
    );
  }
}
```

## Configuration

### TON Connect Manifest

Update the `web/tonconnect-manifest.json` file with your app's information:

```json
{
  "url": "https://your-app-domain.com",
  "name": "Your App Name",
  "iconUrl": "https://your-app-domain.com/icon-180.png",
  "termsOfUseUrl": "https://your-app-domain.com/terms",
  "privacyPolicyUrl": "https://your-app-domain.com/privacy",
  "features": [
    "ton_addr",
    "ton_proof",
    "ton_sendTransaction"
  ]
}
```

### Environment Setup

Make sure your `pubspec.yaml` includes the required dependencies:

```yaml
dependencies:
  darttonconnect: ^1.0.1
  ton_dart: ^1.8.0
  # ... other dependencies
```

## Best Practices

### 1. Always Initialize

Always call `initialize()` before using the service:

```dart
await tonConnectService.initialize();
```

### 2. Handle Connection Status

Use the connection status stream to update your UI:

```dart
tonConnectService.connectionStatusStream.listen((isConnected) {
  // Update UI based on connection status
});
```

### 3. Validate Addresses

Always validate addresses before using them:

```dart
if (!TonConnectUtils.isValidAddress(address)) {
  throw ArgumentError('Invalid address: $address');
}
```

### 4. Use Proper Amount Format

Always use nano TON for amounts:

```dart
// Correct
String amount = TonConnectUtils.tonToNano('1.5'); // 1500000000

// Incorrect
String amount = '1.5'; // This will cause errors
```

### 5. Handle Errors Gracefully

Always wrap TON Connect operations in try-catch blocks:

```dart
try {
  final result = await tonConnectService.sendTransaction(...);
  // Handle success
} catch (e) {
  // Handle error and show user-friendly message
  showErrorDialog('Transaction failed: ${e.toString()}');
}
```

### 6. Dispose Resources

Always dispose the service when done:

```dart
@override
void dispose() {
  tonConnectService.dispose();
  super.dispose();
}
```

## Troubleshooting

### Common Issues

1. **"No wallets available"**
   - Make sure the user has a TON wallet installed
   - Check if the wallet supports TON Connect

2. **"Invalid address"**
   - Ensure addresses start with "EQ" and are 48 characters long
   - Use `TonConnectUtils.isValidAddress()` for validation

3. **"Transaction failed"**
   - Check if the wallet has sufficient balance
   - Verify the contract address is correct
   - Ensure the payload format is correct

4. **"Connection lost"**
   - The service will automatically attempt to restore connection
   - Check network connectivity
   - Verify the manifest URL is accessible

### Debug Mode

Enable debug logging by checking the console output. The service provides detailed logs for:
- Initialization steps
- Wallet discovery
- Connection attempts
- Transaction status
- Error details

## Migration from Old Version

If you're migrating from the old TON Connect service:

1. Update method calls to use named parameters:
   ```dart
   // Old
   sendTransaction(address, message)
   
   // New
   sendTransaction(
     contractAddress: address,
     amount: '0',
     payload: message,
   )
   ```

2. Add error handling for all operations
3. Use the new stream-based architecture for UI updates
4. Implement proper resource disposal

## Support

For issues and questions:
1. Check the [TON Connect documentation](https://docs.ton.org/develop/dapps/ton-connect)
2. Review the [tutorial](https://dev.to/roma_i_m/how-to-authorize-the-ton-blockchain-on-dart-using-a-wallet-via-ton-connect-edo)
3. Check the console logs for detailed error information 