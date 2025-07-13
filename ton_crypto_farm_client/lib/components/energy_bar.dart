import 'package:flutter/material.dart';

class EnergyBar extends StatelessWidget {
  final int energy;
  final int maxEnergy;

  const EnergyBar({super.key, required this.energy, this.maxEnergy = 100});

  @override
  Widget build(BuildContext context) {
    final percentage = energy / maxEnergy;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Энергия',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$energy/$maxEnergy',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage > 0.5 ? Colors.green : 
                percentage > 0.2 ? Colors.orange : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
