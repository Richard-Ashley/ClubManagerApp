# Club Manager App

A Flutter mobile app for managing club venues and bookings — connects to the [Club Management API](https://github.com/Richard-Ashley/ClubManagementApi).

## Tech stack

- **Flutter 3.x** — cross-platform mobile UI
- **Riverpod** — state management & dependency injection
- **GoRouter** — declarative navigation with auth guards
- **Dio** — HTTP client with JWT interceptor
- **flutter_secure_storage** — secure JWT persistence
- **Freezed + json_serializable** — immutable models & JSON parsing

## Architecture

Clean architecture with feature-first folder structure:

```
lib/
├── core/           # App-wide infrastructure
│   ├── network/    # Dio client, interceptors, endpoints
│   ├── storage/    # Secure token storage
│   ├── router/     # GoRouter + auth guard
│   ├── providers/  # Core Riverpod providers
│   └── constants/  # Theme, colors, app constants
├── shared/         # Reusable UI + helpers
│   ├── widgets/    # AppButton, AppTextField, ErrorView...
│   ├── validators/ # Form validators
│   └── extensions/ # Dart extension methods
└── features/
    ├── auth/       # Login, register
    ├── venues/     # Venue list, detail, slots
    ├── bookings/   # My bookings, new booking
    └── members/    # Member profile
```

## Getting started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.x
- Running instance of [ClubManagementApi](https://github.com/Richard-Ashley/ClubManagementApi)

### Setup

```bash
git clone https://github.com/Richard-Ashley/ClubManagerApp.git
cd ClubManagerApp
flutter pub get
flutter run
```

Update `lib/core/constants/app_constants.dart` with your API base URL.

## Screens

- **Login / Register** — JWT authentication
- **Home** — dashboard with quick stats
- **Venues** — browse venues and available slots
- **Bookings** — view and manage your bookings
- **New Booking** — select venue, slot, and date

## License

MIT
