# TON Crypto Farm - Анализ и План Развития

## АНАЛИЗ ПРОЕКТА

### СЕРВЕРНАЯ ЧАСТЬ (`ton_crypto_farm_server`)

#### Структура файлов и классы:

**Controllers:**
- `lib/controllers/game_controller.dart`
  - Класс: `GameController`
  - Методы:
    - `prepareCraft(Request request)` → взаимодействует с `RecipeCalculator.getRecipe()`, `FirebaseService.getGameState()`, `TonService.createCraftMessage()`
    - `prepareFarm(Request request)` → взаимодействует с `FirebaseService.getGameState()`, `RecipeCalculator.calculateHarvest()`, `TonService.createFarmMessage()`
    - `getBalance(Request request)` → взаимодействует с `TonService.getJettonBalance()`, `TonService.getPlayerEnergy()`

- `lib/controllers/player_controller.dart`
  - Класс: `PlayerController`
  - Методы:
    - `register(Request request)` → взаимодействует с `FirebaseService.findPlayerByTelegramId()`, `FirebaseService.createPlayer()`, `FirebaseService.saveGameState()`
    - `getState(Request request)` → взаимодействует с `FirebaseService.getPlayer()`, `FirebaseService.getGameState()`, `TonService.getJettonBalance()`
    - `linkWallet(Request request)` → взаимодействует с `FirebaseService.updatePlayer()`, `_loadBalances()`
    - `_loadBalances(String walletAddress)` → взаимодействует с `TonService.getJettonBalance()`, `TonService.getPlayerEnergy()`

**Middleware:**
- `lib/middleware/auth_middleware.dart`
  - Функция: `authMiddleware` (незавершенная логика авторизации)

**Models:**
- `lib/models/game_state_model.dart`
  - Классы:
    - `GameState` → методы: `toMap()`, `fromMap()`, `hasEnoughResources()`, `updateBalances()`, `addTool()`, `addLand()`, `updateEnergy()`
    - `ResourceBalances` → методы: `toMap()`, `fromMap()`, `getTotalValue()`, `subtract()`, `add()`
    - `ToolNFT` → методы: `toMap()`, `fromMap()`, `needsRepair()`, `isBroken()`, `decreaseDurability()`, `repair()`
    - `LandNFT` → методы: `toMap()`, `fromMap()`, `getBoost()`, `isCompatibleWith()`
  - Енумы: `ToolType`, `LandType`

- `lib/models/player_model.dart`
  - Класс: `Player`
  - Методы: `toMap()`, `fromMap()`

**Repositories:**
- `lib/repositories/nft_repository.dart`
  - Класс: `NFTRepository`
  - Методы (все статические):
    - `getPlayerTools(String playerId)` → взаимодействует с `FirebaseService.getGameState()`
    - `getPlayerLands(String playerId)` → взаимодействует с `FirebaseService.getGameState()`
    - `getToolById(String toolId)` → взаимодействует с `FirebaseService.firestore`
    - `getLandById(String landId)` → взаимодействует с `FirebaseService.firestore`
    - `createTool(ToolNFT tool)` → взаимодействует с `FirebaseService.firestore`
    - `createLand(LandNFT land)` → взаимодействует с `FirebaseService.firestore`
    - `updateToolDurability(String toolId, int durability)` → взаимодействует с `FirebaseService.firestore`
    - `transferNFTOwnership(String nftId, String newOwner, String collection)` → взаимодействует с `FirebaseService.firestore`

- `lib/repositories/recipe_repository.dart`
  - Класс: `RecipeRepository`
  - Методы (все статические):
    - `getRecipe(ToolType toolType, int level)`
    - `getRecipeMap(ToolType toolType, int level)`
    - `getAllRecipesForTool(ToolType toolType)`
    - `getTotalCost(ToolType toolType, int level)`
  - Класс: `Recipe`
  - Методы: `toMap()`, `getRatios()`

