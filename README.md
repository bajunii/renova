# ReNova
Project Description (SDG 11 – Sustainable Cities and Communities):
This project contributes to SDG 11 by promoting sustainable waste management practices that enhance urban living conditions. It focuses on reducing pollution, improving collection and recycling systems, and encouraging community participation in responsible waste disposal. By creating cleaner and more resilient cities, the project aims to ensure healthier environments, efficient resource use, and improved quality of life for all residents.


Renew + Innovate through recycling and art

## Project Structure
.
├── android
│   ├── app
│   └── gradle
├── assets
├── build
├── docs
├── ios
├── lib
│   ├── main.dart
│   ├── config
│   ├── core
│   │   ├── services
│   │   ├── theme
│   │   └── utils
│   ├── features
│   │   ├── auth
│   │   │   ├── pages
│   │   │   └── widgets
│   │   ├── business
│   │   │   ├── pages
│   │   │   └── widgets
│   │   ├── dashboard
│   │   │   ├── pages
│   │   │   └── widgets
│   │   ├── groups
│   │   │   ├── pages
│   │   │   └── widgets
│   │   └── members
│   │       ├── pages
│   │       └── widgets
│   ├── models
│   └── shared
│       ├── models
│       └── widgets
├── linux
├── macos
├── test
├── web
├── windows
├── pubspec.lock
├── pubspec.yaml
├── README.md
└──renova.iml            

## UI Consistency Changes

I added a few shared widgets to improve spacing, alignment and styling across the app:

- `lib/widgets/common/app_button.dart` — AppButton (primary/secondary/outlined) for consistent button styling and spacing.
- `lib/widgets/common/app_card.dart` — AppCard wrapper to enforce card padding, margin and corner radius.
- `lib/widgets/common/app_avatar.dart` — AppAvatar small helper for consistent avatars.
- `lib/widgets/common/app_theme.dart` — Small set of text styles used across screens.

I used these components to refactor `lib/screens/member_selection_screen.dart` and the sign-out action in `lib/widgets/auth_wrapper.dart` as a demonstration. Consider migrating other screens (dashboards, forms, and admin pages) to these shared widgets for a consistent UI.
