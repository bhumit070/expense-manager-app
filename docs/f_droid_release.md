# Publishing on F-Droid

F-Droid doesn't take uploaded APKs. Its build server checks out a git tag of this repo, builds the app from source with its own Flutter, signs the APK with the F-Droid key and publishes it. Publishing therefore means three things:

1. The source must build without any non-free code.
2. The repo must say which version each tag is (so F-Droid can track updates).
3. A small recipe file (the "build metadata") is added to the [fdroiddata](https://gitlab.com/fdroid/fdroiddata) repository through a merge request.

Steps 1–3 are already done in this repo (version 0.2.0, tag `v0.2.0`). What's left is step 4 (test the recipe) and step 5 (submit).

---

## Step 1 — No Google Play Services (done)

F-Droid rejects apps that contain proprietary libraries. The only one was `geolocator_android` (Google's Fused Location Provider). It has been replaced:

- Android reads location through a small platform channel in `MainActivity.kt` (`expense_manager/location`) that uses the framework `LocationManager`: it waits up to 6 s for a fresh fix, then uses the newest known position.
- iOS still uses `geolocator_apple`; `lib/services/location.dart` picks the implementation per platform.
- `geocoding` uses the framework `android.location.Geocoder`, so it can stay.

Check it again after every dependency upgrade; it must print nothing:

```bash
cd android
./gradlew -q app:dependencies --configuration prodReleaseRuntimeClasspath | grep -iE "gms|firebase|play-services|com.google.android.play"
```

F-Droid's own scanner on a release APK must report no problems. It reported 985 problems before this change and 0 after:

```bash
fdroid scanner build/app/outputs/flutter-apk/app-prod-release.apk
```

## Step 2 — Put the version in the source and tag releases

F-Droid reads `versionName` and `versionCode` from `pubspec.yaml` **at the git tag** it builds:

```yaml
version: 0.2.0+2   # versionName + versionCode (current)
```

Today the GitHub workflow injects the build number from the run number, and `pubspec.yaml` stays at `+1`. For F-Droid:

1. Raise both parts in `pubspec.yaml` for every release you want on F-Droid. The `+N` must always go up. (The first F-Droid release is `0.2.0+2`.)
2. Commit, then create a plain tag that matches the version name and push it:

   ```bash
   git tag v0.2.0
   git push origin v0.2.0
   ```

   The existing `v0.1.0-build.N` tags from the GitHub workflow don't matter: the F-Droid recipe (step 4) only tracks tags shaped like `v1.2.3`.

> APKs from F-Droid are signed with F-Droid's key, and APKs from GitHub Releases with yours. Android won't update one over the other, so a user who switches source has to uninstall first (export a backup first!). Say this in the README.

## Step 3 — Store listing (done)

F-Droid shows the title, descriptions, icon, screenshots and changelog from `fastlane/metadata/android/` in this repo:

```
fastlane/metadata/android/en-US/
  title.txt
  short_description.txt          ≤ 80 chars
  full_description.txt           simple HTML
  images/icon.png                512×512, from assets/icon/icon_full.png
  images/phoneScreenshots/1–7.png  the golden screenshots in test/goldens
  changelogs/2.txt               what's new in versionCode 2 (≤ 500 chars)
```

For every release, add `changelogs/<versionCode>.txt`. When screens change, refresh the screenshots (`tool/goldens.sh --update`, then copy them across). Optional: translated listings in `fr-FR/`, `ja-JP/`, `hi-IN/`, `gu-IN/`, `or-IN/`. Missing files fall back to `en-US`.

## Step 4 — Write the build recipe and test it locally

### 4.1 Install the tools

```bash
# fdroidserver (macOS: brew install fdroidserver; Debian/Ubuntu: apt install fdroidserver)
pip install fdroidserver   # alternative

git clone https://gitlab.com/fdroid/fdroiddata.git
cd fdroiddata
fdroid init                # creates config.yml; point sdk_path at your Android SDK
```

Building locally works best on Linux, which is what the F-Droid server uses. On macOS, use the `registry.gitlab.com/fdroid/fdroidserver:buildserver` Docker image or a Linux VM.

### 4.2 Create `metadata/com.bhumit070.expense_manager.yml`

```yaml
Categories:
  - Finance Manager
License: MIT
AuthorName: bhumit070
SourceCode: https://github.com/bhumit070/expense-manager-app
IssueTracker: https://github.com/bhumit070/expense-manager-app/issues
Changelog: https://github.com/bhumit070/expense-manager-app/releases

AutoName: Expense Manager

RepoType: git
Repo: https://github.com/bhumit070/expense-manager-app.git

Builds:
  - versionName: 0.2.0
    versionCode: 2
    commit: v0.2.0
    output: build/app/outputs/flutter-apk/app-prod-release.apk
    srclibs:
      - flutter@3.44.0
    prebuild:
      - sed -i -e '/signingConfig = signingConfigs.getByName/d' android/app/build.gradle.kts
      - export PUB_CACHE=$(pwd)/.pub-cache
      - $$flutter$$/bin/flutter config --no-analytics
      - $$flutter$$/bin/flutter pub get
    scandelete:
      - .pub-cache
    build:
      - export PUB_CACHE=$(pwd)/.pub-cache
      - $$flutter$$/bin/flutter build apk --release --flavor prod

AutoUpdateMode: Version
UpdateCheckMode: Tags ^v\d+\.\d+\.\d+$
UpdateCheckData: pubspec.yaml|version:\s.+\+(\d+)|.|version:\s(.+)\+
CurrentVersion: 0.2.0
CurrentVersionCode: 2
```

Notes:

- The `sed` line in `prebuild` removes the debug-key fallback in `android/app/build.gradle.kts`, because F-Droid signs the APK itself. Don't put YAML comments in the recipe: `fdroid rewritemeta` strips them.
- `Categories` must come from fdroiddata's `config/categories.yml`; `Finance Manager` is the one for expense trackers.
- `flutter@3.44.0` must match `FLUTTER_VERSION` in `.github/workflows/release.yml` (and the version the tag was tested with).
- `--flavor prod` builds the real app ID `com.bhumit070.expense_manager`; the `dev` flavor (`.dev`) is never published.
- `versionName`/`versionCode`/`commit` must match the tag from step 2.
- Checked locally: with the signing line removed, `flutter build apk --release --flavor prod` writes an unsigned APK to `build/app/outputs/flutter-apk/app-prod-release.apk`, which is the `output:` above.
- The `UpdateCheck*` lines let F-Droid find new `vX.Y.Z` tags and read the version from `pubspec.yaml`, so later releases need no merge request (step 6).
- Anti-features: none expected. There are no ads, tracking or non-free dependencies (after step 1), and OpenStreetMap tiles are a free network service. Reviewers may still ask; answer in the merge request.

### 4.3 Check and build

```bash
fdroid readmeta                                  # parses all metadata
fdroid rewritemeta com.bhumit070.expense_manager # normalises formatting
fdroid lint com.bhumit070.expense_manager        # policy and style checks (passes for this recipe)
fdroid checkupdates --allow-dirty com.bhumit070.expense_manager   # finds the tag
fdroid build -v -l com.bhumit070.expense_manager # full build of the latest version
```

The build must finish without scanner errors. Install the resulting APK from `fdroiddata/tmp/` or `unsigned/` on a de-Googled phone or emulator and smoke-test it: onboarding, add a transaction, location, SMS capture, backup and restore, and switching language.

If the scanner flags a binary or a non-free class, fix it in this repo (preferred) or add a `scanignore`/`scandelete` entry with a reason the reviewer will accept.

## Step 5 — Submit to F-Droid

1. Create a GitLab account and **fork** https://gitlab.com/fdroid/fdroiddata.
2. In your fork, create a branch `com.bhumit070.expense_manager` and commit only `metadata/com.bhumit070.expense_manager.yml`.
3. Push. GitLab CI runs lint and a test build. Fix anything it reports.
4. Open a merge request to `fdroid/fdroiddata` `master` using the **"App inclusion"** template. Tick the checklist. In the description, mention:
   - the app is MIT licensed with no account, server or analytics
   - it asks for SMS, location and notification permissions only for opt-in features (see `docs/privacy-policy.md`)
   - Play Services was removed (step 1)
5. Answer reviewer comments in the MR. Expect a few rounds; review can take days to weeks.
6. After the merge, the app appears in the F-Droid client within a few days, once the next build cycle and index update have run.

Before sending, check the inclusion policy: https://f-droid.org/docs/Inclusion_Policy/

## Step 6 — Releasing updates

With the update lines from step 4.2, updates are automatic:

1. Bump `version:` in `pubspec.yaml` (raise `+N`).
2. Add `fastlane/metadata/android/en-US/changelogs/<N>.txt`.
3. Run `./tool/verify.sh`, commit and push to `main`.
4. Tag and push: `git tag vX.Y.Z && git push origin vX.Y.Z`.

F-Droid's checkupdates bot finds the tag (usually within a day), adds a `Builds` entry, builds it and publishes it. Re-run the Play Services grep from step 1 whenever dependencies change, because a new non-free dependency breaks the F-Droid build.

## Optional — Reproducible builds (your own signature on F-Droid)

If F-Droid can rebuild your APK bit-for-bit, it can ship **your** signed APK instead of re-signing. Then users can move between GitHub Releases and F-Droid without uninstalling. This needs a deterministic Flutter build (same Flutter, Gradle, JDK and build path) plus these lines in the recipe:

```yaml
    binary: https://github.com/bhumit070/expense-manager-app/releases/download/v%v/expense-manager-v%v.apk
AllowedAPKSigningKeys: <sha256 of your signing certificate>
```

Treat this as a later improvement. Get the regular inclusion merged first.

## Checklist

- [x] No `gms`/`firebase` in `prodReleaseRuntimeClasspath`; `fdroid scanner` clean (step 1)
- [x] `pubspec.yaml` at `0.2.0+2`; `v0.2.0` tag pushed (step 2)
- [x] `fastlane/metadata/android/en-US/` with texts, icon, screenshots and changelog (step 3)
- [ ] `fdroid lint` and `fdroid build` pass locally (step 4)
- [ ] Merge request opened on fdroiddata with the inclusion template (step 5)
- [x] README says F-Droid and GitHub APKs are signed differently