**Services:**
- `lib/services/firebase_service.dart`
  - Класс: `FirebaseService`
  - Методы (все статические):
    - `init()` → инициализация Firebase
    - `createPlayer(Map<String, dynamic> playerData)`
    - `getPlayer(String playerId)`
    - `updatePlayer(String playerId, Map<String, dynamic> data)`
    - `saveGameState(String playerId, Map<String, dynamic> state)`
    - `getGameState(String playerId)`
    - `findPlayerByTelegramId(String telegramId)`

- `lib/services/ton_service.dart`
  - Класс: `TonService`
  - Методы (все статические):
    - `init()` → инициализация TON провайдера
    - `getJettonBalance(String playerAddress, String jettonMaster)`
    - `getPlayerEnergy(String playerAddress)`
    - `createCraftMessage(String playerAddress, int toolType, int level, Map<String, int> recipe)`
    - `createFarmMessage(String playerAddress, int toolType, int toolLevel, int? landLevel)`
    - `_calculateJettonWalletAddress(String ownerAddress, String jettonMaster)` (незавершенная логика)
    - `getJettonAddress(String tokenType)`

- `lib/services/websocket_service.dart`
  - Класс: `WebSocketService`
  - Методы (все статические):
    - `handleConnection(WebSocketChannel webSocket, String playerId)`
    - `sendToPlayer(String playerId, Map<String, dynamic> message)`
    - `broadcastToAll(Map<String, dynamic> message)`
    - `notifyGameStateUpdate(String playerId, Map<String, dynamic> gameState)`
    - `notifyResourceUpdate(String playerId, Map<String, int> resources)`
    - `notifyEnergyUpdate(String playerId, int energy)`
    - `notifyTransactionConfirmed(String playerId, String transactionHash)`
    - `notifyError(String playerId, String error)`
    - `_setupHeartbeat(String playerId)`
    - `_removeConnection(String playerId)`

**Utils:**
- `lib/utils/recipe_calculator.dart`
  - Класс: `RecipeCalculator`
  - Методы (все статические):
    - `getRecipe(int toolType, int level)`
    - `calculateHarvest(int toolType, int toolLevel, int? landLevel)`
    - `calculateRepairCost(int toolType, int level, int currentDurability)`

---

### КЛИЕНТСКАЯ ЧАСТЬ (`ton_crypto_farm_client`)

#### Структура файлов и классы:

**Main:**
- `lib/main.dart`
  - Класс: `TONFarmApp`
  - Методы: `build(BuildContext context)` → взаимодействует с `GameProvider`, `ApiService`

**Pages:**
- `lib/pages/game_dashboard.dart`
  - Класс: `GameDashboard`
  - Методы: 
    - `build(BuildContext context)` → взаимодействует с `GameProvider`
    - `_buildActionButtons(BuildContext context, GameProvider gameProvider)` (незавершенная навигация)
    - `_buildBottomNavigation()` (незавершенная навигация)

- `lib/pages/initialization_screen.dart`
  - Класс: `InitializationScreen`
  - Методы:
    - `build(BuildContext context)` → взаимодействует с `GameProvider`
    - `_initializeGame()` → взаимодействует с `GameProvider.initializeGame()`

**Providers:**
- `lib/providers/game_provider.dart`
  - Класс: `GameProvider` (extends ChangeNotifier)
  - Методы:
    - `initializeGame()` → взаимодействует с `TelegramService.getCurrentUser()`, `registerPlayer()`, `_setupWebSocket()`
    - `registerPlayer(String telegramId, String username)` → взаимодействует с `ApiService.registerPlayer()`
    - `_loadGameState()` → взаимодействует с `ApiService.getGameState()`
    - `connectWallet()` → взаимодействует с `TonConnectService`, `ApiService.linkWallet()`
    - `craftTool(ToolType toolType, int level)` → взаимодействует с `ApiService.prepareCraftTransaction()`, `TonConnectService.sendTransaction()`
    - `harvestResources(String toolId, String? landId)` → взаимодействует с `ApiService.prepareHarvestTransaction()`, `TonConnectService.sendTransaction()`
    - `_setupWebSocket()` → создает WebSocket соединение
    - `_handleGameUpdate(GameUpdate update)` → обрабатывает обновления через WebSocket

