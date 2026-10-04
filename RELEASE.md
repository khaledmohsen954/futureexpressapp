# Store release preparation

## App identity and version

- Android application ID: `com.future.express.v3`
- iOS bundle ID: `com.future.express.v3`
- Launcher display name: `Future Express`
- Version and build number come from `version` in `pubspec.yaml`. Increase the
  build number for every upload; store uploads must use a version not already
  submitted.
- The iOS project currently uses Apple Development Team `3Q8G45WV7L`. Verify
  that this is the intended team and that the App ID is registered to it before
  archiving.

## Android App Bundle

Create and securely back up an upload keystore. Do not commit the keystore or
passwords. Copy `android/key.properties.example` to
`android/key.properties`, replace every placeholder, and put the keystore at
the configured path (or change `storeFile` to its path relative to `android/`).
Both files are excluded from Git.

Build the Play upload artifact:

```sh
flutter pub get
flutter test
flutter build appbundle --release
```

The artifact is `build/app/outputs/bundle/release/app-release.aab`. Release
builds intentionally fail instead of falling back to the Android debug key if
signing is not configured.

## iOS archive

On macOS with Xcode installed, verify the Apple Developer team, registered
bundle ID, certificates, and App Store provisioning in Xcode. Then archive
`ios/Runner.xcworkspace` with the **Runner** scheme and **Any iOS Device
(arm64)** destination, or run:

```sh
flutter pub get
flutter test
flutter build ipa --release
```

Automatic signing is enabled in the Xcode project and the project has a
configured development team. The Apple account must have permission to sign
and upload for that team. The IPA output is under `build/ios/ipa/`.

## Before submitting to either store

The source tree cannot create store listings or complete account/legal
declarations. In Google Play Console and App Store Connect, complete and verify:

- App listing name, description, category, support contact, and localized
  Arabic/English listing text.
- Current screenshots and any store-required promotional artwork.
- A publicly accessible privacy policy URL and the applicable privacy/data
  safety declarations. Accurately disclose camera use for barcode scanning and
  shipment evidence, and location use for shipment status updates; confirm the
  backend's retention and processing practices with the service owner.
- App access instructions and reviewer credentials for sign-in-protected
  courier features.
- Age/content rating, export compliance, regional availability, and release
  track settings.
- Successful review of the production API environment, permissions, app icon,
  and a release build on supported physical devices.
- The map uses OpenStreetMap's community tile endpoint and visibly attributes
  map data. Review the current tile usage policy and switch to a suitable
  hosted tile provider if the app's usage volume or product needs exceed the
  community service's intended use.

Do not upload a release until the privacy disclosures and reviewer access
details match the production behavior.
