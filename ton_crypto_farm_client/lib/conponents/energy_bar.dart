import 'package:flutter/material.dart';

class EnergyBar extends StatelessWidget {
  final int energy;
  final int maxEnergy;

  const EnergyBar({
    Key? key,
    required this.energy,
    this.maxEnergy = 100,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentage = energy / maxEnergy;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Energy',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '$energy/$maxEnergy',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getEnergyColor(percentage),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getEnergyColor(double percentage) {
    if (percentage > 0.6) return Colors.green;
    if (percentage > 0.3) return Colors.orange;
    return Colors.red;
  }
}
