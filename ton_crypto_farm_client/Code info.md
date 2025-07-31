# Структура взаимодействия клиента и сервера

## Основные сущности:
- Клиент (Flutter-приложение)
- Сервер (API, Telegram, TON Connect)

## Передаваемая информация:
- Запросы на авторизацию (TON Connect, Telegram)
- Запросы на получение/отправку игровых данных (ресурсы, инвентарь, действия)
- Получение состояния игры, баланса, инвентаря

## Получаемая информация:
- Статус авторизации
- Список ресурсов, инструментов, баланса
- Ответы на игровые действия

---

# Список основных классов и их методов

## GameProvider (providers/game_provider.dart)
- loadGameData()
- updateResource()
- updateInventory()
- notifyListeners()
- Взаимодействует с: ApiService, UI-компонентами

## ApiService (core/services/api_service.dart)
- fetchResources()
- fetchInventory()
- sendAction()
- Взаимодействует с: GameProvider

## TelegramService (core/services/telegram_service.dart)
- init()
- getUserInfo()
- Взаимодействует с: main.dart, возможно с ApiService

## TonConnectService (core/services/ton_connect_service.dart)
- initialize()
- getAvailableWallets()
- connectWallet()
- disconnect()
- sendTransaction()
- getBalance()
- Взаимодействует с: UI, возможно с ApiService

## WalletConnectWidget (components/wallet_connect_widget.dart)
- build()
- _connectWallet()
- _disconnectWallet()
- Взаимодействует с: TonConnectService

## ResourceDisplay (components/resource_display.dart)
- build()
- Взаимодействует с: GameProvider

## ToolInventory (components/tool_inventory.dart)
- build()
- Взаимодействует с: GameProvider

---

# Классы и методы с незаконченной логикой

- TonConnectService:
    - sendTransaction() — требует реализации отправки транзакций
    - getBalance() — требует реализации получения баланса

- ApiService:
    - sendAction() — возможно требует доработки для всех игровых действий

- GameProvider:
    - updateResource() — возможно требует расширения для всех типов ресурсов
    - updateInventory() — возможно требует расширения для всех инструментов

---

# Взаимодействие между классами

- GameProvider <-> ApiService (загрузка и обновление данных)
- WalletConnectWidget <-> TonConnectService (авторизация, подключение кошелька)
- ResourceDisplay, ToolInventory <-> GameProvider (отображение состояния)
- main.dart <-> TelegramService (инициализация)