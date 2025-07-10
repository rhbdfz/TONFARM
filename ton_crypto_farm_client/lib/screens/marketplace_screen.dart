import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/marketplace_listing.dart';
import '../services/game_api.dart';
import '../services/ton_connect_service.dart';
import '../widgets/listing_card.dart';

/// Провайдер листингов
final listingsProvider = FutureProvider.autoDispose<List<MarketplaceListing>>((ref) async {
  return await GameAPI().getActiveListings();
});

/// Экран маркетплейса
class MarketplaceScreen extends ConsumerWidget {
  const MarketplaceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(listingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Маркет'), backgroundColor: const Color(0xFF40A6FF)),
      body: async.when(
        data: (list) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (_, i) => ListingCard(
            listing: list[i],
            onBuy: () => _onBuy(context, list[i]),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
      ),
    );
  }

  Future<void> _onBuy(BuildContext context, MarketplaceListing l) async {
    final addr = TonConnectService().walletAddress!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Купить NFT'),
        content: Text('Цена: ${l.price} TON\nКомиссия: ${l.price * 0.035}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final resp = await GameAPI().buyNFT(
                listingId: l.id,
                buyerAddress: addr,
              );
              await TonConnectService().sendTransaction(resp.contractAddress, resp.message);
            },
            child: const Text('Купить'),
          ),
        ],
      ),
    );
  }
}
