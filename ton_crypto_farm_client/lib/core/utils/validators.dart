import '../constants/app_constants.dart';
import '../models/game_models.dart';

class GameValidators {
  static bool isValidWalletAddress(String address) {
    // Проверка формата TON адреса
    return address.isNotEmpty &&
        (address.startsWith('EQ') || address.startsWith('UQ')) &&
        address.length == 48;
  }

  static bool isValidTelegramId(String id) {
    return id.isNotEmpty && RegExp(r'^\d+$').hasMatch(id);
  }

  static bool isValidUsername(String username) {
    return username.isNotEmpty &&
        username.length >= 3 &&
        username.length <= 32 &&
        RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username);
  }

  static bool hasEnoughResources(
      ResourceBalances currentResources,
      Map<String, int> requiredResources
      ) {
    return currentResources.food >= (requiredResources['food'] ?? 0) &&
        currentResources.wood >= (requiredResources['wood'] ?? 0) &&
        currentResources.gold >= (requiredResources['gold'] ?? 0);
  }

  static bool hasEnoughEnergy(int currentEnergy, int requiredEnergy) {
    return currentEnergy >= requiredEnergy;
  }

  static String? validateCraftInput(ToolType toolType, int level) {
    if (level < 1 || level > 4) {
      return 'Уровень инструмента должен быть от 1 до 4';
    }
    return null;
  }

  static String? validateEnergyRefill(int currentEnergy, int refillAmount) {
    if (currentEnergy >= AppConstants.maxEnergy) {
      return 'Энергия уже полная';
    }

    if (refillAmount <= 0) {
      return 'Количество для пополнения должно быть больше 0';
    }

    if (currentEnergy + refillAmount > AppConstants.maxEnergy) {
      return 'Превышен максимальный уровень энергии';
    }

    return null;
  }
}
