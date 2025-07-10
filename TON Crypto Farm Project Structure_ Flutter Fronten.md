<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" class="logo" width="120"/>

# TON Crypto Farm Project Structure: Flutter Frontend and Dart Backend

Based on the analysis of the attached documents and project requirements, here is a detailed structure for developing a TON blockchain crypto farm using Flutter for the frontend and Dart for the backend.

## Architecture Overview

The project consists of three main components:

- **Flutter Frontend** (Telegram Mini App) – User Interface
- **Dart Backend** (API Server) – Server logic with Firebase
- **TON Smart Contracts** – Blockchain logic


## Flutter Frontend Structure

### Main Project Structure

```
ton_farm_frontend/
├── lib/
│   ├── core/
│   │   ├── api/
│   │   ├── models/
│   │   ├── helpers/
│   │   ├── utils/
│   │   ├── constants/
│   │   └── services/
│   ├── pages/
│   ├── components/
│   ├── providers/
│   └── main.dart
├── web/
│   └── index.html (with Telegram script)
└── pubspec.yaml
```


### Key Files and Classes

#### `/lib/main.dart`

Purpose: Application initialization, setting up state providers and services.

#### `/lib/core/services/ton_service.dart`

Purpose: Integration with TON blockchain, wallet management, and transactions.

#### `/lib/core/services/api_service.dart`

Purpose: Interaction with backend API for game operations.

#### `/lib/core/services/telegram_service.dart`

Purpose: Integration with Telegram Mini Apps API.

#### `/lib/core/models/game_models.dart`

Purpose: Data models for game objects and API interaction.

#### `/lib/providers/game_provider.dart`

Purpose: Game state management, API interaction, and real-time updates.

#### `/lib/pages/game_dashboard.dart`

Purpose: Main game screen displaying resources, energy, and inventory.

## Dart Backend Structure

### Main Project Structure

```
ton_farm_backend/
├── bin/
│   └── server.dart
├── lib/
│   ├── controllers/
│   ├── models/
│   ├── services/
│   ├── repositories/
│   ├── middleware/
│   └── utils/
├── pubspec.yaml
└── .env
```


### Key Files and Classes

#### `/bin/server.dart`

Purpose: Server entry point with route and middleware setup.

#### `/lib/services/firebase_service.dart`

Purpose: Integration with Firebase for storing user data and game state.

#### `/lib/services/ton_service.dart`

Purpose: Integration with TON blockchain for reading contracts and preparing transactions.

#### `/lib/controllers/player_controller.dart`

Purpose: Controller for player operations, registration, and state management.

#### `/lib/controllers/game_controller.dart`

Purpose: Controller for game operations – crafting, farming, and balance retrieval.

#### `/lib/services/websocket_service.dart`

Purpose: Service for WebSocket connections and real-time updates.

#### `/lib/utils/recipe_calculator.dart`

Purpose: Utilities for calculating recipes, harvest, and repair according to the economic model.

## Dependencies

### Frontend (Flutter)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Telegram Mini App
  flutter_telegram_miniapp: ^0.0.9

  # TON Connect
  darttonconnect: ^1.0.3
  ton_dart: ^1.8.0

  # State Management
  provider: ^6.0.5

  # HTTP & WebSocket
  http: ^0.13.5
  web_socket_channel: ^2.4.0

  # UI
  flutter_svg: ^2.0.7
  lottie: ^2.6.0

  # Utils
  shared_preferences: ^2.2.0
  intl: ^0.18.1
```


### Backend (Dart)

```yaml
dependencies:
  # Server
  shelf: ^1.4.1
  shelf_router: ^1.1.4
  shelf_cors_headers: ^0.1.5
  shelf_web_socket: ^1.0.4

  # TON
  ton_dart: ^1.8.0

  # Firebase
  firebase_dart: ^1.4.3

  # Utils
  dotenv: ^4.0.1
  crypto: ^3.0.3

dev_dependencies:
  test: ^1.21.0
```


## Conclusion

This structure provides:

- **Complete coverage of communication cycles** according to the attached documents
- **Integration with TON blockchain** via `darttonconnect` and `ton_dart`
- **Support for Telegram Mini Apps** via `flutter_telegram_miniapp`
- **Data storage in Firebase** for users and game state
- **Real-time updates** via WebSocket
- **Scalability** for 5000 online users

Each component has clear responsibilities and can be developed independently, allowing this structure to be used as a roadmap for step-by-step project development.

**A translated .dm file has been generated as `TON_Farm_Project_Structure.dm`.**

<div style="text-align: center">⁂</div>

[^1]: Struktura-proekta-TON-dlia-razrabotki-FINAL.md

[^2]: https://ppl-ai-code-interpreter-files.s3.amazonaws.com/web/direct-files/15d2e24177e10a1007a1019f9f3c82fc/59233846-0fa1-4d3d-a634-c07733fa2390/bb1e9ef3.dm