**Components:**
- `lib/components/energy_bar.dart`
  - Класс: `EnergyBar`
  - Методы: `build(BuildContext context)` → отображение энергии

- `lib/components/resource_display.dart`
  - Класс: `ResourceDisplay`
  - Методы: 
    - `build(BuildContext context)` → взаимодействует с `ResourceBalances`
    - `_buildResourceItem()` → вспомогательный метод отображения

- `lib/components/tool_inventory.dart`
  - Класс: `ToolInventory`
  - Методы:
    - `build(BuildContext context)` → отображение инструментов
    - `_buildToolCard(BuildContext context, ToolNFT tool)`
    - `_getToolIcon(ToolType type)`, `_getToolColor(ToolType type)`, `_getToolName(ToolType type)` → вспомогательные методы

- `lib/components/wallet_connect_widget.dart`
  - Класс: `WalletConnectWidget`
  - Методы:
    - `build(BuildContext context)` → взаимодействует с `TonConnectService`
    - `_initializeTonConnect()` → взаимодействует с `TonConnectService.initialize()`
    - `_loadAvailableWallets()` → взаимодействует с `TonConnectService.getAvailableWallets()`
    - `_connectWallet()` → взаимодействует с `TonConnectService.connectWallet()`
    - `_disconnectWallet()` → взаимодействует с `TonConnectService.disconnect()`
    - `_setupListeners()` → подписка на изменения состояния кошелька

**Core Services:**
- `lib/core/services/api_service.dart`
  - Класс: `ApiService`
  - Методы:
    - `registerPlayer(String telegramId, String username)` → HTTP запрос к серверу
    - `getGameState(String playerId)` → HTTP запрос к серверу
    - `prepareCraftTransaction(CraftRequest request)` → HTTP запрос к серверу
    - `prepareHarvestTransaction(HarvestRequest request)` → HTTP запрос к серверу
    - `linkWallet(String playerId, String walletAddress)` → HTTP запрос к серверу

- `lib/core/services/telegram_service.dart`
  - Класс: `TelegramService`
  - Методы (все статические, с mock реализацией):
    - `init()` → инициализация Telegram Mini App
    - `getCurrentUser()` → получение данных пользователя Telegram
    - `showMainButton(String text, Function() onPressed)`
    - `hideMainButton()`
    - `showAlert(String message)`
    - `close()`

- `lib/core/services/ton_connect_service.dart`
  - Класс: `TonConnectService` (синглтон)
  - Методы:
    - `initialize()` → взаимодействует с `TonConnect`
    - `getAvailableWallets()` → взаимодействует с `TonConnect.getWallets()`
    - `connectWallet([WalletApp? wallet])` → взаимодействует с `TonConnect.connect()`
    - `disconnect()` → взаимодействует с `TonConnect.disconnect()`
    - `sendTransaction()` → взаимодействует с `TonConnect.sendTransaction()`, `TonConnectUtils`
    - `sendBatchTransaction()` → взаимодействует с `TonConnect.sendTransaction()`
    - `getAddressBalance(String address)` → HTTP запрос к TON API
    - `nanoTonToTon(String nanoTonString)` → конвертация
    - `callContract()` → вызов смарт-контрактов (незавершенная логика)

- `lib/core/services/ton_connect_utils.dart`
  - Класс: `TonConnectUtils`
  - Методы (все статические):
    - `tonToNano(String tonAmount)`, `nanoToTon(String nanoAmount)` → конвертация
    - `formatAddress(String address)` → форматирование адреса
    - `isValidAddress(String address)` → валидация адреса
    - `createMessage()`, `createTransactionRequest()` → создание транзакций
    - `getWalletDisplayName()`, `walletSupportsFeature()`, `getWalletFeatures()` → работа с кошельками
    - `createCommentPayload()`, `parseCommentFromPayload()` → работа с комментариями

