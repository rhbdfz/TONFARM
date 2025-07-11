import 'package:intl/intl.dart';
import '../models/game_models.dart';


class FormatHelper {
  static final NumberFormat _numberFormat = NumberFormat('#,###');
  static final NumberFormat _decimalFormat = NumberFormat('#,###.##');

  static String formatNumber(int number) {
    return _numberFormat.format(number);
  }

  static String formatDecimal(double number) {
    return _decimalFormat.format(number);
  }

  static String formatTonAmount(double amount) {
    return '${_decimalFormat.format(amount)} TON';
  }

  static String formatResourceAmount(int amount, ResourceType type) {
    final suffix = _getResourceSuffix(type);
    return '${_numberFormat.format(amount)} $suffix';
  }

  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hoursч $minutesм';
    } else {
      return '$minutesм';
    }
  }

  static String formatPercentage(double percentage) {
    return '${(percentage * 100).toStringAsFixed(1)}%';
  }

  static String formatToolType(ToolType type) {
    switch (type) {
      case ToolType.fishingRod:
        return 'Удочка';
      case ToolType.axe:
        return 'Топор';
      case ToolType.pickaxe:
        return 'Кирка';
    }
  }

  static String formatLandType(LandType type) {
    switch (type) {
      case LandType.lake:
        return 'Озеро';
      case LandType.forest:
        return 'Лес';
      case LandType.mountain:
        return 'Гора';
    }
  }

  static String _getResourceSuffix(ResourceType type) {
    switch (type) {
      case ResourceType.food:
        return 'Еды';
      case ResourceType.wood:
        return 'Дерева';
      case ResourceType.gold:
        return 'Золота';
    }
  }

  static String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('dd.MM.yyyy HH:mm');
    return formatter.format(dateTime);
  }

  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'только что';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} мин назад';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ч назад';
    } else {
      return '${difference.inDays} дн назад';
    }
  }
}
