# OnTheRack

Crowdsourced inventory and reviews of **gym equipment** at different gyms.

> **See what’s on the floor before you go.**

The unit of review is a machine, rack, cardio unit, or free-weight setup *at a gym* — not a generic star rating for the venue. Hong Kong first, not Hong Kong only. A personal project by [Nelson Cheung](https://github.com/cubecnelson).

This Flutter app lives in the existing **`cubecnelson/cross_app`** repository (the GitHub repo name is unchanged). It replaces the previous Cross workout-tracker product in this codebase. Git history is preserved.

**This is not official gym data.** OnTheRack has no partnership with any chain, club, or government operator (including LCSD). Listings and ratings are user-generated and may be incomplete, outdated, or wrong. Seeded rows are labelled **Sample data**. Always confirm hours and access with the venue.

中文簡介：OnTheRack 係一個眾包平台，用家可以為唔同健身室嘅**器材**（唔係成間 gym）寫狀況同等候評分。香港為先，但唔限香港。資料由用家提供，唔代表任何場地或連鎖嘅官方資訊。

## Marketing site

The GitHub Pages landing page (source in `docs/`) describes OnTheRack:

**https://cubecnelson.github.io/cross_app/**

A separate Next.js web MVP also exists in the private `cubecnelson/ontherack` repo.

## Features (v1)

- Browse gyms without an account (search by name / address / chain, filter by Hong Kong district)
- Gym pages with equipment lists and aggregate condition ratings
- Equipment pages with chronological reviews (condition 1–5, availability / wait, optional comment and “last seen working”)
- Sign up / log in with a username and password (stored locally on device)
- Add a gym, add equipment (optional photo URL), write a review, upvote a review
- Hong Kong sample gyms, equipment, and reviews so the UI is not empty
- Dark mode
- Mobile-first Flutter UI for iOS and Android

Write actions require login. Read-only browsing does not.

## How to run

```bash
git clone https://github.com/cubecnelson/cross_app.git
cd cross_app
flutter pub get
flutter run
```

You can also run `flutter run -d chrome` or `flutter run -d linux` if those devices are available. Flutter 3.38.7 is the version pinned in `.fvmrc`; any current Flutter 3.x SDK in the project’s Dart range should work. Do not need a Supabase project for v1 browsing and local writes.

### Optional Supabase

The previous Cross app used Supabase (email / Google / Apple). Those packages and `lib/core/config/supabase_config.dart` are still in the tree. If you pass real values:

```bash
flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

Supabase is initialized only when those values are set. **Gym, equipment, and review data are not stored in Supabase in this pass** and are never written to Cross workout tables. Catalog data lives in local Hive boxes.

Do not commit `.env` files or real API keys.

### Sample accounts

Password for all: `ontherack-demo`

- `mei`
- `alex`
- `kwok`

The seed user `ontherack_seed` is the “added by” account for sample gyms and equipment.

### Seed data

Four **sample** Hong Kong gyms (fictional or clearly labelled; ratings are not official):

| Gym | District | Notes |
| --- | --- | --- |
| Peak Club Central | Central | Pure-style chain *stand-in* (fictional) |
| Sha Tin Sports Centre | Sha Tin | LCSD-style public sports centre (sample, not official LCSD data) |
| IronHour 24 Mong Kok | Mong Kok | Fictional 24-hour gym |
| East Box Kwun Tong | Kwun Tong | Fictional independent box |

Plus 12 equipment items and a handful of reviews. Every seeded gym, item, and review has `isSample: true` and shows a **Sample data** badge. Re-applying the seed inserts missing sample rows only; it does not delete user-contributed data.

## Identifiers left unchanged

To avoid breaking signing and CI in this first pass:

- GitHub repository name remains `cross_app`
- Dart package name in `pubspec.yaml` remains `cross` (imports are still `package:cross/...`)
- iOS bundle identifier remains `com.cross.app`
- Android `applicationId` remains `com.cross.app` / `com.cross.cross` as already present in the Gradle files
- Existing app icons, launcher icons, and `AppIcons/` assets are unchanged

User-visible display names were updated to **OnTheRack** (`android:label`, iOS `CFBundleDisplayName` / `CFBundleName`, app title, package description, README, and the Pages site).

## Project structure (OnTheRack)

```
lib/
├── main.dart
├── app.dart
├── core/                    # theme, Supabase config, constants
├── data/                    # HK districts + sample seed
├── models/                  # gym, equipment, review, session
├── services/                # Hive/memory catalog + local auth
├── providers/               # Riverpod
├── features/
│   ├── gyms/
│   ├── equipment/
│   ├── reviews/
│   ├── account/
│   └── home/
└── widgets/
```

Older Cross workout-tracker screens (routines, ACWR, VBT, achievements, Shorebird update prompts, and so on) remain in the tree but are not referenced by the running app.

## Tests

```bash
flutter pub get
flutter analyze
flutter test
```

## Disclaimer

OnTheRack does not guarantee accuracy, completeness, or availability of any venue or machine. Do not treat reviews as safety, maintenance, or access advice. Users are responsible for what they post.

## Later ideas

- Sync the catalog to a shared backend (without touching Cross production tables)
- Proper maps (pins, nearby search)
- New app icons and store listings under OnTheRack branding
- Changing bundle / application IDs when ready for store release
- Traditional Chinese UI

## License

See the repository’s existing license files. Copyright (c) 2026 Nelson Cheung.
