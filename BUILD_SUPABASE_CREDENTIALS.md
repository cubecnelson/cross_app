# Building with Supabase Credentials

Supabase URL and anon key are compiled into the app at **build time** via `--dart-define`. They are read in `lib/core/config/supabase_config.dart`.

## Get credentials

1. Open [Supabase Dashboard](https://supabase.com/dashboard) → your project.
2. **Settings → API**
3. Copy **Project URL** and **anon public** (Project API keys).

## Local builds

### iOS (release)

```bash
flutter build ios --release --no-codesign \
  --dart-define=SUPABASE_URL="https://YOUR_PROJECT.supabase.co" \
  --dart-define=SUPABASE_ANON_KEY="YOUR_ANON_KEY"
```

### Android (release)

```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL="https://YOUR_PROJECT.supabase.co" \
  --dart-define=SUPABASE_ANON_KEY="YOUR_ANON_KEY"
```

### Run (debug)

```bash
flutter run \
  --dart-define=SUPABASE_URL="https://YOUR_PROJECT.supabase.co" \
  --dart-define=SUPABASE_ANON_KEY="YOUR_ANON_KEY"
```

Or use `./run_dev.sh` (edit the script to set your URL and key).

## CI (GitHub Actions)

These workflows already pass Supabase credentials into the build:

| Workflow | Step that injects credentials |
|----------|-------------------------------|
| `ios-release-automatic.yml` | **Build Flutter iOS** – `SUPABASE_URL`, `SUPABASE_ANON_KEY` from secrets, passed as `--dart-define` |
| `android-release.yml` | Build step – same env and `--dart-define` |

### Required GitHub secrets

- **SUPABASE_URL** – Project URL (e.g. `https://xxxxx.supabase.co`)
- **SUPABASE_ANON_KEY** – anon public API key

Add under: repo **Settings → Secrets and variables → Actions**.

If these secrets are missing, the iOS workflow fails at “Verify required secrets”; the Android workflow may use placeholders and the app will not connect to your project.

## Summary

| Context | How credentials are set |
|---------|---------------------------|
| Local build/run | `--dart-define=SUPABASE_URL=...` and `--dart-define=SUPABASE_ANON_KEY=...` (or `run_dev.sh` / IDE run args) |
| iOS CI | Secrets `SUPABASE_URL`, `SUPABASE_ANON_KEY` → env → `flutter build ios ... --dart-define=...` |
| Android CI | Same secrets → `flutter build apk ... --dart-define=...` |

Never commit real credentials; use GitHub Actions secrets in CI and keep them out of `.env` in version control.
