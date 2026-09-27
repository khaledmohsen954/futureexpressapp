# Future Express — Flutter UI

Arabic right-to-left courier app recreated from [the Figma design](https://www.figma.com/design/jBbYSrD2drww71I7t1oxXQ/Future-expressapp?node-id=0-1). Twelve design states are represented by login, dashboard, shipment filters and expanded details, daily report and send form, wallet, profile, pickup, delivery failure, and support. All data and actions are local examples; there is no API integration.

## Run

Install the current Flutter stable SDK, then run:

```sh
flutter create --platforms=android,ios,web .
flutter pub get
flutter run
```

The `flutter create` command generates platform runners for the installed stable SDK while keeping the existing `lib`, `assets`, and `pubspec.yaml`. Use `flutter analyze` and `flutter build web` to check the Dart source and build a preview. GitHub Actions runs these checks on every push. Sign in with any nonempty phone number and password for the UI preview.

## Structure and Figma mapping

Each screen has its own file. Widgets used by several screens live in `lib/core/widgets/`; shipment records and cards live under `lib/features/shipments/`.

| Figma node | Screen or state | Implementation |
| --- | --- | --- |
| 11:2 | Login | `lib/features/auth/login_screen.dart` |
| 11:23 | Home | `lib/features/home/home_screen.dart` |
| 11:78 | All shipments | `lib/features/shipments/all_shipments_view.dart` |
| 11:131 | Pending shipments | `lib/features/shipments/pending_shipments_view.dart` |
| 11:184 | Expanded shipment | `lib/features/shipments/widgets/shipment_details.dart` |
| 11:250 | Daily report | `lib/features/reports/report_screen.dart` |
| 11:288 | Send report | `lib/features/reports/send_report_screen.dart` |
| 11:326 | Wallet | `lib/features/wallet/wallet_screen.dart` |
| 11:359 | Profile | `lib/features/profile/profile_screen.dart` |
| 11:398 | Pickup | `lib/features/pickup/pickup_screen.dart` |
| 11:428 | Delivery failure | `lib/features/pickup/delivery_failure_screen.dart` |
| 11:465 | Support | `lib/features/support/support_screen.dart` |

`lib/features/shipments/data/sample_shipments.dart` contains sample content; `models/shipment.dart` contains the data shape and status labels. `lib/features/reports/widgets/` holds the report row shared by the two report screens. `assets/auth/` contains the supplied logo; `pubspec.yaml` registers its path.

The supplied Future Express logo is bundled in `assets/auth/future_express_logo.png`. Tajawal typography is provided by `google_fonts` when fonts are available; for offline production use, bundle the Tajawal font files. The new Saudi Riyal sign uses Unicode U+20C1 and needs a font with that glyph on the target device.
