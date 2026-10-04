# Future Express

Arabic right-to-left courier app for shipment management, barcode scanning, pickup and delivery confirmation, reports, wallet, profile, and support. Shipment, home-summary, support-settings, and pickup flows integrate with the Future Express API.

## Run

Install the current Flutter stable SDK, then run:

```sh
flutter pub get
flutter run
```

Use `flutter analyze` and `flutter test` to check the Dart source and tests. The app supports Arabic (RTL) and English (LTR).

See [RELEASE.md](RELEASE.md) for Android and iOS release build preparation, signing, and remaining store-console requirements.

The Flutter source is organized by feature under `lib/features/`, with shared
widgets, localization, networking, and state under `lib/core/`. Arabic and
English strings are defined in `lib/core/l10n/`; brand assets are in `assets/`.