**Core Models:**
- `lib/core/models/game_models.dart`
  - Классы:
    - `Player` → методы: `fromJson()`, `toJson()`
    - `GameState` → методы: `fromJson()`, `toJson()`, `copyWith()`
    - `ResourceBalances` → методы: `fromJson()`, `toJson()`
    - `ToolNFT` → методы: `fromJson()`, `toJson()`
    - `LandNFT` → методы: `fromJson()`, `toJson()`
    - `CraftRequest`, `CraftTransaction` → методы: `fromJson()`, `toJson()`, `toTonTransaction()`
    - `HarvestRequest`, `HarvestTransaction` → методы: `fromJson()`, `toJson()`, `toTonTransaction()`
    - `GameUpdate` → методы: `fromJson()`, `toJson()`
  - Енумы: `ToolType`, `LandType`, `ResourceType`, `UpdateType`
  - Функции: `toolTypeFromJson()`, `landTypeFromJson()`

**Core Helpers/Utils:**
- `lib/core/helpers/format_helper.dart`
  - Класс: `FormatHelper`
  - Методы (все статические): форматирование чисел, времени, ресурсов, типов инструментов и земель

- `lib/core/utils/validators.dart`
  - Класс: `GameValidators`
  - Методы (все статические): валидация адресов, Telegram ID, ресурсов, энергии, крафта

- `lib/core/constants/app_constants.dart`
  - Класс: `AppConstants` → константы API, контрактов, игровых параметров

- `lib/core/theme/app_theme.dart`
  - Класс: `AppTheme`
  - Методы: `get lightTheme`, `get darkTheme` → темы приложения

---

## СТРУКТУРА ВЗАИМОДЕЙСТВИЯ КЛИЕНТ-СЕРВЕР

### Передаваемая информация от клиента к серверу:

1. **Регистрация игрока:**
   - POST `/api/players/register`
   - Данные: `{telegramId, username}`
   - Ответ: `{success, player, gameState}`

2. **Получение состояния игры:**
   - GET `/api/players/{playerId}/state`
   - Ответ: `{player, gameState}`

3. **Подготовка крафта:**
   - POST `/api/craft/prepare`
   - Данные: `{playerId, toolType, level, playerAddress}`
   - Ответ: `{success, contractAddress, message, requirements, estimatedFee}`

4. **Подготовка фарма:**
   - POST `/api/farm/prepare`
   - Данные: `{playerId, toolId, landId?, playerAddress}`
   - Ответ: `{success, contractAddress, message, harvestAmount, energyCost, estimatedFee}`

5. **Привязка кошелька:**
   - POST `/api/players/{playerId}/link-wallet`
   - Данные: `{walletAddress}`
   - Ответ: `{success, walletAddress, balances}`

6. **Получение баланса:**
   - GET `/api/balance/{address}/{token}`
   - Ответ: `{address, token, balance}`

### Получаемая информация клиентом от сервера через WebSocket:

1. **Подключение:** `{type: 'connected', playerId, timestamp}`
2. **Обновление состояния игры:** `{type: 'gameStateUpdate', data, timestamp}`
3. **Изменение ресурсов:** `{type: 'resourcesChanged', resources, timestamp}`
4. **Изменение энергии:** `{type: 'energyChanged', energy, timestamp}`
5. **Подтверждение транзакции:** `{type: 'transactionConfirmed', transactionHash, timestamp}`
6. **Ошибки:** `{type: 'error', message, timestamp}`
7. **Пинг:** `{type: 'ping', timestamp}`

---

## СПИСОК КЛАССОВ И МЕТОДОВ С НЕЗАКОНЧЕННОЙ ЛОГИКОЙ

