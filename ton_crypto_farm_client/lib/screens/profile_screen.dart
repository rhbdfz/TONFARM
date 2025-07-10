import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../services/game_api.dart';
import '../services/ton_connect_service.dart';
import '../utils/helpers.dart';

final profileProvider = FutureProvider<Player>((ref) async {
  final addr = TonConnectService().walletAddress!;
  return await GameAPI().getPlayer(addr);
});

/// Экран профиля и настроек
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(profileProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль'), backgroundColor: const Color(0xFF40A6FF)),
      body: async.when(
        data: (p) => _buildProfile(context, p),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
      ),
    );
  }

  Widget _buildProfile(BuildContext c, Player p) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CircleAvatar(radius: 48, child: Text(p.username[0].toUpperCase())),
          const SizedBox(height: 16),
          Text(p.username, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Уровень ${p.level}', style: const TextStyle(fontSize: 18)),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Выйти'),
            onTap: () => TonConnectService().disconnect(),
          ),
        ],
      ),
    );
  }
}
