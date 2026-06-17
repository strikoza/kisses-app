# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Cross-platform Flutter app (a personal pet project) that tracks "kiss" and "sex" activities, showing them on a calendar and in pie-chart statistics. Data is stored locally on-device; there is no backend. Targets Android, iOS, web, Linux, macOS, and Windows.

## Commands

```bash
flutter pub get                    # install dependencies
flutter run                        # run on the default attached device
flutter run -d chrome              # run on web (also: -d linux, -d macos, etc.)
flutter analyze                    # lint (uses flutter_lints via analysis_options.yaml)
dart format lib/ test/             # format
flutter test                       # run all tests
flutter test test/migration_test.dart            # run a single test file
flutter test --name "round-trips"                # run a single test by name
flutter gen-l10n                   # regenerate localization Dart from .arb files
flutter build apk                  # release build (also: appbundle, ios, web, linux, ...)
```

## Architecture

The app is split by responsibility under `lib/`:

- `main.dart` — `main()` + the `KissesApp` `MaterialApp` only.
- `models/` — `activity_record.dart` (`ActivityType`, `ActivityRecord`, legacy-data migration) and `subtypes.dart` (subtype enums, key lists, label lookup).
- `state/app_state.dart` — the single `AppState extends ChangeNotifier`, provided at the root in `main()`. Screens read it with `context.watch` / `context.select` / `context.read`.
- `screens/` — `main_screen.dart` (the `NavigationBar` shell), `tracker_screen.dart`, `calendar_history_screen.dart`, `stats_screen.dart`, `settings_screen.dart`.
- `widgets/` — small reusable pieces shared by the add/edit sheets (`orgasm_stepper.dart`, `subtype_dropdown.dart`).
- `l10n/` — `.arb` sources plus the committed generated `app_localizations*.dart`.

- **Persistence**: `shared_preferences`. Records are JSON-encoded as a list under the key `kisses_app_data`; settings live under `setting_animation`, `setting_sound`, `setting_language` (keys are constants in `AppState`). Every mutating `AppState` method calls `_saveData()`/`_saveSettings()` then `notifyListeners()`.
- **Data model**: `ActivityRecord` (`id`, `date`, `ActivityType.kiss|sex`, `subtype`, `orgasmCount`). `id` is a microsecond timestamp + random suffix. Sound playback lives in `AppState.playActivitySound` (one reusable `AudioPlayer`, disposed in `AppState.dispose`).

### Localization

- **Subtypes are stable, locale-independent keys.** `ActivityRecord.subtype` stores an enum name (e.g. `'tender'`, `'vaginal'`) defined by `KissSubtype`/`SexSubtype` in `models/subtypes.dart` — never display text. The enums are the single source of truth for the lists shown in the tracker and the calendar edit sheet (`subtypeKeysFor`).
- **Display** goes through `subtypeLabel(loc, key)` (`models/subtypes.dart`), which maps a key to a generated `AppLocalizations` getter. All user-facing strings — including subtype labels and the version easter egg — live in the `.arb` files.
- **Legacy migration**: older builds stored subtypes as Ukrainian display strings. `normalizeSubtypeKey` (driven by `legacySubtypeKeys`) converts them to keys inside `ActivityRecord.fromJson`; `AppState._loadData` re-saves once after decoding so data persists in the new format. Update `legacySubtypeKeys` if old strings ever change.
- **`.arb` workflow**: `app_uk.arb` is the template / source language (set in `l10n.yaml`); Ukrainian is the default. Supported locales are `uk` and `en`. After editing any `.arb`, run `flutter gen-l10n` and commit the regenerated `app_localizations*.dart` (they are tracked, not gitignored). `KissesApp` forces a full `MaterialApp` rebuild on language change via `key: ValueKey(state.languageCode)`.

## Conventions

- Code comments are in English.
- Use the modern Flutter color API (`Color.withValues(alpha: …)`, `color.a`) rather than the deprecated `withOpacity`/`.opacity`.
- The GitHub link in `SettingsScreen` points at `github.com/strikoza/kisses-app`.