### Серверная часть:

1. **`AuthMiddleware`** (полностью незавершен)
   - Нет реализации проверки JWT токенов или других механизмов авторизации

2. **`TonService`**
   - `_calculateJettonWalletAddress()` → возвращает заглушку вместо правильного расчета
   - Константы адресов контрактов содержат заглушки (`'EQCraftingContract...'`)

3. **`GameController`**
   - Отсутствует обработка результатов транзакций из блокчейна
   - Нет валидации входящих данных

4. **`PlayerController`**
   - `_loadBalances()` → возвращает hardcoded значения при ошибке

### Клиентская часть:

1. **`TelegramService`** (полностью mock)
   - Все методы содержат только заглушки для демонстрации

2. **`GameDashboard`**
   - `_buildActionButtons()` → кнопки не ведут никуда (комментарии "Navigate to...")
   - `_buildBottomNavigation()` → навигация не реализована

3. **`TonConnectService`**
   - `callContract()` → метод возвращает null, нет реализации вызовов контрактов
   - Закомментирован большой блок альтернативной реализации

4. **`WalletConnectWidget`**
   - Кнопка копирования адреса не реализована
   - Отсутствует функционал копирования в буфер обмена

5. **`GameProvider`**
   - Отсутствует метод `refresh()` для `RefreshIndicator`
   - Нет обработки ошибок WebSocket переподключения

6. **`ApiService`**
   - Отсутствует обработка сетевых ошибок и таймаутов
   - Нет ретрай логики для неудачных запросов

7. **Общие проблемы:**
   - Отсутствуют экраны крафта, фарма, маркетплейса, профиля
   - Нет системы уведомлений
   - Отсутствует кэширование данных
   - Нет обработки офлайн режима

---

# ПОСЛЕДОВАТЕЛЬНЫЙ ПЛАН РАЗВИТИЯ TON CRYPTO FARM

## ЧАСТЬ 1: ИСПРАВЛЕНИЕ СУЩЕСТВУЮЩИХ ПРОБЛЕМ

### 1.1 Критические исправления серверной части

#### 1.1.1 Исправление TonService (Приоритет: КРИТИЧЕСКИЙ)
```
Проблема: Заглушки контрактов и неправильный расчет Jetton адресов
Решение:
1. Заменить константы заглушек на реальные адреса контрактов
2. Реализовать _calculateJettonWalletAddress() с правильной логикой
3. Добавить валидацию адресов TON
4. Реализовать обработку ошибок сети TON

Файлы: ton_crypto_farm_server/lib/services/ton_service.dart
Время: 3-4 дня
```

#### 1.1.2 Реализация AuthMiddleware (Приоритет: ВЫСОКИЙ)
```
Проблема: Отсутствует авторизация API
Решение:
1. Реализовать JWT токены для аутентификации
2. Добавить middleware для проверки токенов
3. Создать систему ролей (игрок, админ)
4. Добавить rate limiting

Файлы: 
- ton_crypto_farm_server/lib/middleware/auth_middleware.dart
- Новый: ton_crypto_farm_server/lib/services/auth_service.dart
Время: 2-3 дня
```

#### 1.1.3 Улучшение обработки ошибок (Приоритет: ВЫСОКИЙ)
```
Проблема: Недостаточная обработка ошибок
Решение:
1. Добавить валидацию входящих данных во все контроллеры
2. Создать централизованную систему обработки ошибок
3. Добавить логирование ошибок
4. Реализовать graceful degradation для blockchain операций

Файлы: 
- Все контроллеры
- Новый: ton_crypto_farm_server/lib/utils/error_handler.dart
- Новый: ton_crypto_farm_server/lib/utils/logger.dart
Время: 2 дня
```

### 1.2 Критические исправления клиентской части

