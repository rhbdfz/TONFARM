class AppConstants {
  // API Endpoints
  static const String baseApiUrl = 'http://localhost:8080/api';
  static const String wsBaseUrl = 'ws://localhost:8080/ws';

  // Contract Addresses (заглушки для тестирования)
  static const String craftingContractAddress = 'EQCraftingContract...';
  static const String farmingContractAddress = 'EQFarmingContract...';
  static const String energyContractAddress = 'EQEnergyContract...';
  static const String marketplaceContractAddress = 'EQMarketplaceContract...';

  // Jetton Addresses
  static const String foodJettonAddress = 'EQFoodToken...';
  static const String woodJettonAddress = 'EQWoodToken...';
  static const String goldJettonAddress = 'EQGoldToken...';

  // Game Constants
  static const int maxEnergy = 100;
  static const int energyCostPerAction = 10;
  static const double tonToGameTokenRate = 20.0; // 20 игровых токенов = 1 TON

  // Animation Durations
  static const Duration harvestAnimationDuration = Duration(seconds: 2);
  static const Duration craftAnimationDuration = Duration(seconds: 3);
  static const Duration energyRefillAnimationDuration = Duration(seconds: 1);

  // Cache Keys
  static const String playerDataKey = 'player_data';
  static const String gameStateKey = 'game_state';
  static const String walletAddressKey = 'wallet_address';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double cardBorderRadius = 12.0;
  static const double buttonBorderRadius = 8.0;
}
