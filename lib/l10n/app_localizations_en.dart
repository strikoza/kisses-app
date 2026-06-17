// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get trackerTitle => 'Tracker';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get kissesLabel => 'Kisses';

  @override
  String get sexLabel => 'Intimacy';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get generalSection => 'General';

  @override
  String get animationSwitchTitle => 'Animation';

  @override
  String get animationSwitchSubtitle => 'Visual effects for charts';

  @override
  String get soundSwitchTitle => 'Sound Effects';

  @override
  String get soundSwitchSubtitle => 'Sounds when adding events';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageUkrainian => 'Українська 🇺🇦';

  @override
  String get languageEnglish => 'English 🇬🇧';

  @override
  String get dataManagementSection => 'Data Management';

  @override
  String get deleteKissesTitle => 'Delete all Kisses';

  @override
  String get deleteSexTitle => 'Delete all Intimacy';

  @override
  String get deleteAllTitle => 'Clear everything completely';

  @override
  String get aboutSection => 'About App';

  @override
  String get codedByLabel => 'Vibe-coded by';

  @override
  String get versionLabel => 'Version';

  @override
  String get techDetails => 'Technical Details';

  @override
  String deleteConfirmTitle(Object title) {
    return 'Delete $title?';
  }

  @override
  String get deleteConfirmContent =>
      'This action cannot be undone. Are you sure?';

  @override
  String get deleteButton => 'Delete';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get dataDeletedMessage => 'Data deleted';

  @override
  String addTitle(Object title) {
    return 'Add: $title';
  }

  @override
  String get addDate => 'Date';

  @override
  String get addType => 'Type';

  @override
  String get saveButton => 'Save';

  @override
  String get orgasmCountLabel => 'Number of orgasms:';

  @override
  String get editRecordTitle => 'Edit Record';

  @override
  String get updateButton => 'Update';

  @override
  String get deleteQuestion => 'Delete?';

  @override
  String get deleteIrreversible => 'This action cannot be undone.';

  @override
  String get yesDeleteButton => 'Yes, delete';

  @override
  String get nothingToday => 'Nothing happened today 🤷‍♂️';

  @override
  String orgasmsCountShort(Object count) {
    return 'Orgasms: $count';
  }

  @override
  String get statsEmpty => 'No data for statistics yet';

  @override
  String get summaryTotal => 'Total';

  @override
  String get summaryOrgasms => 'Orgasms';

  @override
  String get statsType => 'Type';

  @override
  String get statsCount => 'Count';

  @override
  String get statsOrgasms => 'Orgasms';

  @override
  String easterEggHint(Object remaining) {
    return '$remaining more... 🕵️';
  }

  @override
  String get platformLabel => 'Platform';

  @override
  String get frameworkLabel => 'Framework';

  @override
  String get subtypeTender => 'Tender';

  @override
  String get subtypePassionate => 'Passionate';

  @override
  String get subtypeSmallKiss => 'Small Kiss';

  @override
  String get subtypeFrenchKiss => 'French Kiss';

  @override
  String get subtypeReluctant => 'Reluctant Kiss';

  @override
  String get subtypeVaginal => 'Vaginal';

  @override
  String get subtypeOralCuni => 'Oral (Cuni)';

  @override
  String get subtypeOralBlowjob => 'Oral (Blowjob)';

  @override
  String get easterEggTitle => 'Top Secret!';

  @override
  String get easterEggContent => 'My Love made me create this app :)';

  @override
  String get easterEggSubtitle => '(If you are reading this, blink twice)';

  @override
  String get easterEggButton => 'Got it, hang in there! ✊';
}