#### 1.2.1 Замена TelegramService mock на реальную реализацию (Приоритет: КРИТИЧЕСКИЙ)
```
Проблема: Все методы TelegramService являются заглушками
Решение:
1. Интегрировать telegram_web_app пакет
2. Реализовать получение реальных данных пользователя
3. Добавить обработку Telegram Mini App lifecycle
4. Реализовать Telegram-специфичные UI элементы

Файлы: ton_crypto_farm_client/lib/core/services/telegram_service.dart
Время: 3-4 дня
```

#### 1.2.2 Исправление навигации и недостающих экранов (Приоритет: ВЫСОКИЙ)
```
Проблема: Кнопки навигации не работают
Решение:
1. Реализовать роутинг с go_router
2. Создать недостающие экраны (крафт, фарм, маркет, профиль)
3. Связать кнопки с соответствующими экранами
4. Добавить анимации переходов

Файлы:
- ton_crypto_farm_client/lib/pages/game_dashboard.dart
- Новые экраны в ton_crypto_farm_client/lib/pages/
Время: 4-5 дней
```

#### 1.2.3 Улучшение TonConnectService (Приоритет: ВЫСОКИЙ)
```
Проблема: Незавершенная логика вызова контрактов
Решение:
1. Реализовать callContract() метод
2. Добавить обработку различных типов транзакций
3. Улучшить error handling
4. Добавить retry логику для неудачных транзакций

Файлы: ton_crypto_farm_client/lib/core/services/ton_connect_service.dart
Время: 2-3 дня
```

### 1.3 Исправления инфраструктуры

#### 1.3.1 Улучшение API обработки (Приоритет: СРЕДНИЙ)
```
Проблема: Нет обработки сетевых ошибок и таймаутов
Решение:
1. Добавить retry логику в ApiService
2. Реализовать timeout handling
3. Добавить offline/online detection
4. Создать queue для отложенных запросов

Файлы: ton_crypto_farm_client/lib/core/services/api_service.dart
Время: 2 дня
```

#### 1.3.2 Исправление WebSocket стабильности (Приоритет: СРЕДНИЙ)
```
Проблема: Нет переподключения при обрыве соединения
Решение:
1. Добавить автоматическое переподключение
2. Реализовать heartbeat механизм
3. Добавить queue для сообщений при разрыве
4. Улучшить error handling

Файлы: 
- ton_crypto_farm_client/lib/providers/game_provider.dart
- ton_crypto_farm_server/lib/services/websocket_service.dart
Время: 2 дня
```

## ЧАСТЬ 2: ВНЕДРЕНИЕ НЕОБХОДИМОГО ФУНКЦИОНАЛА

### 2.1 Основной игровой функционал

#### 2.1.1 Система инвентаря и управления NFT (Приоритет: КРИТИЧЕСКИЙ)
```
Цель: Полноценная работа с NFT инструментами и землями
Реализация:
1. Создать экран инвентаря с фильтрацией и сортировкой
2. Добавить drag & drop для использования инструментов
3. Реализовать систему ремонта инструментов
4. Добавить preview NFT с детальной информацией

Новые файлы:
- ton_crypto_farm_client/lib/pages/inventory_screen.dart
- ton_crypto_farm_client/lib/components/nft_card.dart
- ton_crypto_farm_client/lib/components/repair_dialog.dart

Изменения в серверной части:
- Добавить эндпоинты для ремонта
- Реализовать логику износа инструментов

Время: 5-6 дней
```

#### 2.1.2 Система крафтинга (Приоритет: КРИТИЧЕСКИЙ)
```
Цель: Интерактивный процесс создания инструментов
Реализация:
1. Создать экран крафтинга с выбором типа и уровня
2. Добавить предпросмотр требований ресурсов
3. Реализовать анимации процесса крафтинга
4. Добавить звуковые эффекты и вибрацию

Новые файлы:
- ton_crypto_farm_client/lib/pages/crafting_screen.dart
- ton_crypto_farm_client/lib/components/recipe_card.dart
- ton_crypto_farm_client/lib/components/crafting_progress.dart

Серверная часть:
- Добавить валидацию рецептов
- Реализовать очередь крафтинга

Время: 4-5 дней
```

