import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('uk'),
    Locale('en'),
    Locale('en', 'GB'),
  ];

  /// No description provided for @trackerTitle.
  ///
  /// In uk, this message translates to:
  /// **'Трекер'**
  String get trackerTitle;

  /// No description provided for @calendarTitle.
  ///
  /// In uk, this message translates to:
  /// **'Календар'**
  String get calendarTitle;

  /// No description provided for @statsTitle.
  ///
  /// In uk, this message translates to:
  /// **'Статистика'**
  String get statsTitle;

  /// No description provided for @kissesLabel.
  ///
  /// In uk, this message translates to:
  /// **'Цьомчики'**
  String get kissesLabel;

  /// No description provided for @sexLabel.
  ///
  /// In uk, this message translates to:
  /// **'Семкс'**
  String get sexLabel;

  /// No description provided for @settingsTitle.
  ///
  /// In uk, this message translates to:
  /// **'Налаштування'**
  String get settingsTitle;

  /// No description provided for @generalSection.
  ///
  /// In uk, this message translates to:
  /// **'Загальні'**
  String get generalSection;

  /// No description provided for @animationSwitchTitle.
  ///
  /// In uk, this message translates to:
  /// **'Анімація'**
  String get animationSwitchTitle;

  /// No description provided for @animationSwitchSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Візуальні ефекти графіків'**
  String get animationSwitchSubtitle;

  /// No description provided for @soundSwitchTitle.
  ///
  /// In uk, this message translates to:
  /// **'Звукові ефекти'**
  String get soundSwitchTitle;

  /// No description provided for @soundSwitchSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Звуки при додаванні подій'**
  String get soundSwitchSubtitle;

  /// No description provided for @languageTitle.
  ///
  /// In uk, this message translates to:
  /// **'Мова'**
  String get languageTitle;

  /// No description provided for @languageUkrainian.
  ///
  /// In uk, this message translates to:
  /// **'Українська 🇺🇦'**
  String get languageUkrainian;

  /// No description provided for @languageEnglish.
  ///
  /// In uk, this message translates to:
  /// **'English 🇬🇧'**
  String get languageEnglish;

  /// No description provided for @dataManagementSection.
  ///
  /// In uk, this message translates to:
  /// **'Управління даними'**
  String get dataManagementSection;

  /// No description provided for @deleteKissesTitle.
  ///
  /// In uk, this message translates to:
  /// **'Видалити всі Цьомчики'**
  String get deleteKissesTitle;

  /// No description provided for @deleteSexTitle.
  ///
  /// In uk, this message translates to:
  /// **'Видалити весь Семкс'**
  String get deleteSexTitle;

  /// No description provided for @deleteAllTitle.
  ///
  /// In uk, this message translates to:
  /// **'Очистити все повністю'**
  String get deleteAllTitle;

  /// No description provided for @aboutSection.
  ///
  /// In uk, this message translates to:
  /// **'Про програму'**
  String get aboutSection;

  /// No description provided for @codedByLabel.
  ///
  /// In uk, this message translates to:
  /// **'Vibe-coded by'**
  String get codedByLabel;

  /// No description provided for @versionLabel.
  ///
  /// In uk, this message translates to:
  /// **'Версія'**
  String get versionLabel;

  /// No description provided for @techDetails.
  ///
  /// In uk, this message translates to:
  /// **'Технічні деталі'**
  String get techDetails;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In uk, this message translates to:
  /// **'Видалити {title}?'**
  String deleteConfirmTitle(Object title);

  /// No description provided for @deleteConfirmContent.
  ///
  /// In uk, this message translates to:
  /// **'Цю дію не можна скасувати. Ви впевнені?'**
  String get deleteConfirmContent;

  /// No description provided for @deleteButton.
  ///
  /// In uk, this message translates to:
  /// **'Видалити'**
  String get deleteButton;

  /// No description provided for @cancelButton.
  ///
  /// In uk, this message translates to:
  /// **'Скасувати'**
  String get cancelButton;

  /// No description provided for @dataDeletedMessage.
  ///
  /// In uk, this message translates to:
  /// **'Дані видалено'**
  String get dataDeletedMessage;

  /// No description provided for @addTitle.
  ///
  /// In uk, this message translates to:
  /// **'Додати: {title}'**
  String addTitle(Object title);

  /// No description provided for @addDate.
  ///
  /// In uk, this message translates to:
  /// **'Дата'**
  String get addDate;

  /// No description provided for @addType.
  ///
  /// In uk, this message translates to:
  /// **'Тип'**
  String get addType;

  /// No description provided for @saveButton.
  ///
  /// In uk, this message translates to:
  /// **'Зберегти'**
  String get saveButton;

  /// No description provided for @orgasmCountLabel.
  ///
  /// In uk, this message translates to:
  /// **'Кількість оргазмів:'**
  String get orgasmCountLabel;

  /// No description provided for @editRecordTitle.
  ///
  /// In uk, this message translates to:
  /// **'Редагувати запис'**
  String get editRecordTitle;

  /// No description provided for @updateButton.
  ///
  /// In uk, this message translates to:
  /// **'Оновити'**
  String get updateButton;

  /// No description provided for @deleteQuestion.
  ///
  /// In uk, this message translates to:
  /// **'Видалити?'**
  String get deleteQuestion;

  /// No description provided for @deleteIrreversible.
  ///
  /// In uk, this message translates to:
  /// **'Цю дію не можна скасувати.'**
  String get deleteIrreversible;

  /// No description provided for @yesDeleteButton.
  ///
  /// In uk, this message translates to:
  /// **'Так, видалити'**
  String get yesDeleteButton;

  /// No description provided for @nothingToday.
  ///
  /// In uk, this message translates to:
  /// **'Нічого не було в цей день 🤷‍♂️'**
  String get nothingToday;

  /// No description provided for @orgasmsCountShort.
  ///
  /// In uk, this message translates to:
  /// **'Оргазмів: {count}'**
  String orgasmsCountShort(Object count);

  /// No description provided for @statsEmpty.
  ///
  /// In uk, this message translates to:
  /// **'Ще немає даних для статистики'**
  String get statsEmpty;

  /// No description provided for @summaryTotal.
  ///
  /// In uk, this message translates to:
  /// **'Разом'**
  String get summaryTotal;

  /// No description provided for @summaryOrgasms.
  ///
  /// In uk, this message translates to:
  /// **'Оргазми'**
  String get summaryOrgasms;

  /// No description provided for @statsType.
  ///
  /// In uk, this message translates to:
  /// **'Тип'**
  String get statsType;

  /// No description provided for @statsCount.
  ///
  /// In uk, this message translates to:
  /// **'К-сть'**
  String get statsCount;

  /// No description provided for @statsOrgasms.
  ///
  /// In uk, this message translates to:
  /// **'Оргазми'**
  String get statsOrgasms;

  /// No description provided for @easterEggHint.
  ///
  /// In uk, this message translates to:
  /// **'Ще {remaining}... 🕵️'**
  String easterEggHint(Object remaining);

  /// No description provided for @platformLabel.
  ///
  /// In uk, this message translates to:
  /// **'Платформа'**
  String get platformLabel;

  /// No description provided for @frameworkLabel.
  ///
  /// In uk, this message translates to:
  /// **'Фреймворк'**
  String get frameworkLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'en':
      {
        switch (locale.countryCode) {
          case 'GB':
            return AppLocalizationsEnGb();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
