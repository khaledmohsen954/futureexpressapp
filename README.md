# Future Express — Flutter UI

Arabic right-to-left courier app recreated from [the Figma design](https://www.figma.com/design/jBbYSrD2drww71I7t1oxXQ/Future-expressapp?node-id=0-1). Twelve design states are represented by login, dashboard, shipment filters and expanded details, daily report and send form, wallet, profile, pickup, delivery failure, and support. All data and actions are local examples; there is no API integration.

## Run

Install the current Flutter stable SDK, then run:

```sh
flutter create --platforms=android,ios,web .
flutter pub get
flutter run
```

The `flutter create` command generates platform runners for the installed stable SDK while keeping the existing `lib`, `assets`, and `pubspec.yaml`. Use `flutter analyze` to check the Dart source. Sign in with any nonempty phone number and password for the UI preview.

## Structure

- `lib/core`: theme, shared cards, buttons, currency widget
- `lib/features/auth`: local sign-in
- `lib/features/home`: dashboard and navigation shell
- `lib/features/shipments`: filtering and expandable shipment details
- `lib/features/reports`: daily report and send flow
- `lib/features/wallet`: balances and transaction history
- `lib/features/profile`: courier details and sign-out
- `lib/features/pickup`: scan preview and failed delivery form
- `lib/features/support`: support contact preview

The supplied Future Express logo is bundled in `assets/images/logo.png`. Tajawal typography is provided by `google_fonts` when fonts are available; for offline production use, bundle the Tajawal font files. The new Saudi Riyal sign uses Unicode U+20C1 and needs a font with that glyph on the target device.
