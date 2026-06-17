// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get trackerTitle => 'Трекер';

  @override
  String get calendarTitle => 'Календар';

  @override
  String get statsTitle => 'Статистика';

  @override
  String get kissesLabel => 'Цьомчики';

  @override
  String get sexLabel => 'Семкс';

  @override
  String get settingsTitle => 'Налаштування';

  @override
  String get generalSection => 'Загальні';

  @override
  String get animationSwitchTitle => 'Анімація';

  @override
  String get animationSwitchSubtitle => 'Візуальні ефекти графіків';

  @override
  String get soundSwitchTitle => 'Звукові ефекти';

  @override
  String get soundSwitchSubtitle => 'Звуки при додаванні подій';

  @override
  String get languageTitle => 'Мова';

  @override
  String get languageUkrainian => 'Українська 🇺🇦';

  @override
  String get languageEnglish => 'English 🇬🇧';

  @override
  String get dataManagementSection => 'Управління даними';

  @override
  String get deleteKissesTitle => 'Видалити всі Цьомчики';

  @override
  String get deleteSexTitle => 'Видалити весь Семкс';

  @override
  String get deleteAllTitle => 'Очистити все повністю';

  @override
  String get aboutSection => 'Про програму';

  @override
  String get codedByLabel => 'Vibe-coded by';

  @override
  String get versionLabel => 'Версія';

  @override
  String get techDetails => 'Технічні деталі';

  @override
  String deleteConfirmTitle(Object title) {
    return 'Видалити $title?';
  }

  @override
  String get deleteConfirmContent => 'Цю дію не можна скасувати. Ви впевнені?';

  @override
  String get deleteButton => 'Видалити';

  @override
  String get cancelButton => 'Скасувати';

  @override
  String get dataDeletedMessage => 'Дані видалено';

  @override
  String addTitle(Object title) {
    return 'Додати: $title';
  }

  @override
  String get addDate => 'Дата';

  @override
  String get addType => 'Тип';

  @override
  String get saveButton => 'Зберегти';

  @override
  String get orgasmCountLabel => 'Кількість оргазмів:';

  @override
  String get editRecordTitle => 'Редагувати запис';

  @override
  String get updateButton => 'Оновити';

  @override
  String get deleteQuestion => 'Видалити?';

  @override
  String get deleteIrreversible => 'Цю дію не можна скасувати.';

  @override
  String get yesDeleteButton => 'Так, видалити';

  @override
  String get nothingToday => 'Нічого не було в цей день 🤷‍♂️';

  @override
  String orgasmsCountShort(Object count) {
    return 'Оргазмів: $count';
  }

  @override
  String get statsEmpty => 'Ще немає даних для статистики';

  @override
  String get summaryTotal => 'Разом';

  @override
  String get summaryOrgasms => 'Оргазми';

  @override
  String get statsType => 'Тип';

  @override
  String get statsCount => 'К-сть';

  @override
  String get statsOrgasms => 'Оргазми';

  @override
  String easterEggHint(Object remaining) {
    return 'Ще $remaining... 🕵️';
  }

  @override
  String get platformLabel => 'Платформа';

  @override
  String get frameworkLabel => 'Фреймворк';

  @override
  String get subtypeTender => 'Ніжний';

  @override
  String get subtypePassionate => 'Пристрасний';

  @override
  String get subtypeSmallKiss => 'Маленький цьом';

  @override
  String get subtypeFrenchKiss => 'З язиком';

  @override
  String get subtypeReluctant => 'Цьом ніби не любить';

  @override
  String get subtypeVaginal => 'Вагінальний';

  @override
  String get subtypeOralCuni => 'Оральний (куні)';

  @override
  String get subtypeOralBlowjob => 'Оральний (мінет)';

  @override
  String get easterEggTitle => 'Цілком таємно!';

  @override
  String get easterEggContent =>
      'Моя Кохана змусила мене зробити цей застосунок :)';

  @override
  String get easterEggSubtitle => '(Якщо ви це читаєте, кліпніть двічі)';

  @override
  String get easterEggButton => 'Зрозумів, тримайся! ✊';
}