#### 2.1.3 Система фарминга и добычи ресурсов (Приоритет: КРИТИЧЕСКИЙ)
```
Цель: Интерактивный процесс добычи ресурсов
Реализация:
1. Создать экран фарминга с выбором локации
2. Добавить мини-игры для добычи (тап-игры)
3. Реализовать систему комбо и множителей
4. Добавить визуальные эффекты добычи

Новые файлы:
- ton_crypto_farm_client/lib/pages/farming_screen.dart
- ton_crypto_farm_client/lib/components/location_selector.dart
- ton_crypto_farm_client/lib/components/mining_game.dart

Серверная часть:
- Добавить anti-cheat систему
- Реализовать динамические коэффициенты добычи

Время: 6-7 дней
```

### 2.2 Экономическая система

#### 2.2.1 Внутриигровой маркетплейс (Приоритет: ВЫСОКИЙ)
```
Цель: Торговля NFT между игроками
Реализация:
1. Создать экран маркетплейса с фильтрами
2. Реализовать систему выставления лотов
3. Добавить историю транзакций
4. Реализовать систему комиссий

Новые файлы:
- ton_crypto_farm_client/lib/pages/marketplace_screen.dart
- ton_crypto_farm_client/lib/components/marketplace_filter.dart
- ton_crypto_farm_client/lib/components/auction_card.dart

Серверная часть:
- Новые контроллеры для маркетплейса
- Система эскроу для безопасных сделок
- Новые таблицы в базе данных

Время: 8-10 дней
```

#### 2.2.2 Система энергии и восстановления (Приоритет: ВЫСОКИЙ)
```
Цель: Сбалансированная система лимитов активности
Реализация:
1. Добавить автоматическое восстановление энергии
2. Реализовать покупку энергии за TON
3. Добавить бонусы и буферы энергии
4. Создать систему daily энергетических подарков

Новые файлы:
- ton_crypto_farm_client/lib/components/energy_shop.dart
- ton_crypto_farm_client/lib/components/energy_timer.dart

Серверная часть:
- Планировщик восстановления энергии
- Система микротранзакций

Время: 4-5 дней
```

### 2.3 Социальные функции

#### 2.3.1 Система достижений и прогресса (Приоритет: СРЕДНИЙ)
```
Цель: Мотивация долгосрочной игры
Реализация:
1. Создать систему достижений с наградами
2. Добавить прогресс-бары и статистику
3. Реализовать ежедневные задания
4. Добавить сезонные ивенты

Новые файлы:
- ton_crypto_farm_client/lib/pages/achievements_screen.dart
- ton_crypto_farm_client/lib/components/achievement_card.dart
- ton_crypto_farm_client/lib/components/daily_quests.dart

Серверная часть:
- Система трекинга достижений
- Планировщик ивентов

Время: 6-7 дней
```

#### 2.3.2 Система рефералов (Приоритет: СРЕДНИЙ)
```
Цель: Вирусный рост пользователей
Реализация:
1. Создать реферальные ссылки через Telegram
2. Добавить систему наград за приведенных друзей
3. Реализовать таблицу лидеров рефереров
4. Добавить групповые бонусы

Новые файлы:
- ton_crypto_farm_client/lib/pages/referral_screen.dart
- ton_crypto_farm_client/lib/components/referral_stats.dart

Серверная часть:
- Система отслеживания рефералов
- Автоматические выплаты наград

Время: 4-5 дней
```

### 2.4 Техническая инфраструктура

