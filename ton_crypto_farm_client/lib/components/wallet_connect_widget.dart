import 'package:flutter/material.dart';
import '../core/services/ton_connect_service.dart';
import '../core/services/ton_connect_utils.dart';

class WalletConnectWidget extends StatefulWidget {
  final Function(String address)? onWalletConnected;
  final Function()? onWalletDisconnected;

  const WalletConnectWidget({
    Key? key,
    this.onWalletConnected,
    this.onWalletDisconnected,
  }) : super(key: key);

  @override
  State<WalletConnectWidget> createState() => _WalletConnectWidgetState();
}

class _WalletConnectWidgetState extends State<WalletConnectWidget> {
  final TonConnectService _tonConnectService = TonConnectService();
  bool _isConnecting = false;
  String? _error;
  List<String> _availableWallets = [];

  @override
  void initState() {
    super.initState();
    _initializeTonConnect();
    _setupListeners();
  }

  void _setupListeners() {
    // Listen to connection status changes
    _tonConnectService.connectionStatusStream.listen((isConnected) {
      if (mounted) {
        setState(() {});
        if (isConnected) {
          final address = _tonConnectService.walletAddress;
          if (address != null) {
            widget.onWalletConnected?.call(address);
          }
        } else {
          widget.onWalletDisconnected?.call();
        }
      }
    });

    // Listen to wallet address changes
    _tonConnectService.walletAddressStream.listen((address) {
      if (mounted) {
        setState(() {});
      }
    });

    // Listen to errors
    _tonConnectService.errorStream.listen((error) {
      if (mounted) {
        setState(() {
          _error = error;
        });
      }
    });
  }

  Future<void> _initializeTonConnect() async {
    try {
      await _tonConnectService.initialize();
      await _loadAvailableWallets();
    } catch (e) {
      setState(() {
        _error = 'Failed to initialize TON Connect: $e';
      });
    }
  }

  Future<void> _loadAvailableWallets() async {
    try {
      final wallets = await _tonConnectService.getAvailableWallets();
      setState(() {
        _availableWallets = wallets.map((w) => TonConnectUtils.getWalletDisplayName(w)).toList();
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load wallets: $e';
      });
    }
  }

  Future<void> _connectWallet() async {
    setState(() {
      _isConnecting = true;
      _error = null;
    });

    try {
      final result = await _tonConnectService.connectWallet();
      if (!result) {
        setState(() {
          _error = 'Failed to connect wallet';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Connection error: $e';
      });
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  Future<void> _disconnectWallet() async {
    try {
      await _tonConnectService.disconnect();
    } catch (e) {
      setState(() {
        _error = 'Disconnection error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = _tonConnectService.isConnected;
    final walletAddress = _tonConnectService.walletAddress;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  isConnected ? Icons.account_balance_wallet : Icons.account_balance_wallet_outlined,
                  color: isConnected ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  'TON Wallet',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (isConnected)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Connected',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (isConnected && walletAddress != null) ...[
              Text(
                'Address:',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        TonConnectUtils.formatAddress(walletAddress),
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 16),
                      onPressed: () {
                        // Copy to clipboard
                        // You can add clipboard functionality here
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _disconnectWallet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Disconnect Wallet'),
                ),
              ),
            ] else ...[
              if (_availableWallets.isNotEmpty) ...[
                Text(
                  'Available Wallets:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                ...(_availableWallets.take(3).map((wallet) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $wallet'),
                ))),
                if (_availableWallets.length > 3)
                  Text('... and ${_availableWallets.length - 3} more'),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isConnecting ? null : _connectWallet,
                  child: _isConnecting
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('Connecting...'),
                          ],
                        )
                      : const Text('Connect Wallet'),
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red[600], size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: Colors.red[700], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tonConnectService.dispose();
    super.dispose();
  }
} 