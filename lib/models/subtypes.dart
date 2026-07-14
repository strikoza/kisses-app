import '../l10n/app_localizations.dart';

/// Locale-independent keys for kiss subtypes.
///
/// The enum name (e.g. `tender`) is what gets persisted in
/// `ActivityRecord.subtype`; display text is resolved at runtime via
/// [subtypeLabel] so storage never couples to the UI language.
enum KissSubtype { tender, passionate, smallKiss, frenchKiss, reluctant }

/// Locale-independent keys for intimacy subtypes.
enum SexSubtype { vaginal, oralCuni, oralBlowjob }

/// Canonical, ordered kiss subtype keys (single source of truth for the UI).
final List<String> kissSubtypeKeys =
    KissSubtype.values.map((e) => e.name).toList(growable: false);

/// Canonical, ordered intimacy subtype keys.
final List<String> sexSubtypeKeys =
    SexSubtype.values.map((e) => e.name).toList(growable: false);

/// Maps legacy Ukrainian subtype strings (stored before the key-based
/// redesign) to their stable keys. Applied once when decoding old records.
const Map<String, String> legacySubtypeKeys = {
  'Ніжний': 'tender',
  'Пристрасний': 'passionate',
  'Маленький цьом': 'smallKiss',
  'З язиком': 'frenchKiss',
  'Цьом ніби не любить': 'reluctant',
  'Вагінальний': 'vaginal',
  'Оральний (куні)': 'oralCuni',
  'Оральний (мінет)': 'oralBlowjob',
};

/// Normalizes a stored subtype value to its stable key, translating any legacy
/// Ukrainian string. Unknown/custom values pass through unchanged.
String normalizeSubtypeKey(String stored) => legacySubtypeKeys[stored] ?? stored;

/// Resolves a subtype key to its localized display label.
/// Unknown/custom keys fall back to the raw key.
String subtypeLabel(AppLocalizations loc, String key) {
  switch (key) {
    case 'tender':
      return loc.subtypeTender;
    case 'passionate':
      return loc.subtypePassionate;
    case 'smallKiss':
      return loc.subtypeSmallKiss;
    case 'frenchKiss':
      return loc.subtypeFrenchKiss;
    case 'reluctant':
      return loc.subtypeReluctant;
    case 'vaginal':
      return loc.subtypeVaginal;
    case 'oralCuni':
      return loc.subtypeOralCuni;
    case 'oralBlowjob':
      return loc.subtypeOralBlowjob;
    default:
      return key;
  }
}
