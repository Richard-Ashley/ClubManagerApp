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
- [.NET 8 SDK](https://dotnet.microsoft.com/download) to run [ClubManagementApi](https://github.com/Richard-Ashley/ClubManagementApi)

### Running locally

This app talks to [ClubManagementApi](https://github.com/Richard-Ashley/ClubManagementApi). Start the API first. It applies its own migrations and seed data on startup:

```bash
git clone https://github.com/Richard-Ashley/ClubManagementApi.git
cd ClubManagementApi

# The API refuses to start without a signing key. Generate your own:
openssl rand -base64 64
dotnet user-secrets set "Jwt:Key" "<paste the generated key>"

dotnet run
```

The API listens on `http://localhost:5014` (and `https://localhost:7190`).

Then set `baseUrl` in `lib/core/constants/app_constants.dart` to match your target:

| Target | `baseUrl` |
|---|---|
| Android emulator | `http://10.0.2.2:5014` |
| iOS simulator | `https://localhost:7190` |
| Physical device | `http://YOUR_LOCAL_IP:5014` |

Then run the app:

```bash
git clone https://github.com/Richard-Ashley/ClubManagerApp.git
cd ClubManagerApp
flutter pub get
flutter run
```

## Screens

- **Login / Register** — JWT authentication
- **Home** — dashboard with quick stats
- **Venues** — browse venues and available slots
- **Bookings** — view and manage your bookings
- **New Booking** — select venue, slot, and date

## License

MIT
