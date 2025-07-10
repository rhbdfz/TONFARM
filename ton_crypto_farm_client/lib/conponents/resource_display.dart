import 'package:flutter/material.dart';
import '../core/models/game_models.dart';

class ResourceDisplay extends StatelessWidget {
  final ResourceBalances resources;

  const ResourceDisplay({Key? key, required this.resources}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resources',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ResourceItem(
                  icon: Icons.restaurant,
                  label: 'Food',
                  value: resources.food,
                  color: Colors.orange,
                ),
                _ResourceItem(
                  icon: Icons.park,
                  label: 'Wood',
                  value: resources.wood,
                  color: Colors.brown,
                ),
                _ResourceItem(
                  icon: Icons.monetization_on,
                  label: 'Gold',
                  value: resources.gold,
                  color: Colors.yellow[700]!,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ResourceItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;

  const _ResourceItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 2),
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
