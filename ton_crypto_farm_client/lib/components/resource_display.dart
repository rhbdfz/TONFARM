import 'package:flutter/material.dart';
import '../core/models/game_models.dart';

class ResourceDisplay extends StatelessWidget {
  final ResourceBalances resources;

  const ResourceDisplay({super.key, required this.resources});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ресурсы',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildResourceItem(
                  context,
                  'Еда',
                  resources.food,
                  Icons.restaurant,
                  Colors.orange,
                ),
                _buildResourceItem(
                  context,
                  'Дерево',
                  resources.wood,
                  Icons.forest,
                  Colors.brown,
                ),
                _buildResourceItem(
                  context,
                  'Золото',
                  resources.gold,
                  Icons.monetization_on,
                  Colors.amber,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceItem(
    BuildContext context,
    String label,
    int amount,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          amount.toString(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