#### 2.4.1 Система кэширования и оффлайн режима (Приоритет: ВЫСОКИЙ)
```
Цель: Стабильная работа при плохом интернете
Реализация:
1. Добавить локальное кэширование игрового состояния
2. Реализовать синхронизацию при восстановлении сети
3. Добавить оффлайн индикаторы
4. Создать очередь отложенных действий

Новые файлы:
- ton_crypto_farm_client/lib/core/services/cache_service.dart
- ton_crypto_farm_client/lib/core/services/sync_service.dart

Время: 4-5 дней
```

#### 2.4.2 Система аналитики и мониторинга (Приоритет: СРЕДНИЙ)
```
Цель: Отслеживание метрик и проблем
Реализация:
1. Интегрировать Firebase Analytics
2. Добавить трекинг пользовательских действий
3. Реализовать crash reporting
4. Создать dashboard администратора

Новые файлы:
- ton_crypto_farm_client/lib/core/services/analytics_service.dart
- ton_crypto_farm_server/lib/services/analytics_service.dart

Время: 3-4 дня
```

#### 2.4.3 Система безопасности (Приоритет: ВЫСОКИЙ)
```
Цель: Защита от читерства и атак
Реализация:
1. Добавить server-side валидацию всех действий
2. Реализовать rate limiting и spam protection
3. Добавить детекцию аномальной активности
4. Создать систему банов и предупреждений

Серверная часть:
- Middleware для валидации
- Система мониторинга подозрительной активности

Время: 5-6 дней
```

### 2.5 UI/UX улучшения

#### 2.5.1 Адаптивный дизайн и анимации (Приоритет: СРЕДНИЙ)
```
Цель: Современный и привлекательный интерфейс
Реализация:
1. Добавить адаптацию под разные размеры экранов
2. Реализовать плавные анимации переходов
3. Добавить haptic feedback
4. Создать темную/светлую темы

Изменения во всех UI компонентах
Время: 4-5 дней
```

#### 2.5.2 Система уведомлений (Приоритет: СРЕДНИЙ)
```
Цель: Информирование о важных событиях
Реализация:
1. Push уведомления через Telegram Bot API
2. In-app уведомления о завершении действий
3. Email уведомления для важных событий
4. Настройки уведомлений

Новые файлы:
- ton_crypto_farm_client/lib/core/services/notification_service.dart
- ton_crypto_farm_server/lib/services/notification_service.dart

Время: 3-4 дня
```

## ОБЩИЙ ПЛАН ВЫПОЛНЕНИЯ

### Фаза 1: Критические исправления (2-3 недели)
1. TonService исправления
2. TelegramService реализация
3. AuthMiddleware
4. Базовая навигация

### Фаза 2: Основной функционал (3-4 недели)
1. Система инвентаря
2. Крафтинг
3. Фарминг
4. Энергетическая система

### Фаза 3: Экономика и социальность (2-3 недели)
1. Маркетплейс
2. Достижения
3. Рефералы

### Фаза 4: Техническая стабильность (2 недели)
1. Кэширование и оффлайн
2. Безопасность
3. Аналитика

### Фаза 5: UI/UX полировка (1-2 недели)
1. Анимации и адаптивность
2. Уведомления
3. Финальное тестирование

**Общее время разработки: 10-14 недель**

Каждая фаза включает тестирование и отладку. Рекомендуется параллельная работа над клиентской и серверной частями.

## РЕКОМЕНДАЦИИ ПО ПРИОРИТИЗАЦИИ

### Первоочередные задачи (Неделя 1-2):
1. Исправить TonService - критично для работы с блокчейном
2. Реализовать TelegramService - критично для Telegram Mini App
3. Добавить базовую навигацию - критично для UX

### Средний приоритет (Неделя 3-6):
1. Система инвентаря и крафтинга
2. Фарминг ресурсов
3. Авторизация и безопасность

### Долгосрочные цели (Неделя 7-14):
1. Маркетплейс и экономика
2. Социальные функции
3. Аналитика и мониторинг

Этот план обеспечит поэтапное развитие проекта от базового функционала до полноценной игровой экосистемы.