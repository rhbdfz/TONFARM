import 'package:flutter/material.dart';
import '../core/models/game_models.dart';

class ToolInventory extends StatelessWidget {
  final List<ToolNFT> tools;

  const ToolInventory({super.key, required this.tools});

  @override
  Widget build(BuildContext context) {
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
                  'Инструменты',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${tools.length} шт.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (tools.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Нет инструментов',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.2,
                ),
                itemCount: tools.length,
                itemBuilder: (context, index) {
                  return _buildToolCard(context, tools[index]);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, ToolNFT tool) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getToolIcon(tool.type),
              size: 32,
              color: _getToolColor(tool.type),
            ),
            const SizedBox(height: 4),
            Text(
              _getToolName(tool.type),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              'Ур. ${tool.level}',
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: tool.durability / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                tool.durability > 50 ? Colors.green : 
                tool.durability > 20 ? Colors.orange : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getToolIcon(ToolType type) {
    switch (type) {
      case ToolType.fishingRod:
        return Icons.fishing;
      case ToolType.axe:
        return Icons.forest;
      case ToolType.pickaxe:
        return Icons.construction;
    }
  }

  Color _getToolColor(ToolType type) {
    switch (type) {
      case ToolType.fishingRod:
        return Colors.blue;
      case ToolType.axe:
        return Colors.brown;
      case ToolType.pickaxe:
        return Colors.grey;
    }
  }

  String _getToolName(ToolType type) {
    switch (type) {
      case ToolType.fishingRod:
        return 'Удочка';
      case ToolType.axe:
        return 'Топор';
      case ToolType.pickaxe:
        return 'Кирка';
    }
  }
}
