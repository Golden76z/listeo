# Listeo — Store Release Audit

_Audited 2026-06-15 against the current `main` source. App is a local-only Flutter grocery-list app (Provider + `shared_preferences`, no network calls, no accounts, no third-party SDKs). That makes the privacy story easy, but several blockers remain._

Legend: 🔴 blocker (store will reject or you can't ship) · 🟠 high · 🟡 medium · ⚪ low/cleanup

---

## 🔴 Blockers — fix before any upload

### 1. Android release build is signed with the debug key
`android/app/build.gradle.kts`:
```kotlin
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("debug")  // ← Play Store will reject this
    }
}
```
You must create an **upload keystore** and wire it up:
1. `keytool -genkey -v -keystore ~/listeo-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
2. Create `android/key.properties` (and add it to `.gitignore` — never commit it):
   ```
   storePassword=...
   keyPassword=...
   keyAlias=upload
   storeFile=/absolute/path/listeo-upload.jks
   ```
3. Load it in `build.gradle.kts` and set `release { signingConfig = signingConfigs.getByName("release") }`.
4. Back up the keystore + passwords somewhere safe. Lose it and you can't update the app (unless enrolled in Play App Signing, which you should also enable).

### 2. Final package / bundle identifier is a placeholder
Both platforms use `com.golden76z.listeo` (a personal GitHub-handle namespace), and `build.gradle.kts` still carries the template `// TODO: Specify your own unique Application ID`.
**This ID is permanent — it can never be changed after the first publish on either store.** Decide now on a real reverse-domain ID (e.g. `com.yourdomain.listeo`) and apply it to:
- Android `applicationId` and `namespace`
- iOS `PRODUCT_BUNDLE_IDENTIFIER` (and the `.RunnerTests` variant)

### 3. No privacy policy / store data-disclosure
Both stores require this even for a fully offline app:
- **Privacy policy URL** — mandatory field on both stores. Host a simple page (can state "all data stays on your device, nothing is collected").
- **Google Play Data Safety form** — must be completed; you'll declare "no data collected/shared."
- **Apple Privacy Nutrition labels** — declare "Data Not Collected."

### 4. Developer accounts & iOS signing
- **Google Play Console** account ($25 one-time).
- **Apple Developer Program** ($99/year) — required to ship to the App Store at all.
- iOS signing is currently `CODE_SIGN_STYLE = Automatic` with **no `DEVELOPMENT_TEAM` set**. You'll need to set your team and a distribution provisioning profile in Xcode before archiving.

---

## 🟠 High priority

### 5. Launcher-icon regeneration is broken
`pubspec.yaml` points `flutter_launcher_icons` at `assets/icon/listeo.png`, but the file on disk is `assets/icon/listeo.jpg`. Generated icons currently exist in the project, but `dart run flutter_launcher_icons` will fail until the path matches. Fix the path (and note iOS icons must have no alpha — a JPEG satisfies that, but PNG is the conventional source).

### 6. App display names / metadata are inconsistent or still template defaults
- Android `android:label="listeo"` (lowercase) — set to `Listeo` for the on-device name.
- `web/manifest.json` still has `"name": "listeo"` and `"description": "A new Flutter project."` with the default Flutter blue `#0175C2` theme/background colors. Update if you ever ship web; harmless otherwise but looks unfinished.
- iOS `CFBundleName` is `listeo` but `CFBundleDisplayName` is `Listeo` (the latter is what users see) — OK, but worth aligning.

### 7. iOS export-compliance flag missing
Add to `ios/Runner/Info.plist` to skip the encryption-compliance prompt on every TestFlight/App Store upload (true since the app uses no non-exempt encryption):
```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

### 8. Verify Android target API level
`build.gradle.kts` inherits `flutter.targetSdkVersion`. Google Play currently requires apps to **target API 35 (Android 15)**. Confirm your Flutter SDK's default targets 35; if not, set `targetSdk = 35` explicitly. (`flutter --version` / `flutter doctor` to check.)

---

## 🟡 Medium

### 9. Screen orientation
iOS `Info.plist` allows landscape (and upside-down on iPad). The UI looks designed for portrait. Decide and lock orientations on both platforms so the layout isn't tested/broken in landscape, or confirm landscape is intentionally supported.

### 10. Store-listing assets (not in repo yet)
You'll need, per store: localized title + short/long descriptions (FR + EN, matching the app's bilingual support), screenshots for each required device class (phone + tablet/iPad; iPhone 6.7" and 6.5" sizes for App Store), a Play **feature graphic** (1024×500), the 512×512 Play icon and 1024×1024 App Store icon, a category, and answers to the **content-rating / age questionnaire**.

### 11. Run the quality gates before building
Flutter isn't installed in this audit sandbox, so I couldn't execute them. Before release run:
- `flutter analyze` — note `analysis_options.yaml` suppresses `use_build_context_synchronously` (`errors: ... ignore`). That lint catches real crashes from using a `BuildContext` after an `await`; with 30+ sheet/async flows it's worth turning back on and fixing rather than silencing.
- `flutter test` — 10 test files are present (good); make sure they pass.
- `flutter build appbundle --release` and `flutter build ipa --release` to confirm clean release builds.

---

## ⚪ Low / cleanup

- **Stray dev artifacts in repo root**: `scratch/`, `scratch_keys.json`, `screenshot_current.png`, `screenshot_profile.png`, `screenshot_list_details_en.png`, `preview1.png`, `preview2.png`. Remove or move out before tagging a release.
- **README is stale**: it says the platform folders aren't committed and that fonts are fetched at runtime via `google_fonts`/network. In reality the platform folders exist and Quicksand `.ttf` files are now bundled in `pubspec.yaml` — so the app is fully offline (a plus). Update the docs.
- **Version**: `1.0.0+1` is fine for a first release. Remember to bump the `+N` build number on every store upload.
- **No `print`/`debugPrint` left in `lib/`** ✅ and no hardcoded secrets/keys ✅ — good.

---

## Suggested order of attack
1. Decide final bundle ID → apply everywhere (#2).
2. Create upload keystore + signing config (#1); enroll in Play App Signing.
3. Set up Apple Developer team + iOS distribution signing (#4).
4. Write & host privacy policy; complete Data Safety + Apple privacy labels (#3).
5. Fix icon path (#5), display names (#6), add iOS encryption flag (#7), confirm target API 35 (#8).
6. Lock orientations (#9); run analyze/test/release builds (#11).
7. Produce listing assets (#10); clean repo (#cleanup).
8. Upload to internal testing track / TestFlight before public release.
