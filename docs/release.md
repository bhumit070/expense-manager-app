# Releasing

Every push to `main` that touches code or build inputs runs `.github/workflows/release.yml`:
verify (format, analyze, tests, 100% coverage) → build Android (`--flavor prod`) and iOS (`FLAVOR=prod`) → publish a GitHub Release tagged `v<version>-build.<run>` with whatever built. Use **Actions → Release → Run workflow** to force one.

Bump the user-facing version in `pubspec.yaml` (`version: 0.2.0+1`); the build number comes from the run number.

## GitHub secrets the workflow reads

All are optional — without them the APK is debug-signed and the IPA is unsigned.

| Secret | Used for |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | `base64 -i upload-keystore.jks` |
| `ANDROID_KEYSTORE_PASSWORD` | keystore password |
| `ANDROID_KEY_ALIAS` | key alias (e.g. `upload`) |
| `ANDROID_KEY_PASSWORD` | key password |
| `IOS_CERTIFICATE_P12_BASE64` | Apple Distribution certificate exported as .p12, base64 |
| `IOS_CERTIFICATE_PASSWORD` | .p12 password |
| `IOS_PROVISIONING_PROFILE_BASE64` | App Store (or Ad Hoc) profile for `com.bhumit070.expenseManager`, base64 |
| `IOS_EXPORT_OPTIONS_PLIST_BASE64` | `ExportOptions.plist` with `method` = `app-store-connect` (or `ad-hoc`), `teamID`, and the profile mapping, base64 |

Create the Android upload key once:

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Keep it (and its passwords) somewhere safe; losing it means you can't update the Play listing without a key reset.

## Play Console — internal testing

1. Create the app in Play Console (Finance, Free). Complete **App content**: privacy policy URL (publish `docs/privacy-policy.md`), Data safety = no data collected, content rating questionnaire, target audience 18+, no ads.
2. Enrol in **Play App Signing** (default) and use the upload key above.
3. Play requires an **AAB** for store tracks: `flutter build appbundle --release --flavor prod` → `build/app/outputs/bundle/prodRelease/app-prod-release.aab`.
4. **Testing → Internal testing → Create release**, upload the AAB, add release notes, add testers (email list), roll out.
5. Store listing text and screenshots: [`docs/store-listing.md`](store-listing.md).

## TestFlight

1. In the Apple Developer portal register the bundle ID, create an **Apple Distribution** certificate and an **App Store** provisioning profile; add them as the iOS secrets above. Set the team in Xcode (`ios/Runner.xcodeproj`) or via `DEVELOPMENT_TEAM`.
2. In App Store Connect create the app (Finance), fill **App Privacy** = Data Not Collected, and the listing from `docs/store-listing.md`.
3. Build: `flutter build ipa --release --dart-define=FLAVOR=prod --export-options-plist=ExportOptions.plist` (CI does this when the secrets exist).
4. Upload with **Transporter** or `xcrun altool --upload-app -f build/ios/ipa/*.ipa -t ios --apiKey <key> --apiIssuer <issuer>`.
5. In TestFlight add internal testers; the build appears after processing (~15 min). Answer the export-compliance question: the app uses no non-exempt encryption.

## Splash screen and icons

- Icons: `dart run flutter_launcher_icons` (revert `ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS` if it rewrites it in `project.pbxproj`).
- Splash (light + dark): `dart run flutter_native_splash:create`, config in `pubspec.yaml`, images in `assets/splash/`. It also adds `UIStatusBarHidden` to `Info.plist` — revert that.
