import 'package:flutter/material.dart';
import '../core/models/game_models.dart';

class ToolInventory extends StatelessWidget {
  final List<ToolNFT> tools;

  const ToolInventory({Key? key, required this.tools}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tools',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (tools.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No tools yet. Craft your first tool!'),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: tools.length,
                itemBuilder: (context, index) {
                  final tool = tools[index];
                  return _ToolCard(tool: tool);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final ToolNFT tool;

  const _ToolCard({required this.tool});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8),
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
              'Lv.${tool.level}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            LinearProgressIndicator(
              value: tool.durability / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getDurabilityColor(tool.durability),
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
        return Icons.phishing;
      case ToolType.axe:
        return Icons.carpenter;
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

  Color _getDurabilityColor(int durability) {
    if (durability > 60) return Colors.green;
    if (durability > 30) return Colors.orange;
    return Colors.red;
  }
}
