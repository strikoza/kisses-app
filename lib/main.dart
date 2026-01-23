import 'dart:convert';
import 'dart:io'; // Для визначення Platform
import 'package:flutter/foundation.dart'; // Для kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Для SystemChrome та HapticFeedback
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:package_info_plus/package_info_plus.dart';
// 🔥 ІМПОРТ ЗГЕНЕРОВАНОГО КЛАСУ ЛОКАЛІЗАЦІЇ
import 'package:kisses_app/l10n/app_localizations.dart'; 
import 'package:url_launcher/url_launcher.dart';


// --- MODELS ---

enum ActivityType { kiss, sex }

class ActivityRecord {
  final String id;
  final DateTime date;
  final ActivityType type;
  final String subtype;
  final int orgasmCount;

  ActivityRecord({
    required this.id,
    required this.date,
    required this.type,
    required this.subtype,
    this.orgasmCount = 0,
  });

  ActivityRecord copyWith({
    String? subtype,
    int? orgasmCount,
    DateTime? date,
  }) {
    return ActivityRecord(
      id: id,
      date: date ?? this.date,
      type: type,
      subtype: subtype ?? this.subtype,
      orgasmCount: orgasmCount ?? this.orgasmCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'type': type.index,
        'subtype': subtype,
        'orgasmCount': orgasmCount,
      };

  factory ActivityRecord.fromJson(Map<String, dynamic> json) {
    return ActivityRecord(
      id: json['id'],
      date: DateTime.parse(json['date']),
      type: ActivityType.values[json['type']],
      subtype: json['subtype'],
      orgasmCount: json['orgasmCount'] ?? 0,
    );
  }
}

// --- STATE MANAGEMENT ---

class AppState extends ChangeNotifier {
  List<ActivityRecord> _records = [];
  bool _isLoading = true;
  
  // Settings
  bool _isAnimationEnabled = true;
  bool _isSoundEnabled = true;
  String _languageCode = 'uk'; 

  List<ActivityRecord> get records => _records;
  bool get isLoading => _isLoading;
  bool get isAnimationEnabled => _isAnimationEnabled;
  bool get isSoundEnabled => _isSoundEnabled;
  
  // Геттер для Locale
  Locale get currentLocale {
    if (_languageCode == 'en') {
      return const Locale('en', 'GB');
    }
    return const Locale('uk');
  }
  
  String get languageCode => _languageCode;

  AppState() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final String? data = prefs.getString('kisses_app_data');
    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data);
      _records = jsonList.map((e) => ActivityRecord.fromJson(e)).toList();
    }

    _isAnimationEnabled = prefs.getBool('setting_animation') ?? true;
    _isSoundEnabled = prefs.getBool('setting_sound') ?? true;
    // Завантаження мови
    _languageCode = prefs.getString('setting_language') ?? 'uk';

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(_records.map((e) => e.toJson()).toList());
    await prefs.setString('kisses_app_data', data);
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('setting_animation', _isAnimationEnabled);
    await prefs.setBool('setting_sound', _isSoundEnabled);
    // Збереження мови
    await prefs.setString('setting_language', _languageCode);
  }
  
  // Метод для зміни мови
  void setLanguage(String code) {
    _languageCode = code;
    _saveSettings();
    notifyListeners();
  }

  void toggleAnimation(bool value) {
    _isAnimationEnabled = value;
    _saveSettings();
    notifyListeners();
  }

  void toggleSound(bool value) {
    _isSoundEnabled = value;
    _saveSettings();
    notifyListeners();
  }

  // --- DATA MODIFICATION ---

  void addRecord(ActivityType type, String subtype, DateTime date, {int orgasms = 0}) {
    _records.add(ActivityRecord(
      id: DateTime.now().toString(),
      date: date,
      type: type,
      subtype: subtype,
      orgasmCount: orgasms,
    ));
    _saveData();
    notifyListeners();
  }

  void updateRecord(ActivityRecord updatedRecord) {
    final index = _records.indexWhere((r) => r.id == updatedRecord.id);
    if (index != -1) {
      _records[index] = updatedRecord;
      _saveData();
      notifyListeners();
    }
  }

  void deleteRecord(String id) {
    _records.removeWhere((r) => r.id == id);
    _saveData();
    notifyListeners();
  }

  // --- BULK DELETE ---

  void clearAllData() {
    _records.clear();
    _saveData();
    notifyListeners();
  }

  void clearDataByType(ActivityType type) {
    _records.removeWhere((r) => r.type == type);
    _saveData();
    notifyListeners();
  }

  // --- GETTERS ---

  List<ActivityRecord> getRecordsForDay(DateTime day) {
    return _records.where((r) => isSameDay(r.date, day)).toList();
  }

  Map<String, int> getStatsByType(ActivityType type) {
    var filtered = _records.where((r) => r.type == type);
    return groupBy(filtered, (ActivityRecord r) => r.subtype)
        .map((key, value) => MapEntry(key, value.length));
  }

  Map<String, int> getOrgasmStatsByType(ActivityType type) {
    var filtered = _records.where((r) => r.type == type);
    return groupBy(filtered, (ActivityRecord r) => r.subtype)
        .map((key, value) => MapEntry(key, value.fold(0, (sum, r) => sum + r.orgasmCount)));
  }
}

// --- MAIN ENTRY POINT ---

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const KissesApp(),
    ),
  );
}

class KissesApp extends StatelessWidget {
  const KissesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return MaterialApp(
      title: 'Kisses & Love',
      
      // ВИПРАВЛЕННЯ: Додано ключ для примусової перебудови
      key: ValueKey(state.languageCode), 
      
      locale: state.currentLocale, 
      
      // ВИКОРИСТОВУЄМО ЗГЕНЕРОВАНИЙ ДЕЛЕГАТ
      localizationsDelegates: const [
        // AppLocalizations.delegate повинен бути константою після генерації
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppLocalizations.delegate, // Наш делегат
      ],
      supportedLocales: const [
        Locale('uk'), 
        Locale('en', 'GB'), 
      ],
      
      theme: ThemeData(
        useMaterial3: true,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            // 🔥 ВИПРАВЛЕНО: Прибрано дублювання TargetPlatform.android
            TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        splashFactory: InkRipple.splashFactory,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink, 
          brightness: Brightness.light,
          dynamicSchemeVariant: DynamicSchemeVariant.vibrant, 
        ),
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = const [
    TrackerScreen(),
    CalendarHistoryScreen(),
    StatsScreen(),
  ];

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      HapticFeedback.lightImpact(); 
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<AppState, bool>((s) => s.isLoading);
    // 🔥 Використовуємо AppLocalizations.of(context)! для null safety
    final loc = AppLocalizations.of(context)!;
    
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      extendBody: true, 
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabTapped,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.95),
        elevation: 0,
        destinations: [
          NavigationDestination(icon: const Icon(Icons.add_circle_outline), label: loc.trackerTitle),
          NavigationDestination(icon: const Icon(Icons.calendar_month), label: loc.calendarTitle),
          NavigationDestination(icon: const Icon(Icons.bar_chart), label: loc.statsTitle),
        ],
      ),
    );
  }
}

// --- SETTINGS SCREEN ---

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '...';
  String _buildNumber = '';
  String _installerStore = '';
  
  // Для пасхалки
  int _easterEggTapCount = 0;

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = info.version;
      _buildNumber = info.buildNumber;
      _installerStore = info.installerStore ?? 'Manual Build';
    });
  }

  void _confirmDelete(BuildContext context, String title, VoidCallback onConfirm) {
    // 🔥 Використовуємо AppLocalizations.of(context)! для null safety
    final loc = AppLocalizations.of(context)!;
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.deleteConfirmTitle(title)),
        content: Text(loc.deleteConfirmContent),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(loc.cancelButton)),
          TextButton(
            onPressed: () {
              HapticFeedback.heavyImpact();
              onConfirm();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.dataDeletedMessage)));
            },
            child: Text(loc.deleteButton, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  // 🔥 Оновлено для локалізації тексту пасхалки
  void _showEasterEgg(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    // 🔥 Локалізовані рядки для пасхалки
    final String title = loc.localeName == 'uk' ? 'Цілком таємно!' : 'Top Secret!';
    final String content = loc.localeName == 'uk' 
      ? 'Моя Кохана змусила мене зробити цей застосунок :)' 
      : 'My Love made me create this app :)';
    final String subtitle = loc.localeName == 'uk'
      ? '(Якщо ви це читаєте, кліпніть двічі)'
      : '(If you are reading this, blink twice)';
    final String buttonText = loc.localeName == 'uk' 
      ? 'Зрозумів, тримайся! ✊'
      : 'Got it, hang in there! ✊';
      
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Text('🤫 '),
            Text(title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              content,
              style: const TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text('🆘', style: TextStyle(fontSize: 50)),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              HapticFeedback.mediumImpact();
            },
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    // 🔥 Використовуємо AppLocalizations.of(context)! для null safety
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.settingsTitle)),
      body: ListView(
        children: [
          const SizedBox(height: 10),
          _buildSectionTitle(context, loc.generalSection),
          
          // 🔥 Перемикач мови
          ListTile(
            title: Text(loc.languageTitle),
            trailing: DropdownButton<String>(
              value: state.languageCode,
              icon: const Icon(Icons.arrow_drop_down),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  HapticFeedback.selectionClick();
                  state.setLanguage(newValue);
                }
              },
              items: <Map<String, String>>[
                {'code': 'uk', 'name': loc.languageUkrainian},
                {'code': 'en', 'name': loc.languageEnglish},
              ].map<DropdownMenuItem<String>>((Map<String, String> map) {
                return DropdownMenuItem<String>(
                  value: map['code'],
                  child: Text(map['name']!),
                );
              }).toList(),
            ),
          ),
          // ------------------------------------

          SwitchListTile(
            title: Text(loc.animationSwitchTitle),
            subtitle: Text(loc.animationSwitchSubtitle),
            value: state.isAnimationEnabled,
            onChanged: (val) {
               HapticFeedback.selectionClick();
               state.toggleAnimation(val);
            },
          ),
          SwitchListTile(
            title: Text(loc.soundSwitchTitle),
            subtitle: Text(loc.soundSwitchSubtitle),
            value: state.isSoundEnabled,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              state.toggleSound(val);
            },
          ),
          
          const Divider(height: 30),
          _buildSectionTitle(context, loc.dataManagementSection, color: Colors.red.shade700),
          ListTile(
            leading: const Icon(Icons.delete_sweep, color: Colors.pink),
            title: Text(loc.deleteKissesTitle),
            onTap: () => _confirmDelete(context, loc.kissesLabel, () => state.clearDataByType(ActivityType.kiss)),
          ),
          ListTile(
            leading: const Icon(Icons.local_fire_department, color: Colors.purple),
            title: Text(loc.deleteSexTitle),
            onTap: () => _confirmDelete(context, loc.sexLabel, () => state.clearDataByType(ActivityType.sex)),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: Text(loc.deleteAllTitle),
            onTap: () => _confirmDelete(context, loc.deleteAllTitle, () => state.clearAllData()),
          ),

          const Divider(height: 30),
          _buildSectionTitle(context, loc.aboutSection),
          
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(loc.codedByLabel),
            trailing: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Serhii Trykoza',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.blue,
                  ),
                ),
                Text(' © 2025'),
              ],
            ),
            onTap: () async {
              HapticFeedback.lightImpact();
              final Uri url = Uri.parse('https://github.com/strikoza/kisses-app');
              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                debugPrint('Could not launch $url');
              }
            },
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(loc.versionLabel),
            trailing: Text('$_appVersion ($_buildNumber)'),
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _easterEggTapCount++;
              });

              if (_easterEggTapCount >= 5) {
                _showEasterEgg(context);
                _easterEggTapCount = 0; // Reset counter
              } else if (_easterEggTapCount >= 2) {
                // Показуємо скільки залишилось
                final remaining = 5 - _easterEggTapCount;
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(loc.easterEggHint(remaining)), // 🔥 ВИКОРИСТАННЯ ЛОКАЛІЗОВАНОГО РЯДКА
                    duration: const Duration(milliseconds: 500),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
          ExpansionTile(
            title: Text(loc.techDetails, style: const TextStyle(fontSize: 14)),
            children: [
               Padding(
                 padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                 child: Column(
                   children: [
                      _buildTechRow(loc.platformLabel, kIsWeb ? 'Web' : Platform.operatingSystem),
                      _buildTechRow(loc.frameworkLabel, 'Flutter Stable'),
                      const SizedBox(height: 8),
                      const Text(
                        'Libs: provider, fl_chart, table_calendar, audioplayers, shared_preferences, url_launcher',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                   ],
                 ),
               )
            ],
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: color ?? Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTechRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'monospace', fontSize: 13)),
        ],
      ),
    );
  }
}

// --- SCREEN 1: TRACKER ---

class TrackerScreen extends StatelessWidget {
  const TrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔥 Використовуємо AppLocalizations.of(context)! для null safety
    final loc = AppLocalizations.of(context)!;
    
    // 🔥 Явна типізація List<String>
    final List<String> kissesSubtypes = [
      loc.translateSubtype('Ніжний'), 
      loc.translateSubtype('Пристрасний'),
      loc.translateSubtype('Маленький цьом'),
      loc.translateSubtype('З язиком'),
      loc.translateSubtype('Цьом ніби не любить'),
    ];
    final List<String> sexSubtypes = [
      loc.translateSubtype('Вагінальний'),
      loc.translateSubtype('Оральний (куні)'),
      loc.translateSubtype('Оральний (мінет)'),
    ];

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true, 
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
               HapticFeedback.lightImpact();
               Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildBigButton(
              context,
              loc.kissesLabel,
              const Text('💋', style: TextStyle(fontSize: 28)),
              Colors.pink,
              ActivityType.kiss,
              kissesSubtypes, // Використовуємо локалізовані підтипи
            ),
            const SizedBox(height: 30),
            _buildBigButton(
              context,
              loc.sexLabel,
              const Icon(Icons.local_fire_department, size: 38),
              Colors.purple,
              ActivityType.sex,
              sexSubtypes, // Використовуємо локалізовані підтипи
              showOrgasmCounter: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBigButton(
    BuildContext context,
    String title,
    Widget icon, 
    Color color,
    ActivityType type,
    List<String> subtypes, {
    bool showOrgasmCounter = false,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0, 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      onPressed: () {
         HapticFeedback.mediumImpact(); 
         _showAddDialog(context, title, type, subtypes, showOrgasmCounter);
      },
      icon: icon, 
      label: Text(title, style: const TextStyle(fontSize: 24)),
    );
  }

  void _showAddDialog(
    BuildContext context,
    String title,
    ActivityType type,
    List<String> subtypes,
    bool showOrgasmCounter,
  ) {
    String selectedSubtype = subtypes.first;
    int orgasmCount = 0;
    DateTime selectedDate = DateTime.now();
    // 🔥 Використовуємо AppLocalizations.of(context)! для null safety
    final loc = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true, 
      showDragHandle: true, 
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(loc.addTitle(title), style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () async {
                        HapticFeedback.selectionClick();
                        final d = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (d != null) setModalState(() => selectedDate = d);
                      },
                      child: Text(DateFormat('dd.MM.yyyy').format(selectedDate)),
                    ),
                  ],
                ),
                
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedSubtype,
                  decoration: InputDecoration(
                    labelText: loc.addType,
                    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                  ),
                  items: subtypes.map((s) => DropdownMenuItem<String>(value: s, child: Text(s))).toList(), // Явна типізація
                  onChanged: (v) => setModalState(() => selectedSubtype = v!),
                ),

                if (showOrgasmCounter) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(loc.orgasmCountLabel, style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, color: Colors.green),
                              onPressed: () {
                                if (orgasmCount > 0) {
                                   HapticFeedback.selectionClick();
                                   setModalState(() => orgasmCount--);
                                }
                              },
                            ),
                            Text('$orgasmCount', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.green),
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                setModalState(() => orgasmCount++);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: type == ActivityType.sex ? Colors.purple : Colors.pink,
                      padding: const EdgeInsets.symmetric(vertical: 16), 
                    ),
                    onPressed: () async {
                      HapticFeedback.heavyImpact(); 
                      final appState = context.read<AppState>();
                      
                      // ЗБЕРІГАЄМО ОРИГІНАЛЬНИЙ КЛЮЧ
                      final originalSubtype = loc.getOriginalSubtype(selectedSubtype);
                      
                      appState.addRecord(
                        type,
                        originalSubtype,
                        selectedDate,
                        orgasms: orgasmCount,
                      );
                      Navigator.pop(context);

                      if (appState.isSoundEnabled) {
                        try {
                          final player = AudioPlayer();
                          final soundPath = type == ActivityType.sex ? 'sounds/sex.mp3' : 'sounds/kiss.mp3';
                          await player.play(AssetSource(soundPath));
                        } catch (e) {
                          debugPrint("Audio Error: $e");
                        }
                      }
                    },
                    child: Text(loc.saveButton, style: const TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// --- SCREEN 2: CALENDAR ---

class CalendarHistoryScreen extends StatefulWidget {
  const CalendarHistoryScreen({super.key});

  @override
  State<CalendarHistoryScreen> createState() => _CalendarHistoryScreenState();
}

class _CalendarHistoryScreenState extends State<CalendarHistoryScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  void _showEditDialog(BuildContext context, ActivityRecord record) {
    // 🔥 Використовуємо AppLocalizations.of(context)! для null safety
    final loc = AppLocalizations.of(context)!;
    
    // 🔥 Використовуємо локалізовані підтипи
    final isSex = record.type == ActivityType.sex;
    final originalSubtypes = isSex 
        ? ['Вагінальний', 'Оральний (куні)', 'Оральний (мінет)']
        : ['Ніжний', 'Пристрасний', 'Маленький цьом', 'З язиком', 'Цьом ніби не любить'];
    
    // Перекладаємо підтипи для відображення в Dropdown
    final List<String> displayedSubtypes = originalSubtypes.map((s) => loc.translateSubtype(s)).toList();

    // Визначаємо поточний вибраний підтип (якщо він є в списку)
    String currentOriginalSubtype = record.subtype;
    String currentDisplayedSubtype = loc.translateSubtype(currentOriginalSubtype);

    int currentOrgasms = record.orgasmCount;

    // Якщо поточний підтип не входить в оригінальний список, додаємо його переклад
    if (!originalSubtypes.contains(currentOriginalSubtype)) {
      if (!displayedSubtypes.contains(currentDisplayedSubtype)) {
          displayedSubtypes.add(currentDisplayedSubtype);
      }
    }


    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(loc.editRecordTitle, style: Theme.of(context).textTheme.headlineSmall),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        showDialog(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: Text(loc.deleteQuestion),
                            content: Text(loc.deleteIrreversible),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(c), child: Text(loc.cancelButton)),
                              TextButton(
                                onPressed: () {
                                  HapticFeedback.heavyImpact();
                                  context.read<AppState>().deleteRecord(record.id);
                                  Navigator.pop(c);
                                  Navigator.pop(context);
                                },
                                child: Text(loc.yesDeleteButton, style: const TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  ],
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: currentDisplayedSubtype, // Відображаємо переклад
                  decoration: InputDecoration(
                    labelText: loc.addType,
                    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                  ),
                  items: displayedSubtypes.map((s) => DropdownMenuItem<String>(value: s, child: Text(s))).toList(), // Явна типізація
                  onChanged: (v) {
                    // Коли користувач обирає переклад, ми повинні знайти оригінальний ключ
                    final newOriginalSubtype = loc.getOriginalSubtype(v!); 
                    setModalState(() {
                        currentDisplayedSubtype = v;
                        currentOriginalSubtype = newOriginalSubtype; 
                    });
                  },
                ),
                if (isSex) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(loc.orgasmCountLabel, style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, color: Colors.green),
                              onPressed: () {
                                if (currentOrgasms > 0) {
                                  HapticFeedback.selectionClick();
                                  setModalState(() => currentOrgasms--);
                                }
                              },
                            ),
                            Text('$currentOrgasms', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.green),
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                setModalState(() => currentOrgasms++);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: isSex ? Colors.purple : Colors.pink,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      // Зберігаємо оригінальний (не перекладений) підтип, щоб не ламати логіку AppState
                      context.read<AppState>().updateRecord(
                        record.copyWith(
                          subtype: currentOriginalSubtype,
                          orgasmCount: currentOrgasms,
                        ),
                      );
                      Navigator.pop(context);
                    },
                    child: Text(loc.updateButton),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final events = state.getRecordsForDay(_selectedDay ?? _focusedDay);
    // 🔥 Використовуємо AppLocalizations.of(context)! для null safety
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selected, focused) {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
              },
              eventLoader: (day) => state.getRecordsForDay(day),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false, 
                titleCentered: true,
              ),
              calendarStyle: const CalendarStyle(
                markerDecoration: BoxDecoration(color: Colors.pinkAccent, shape: BoxShape.circle), 
                todayDecoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(BorderSide(color: Colors.pinkAccent, width: 2.0)),
                  color: Colors.transparent,
                ),
                todayTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isEmpty) return null;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: events.take(3).map((e) {
                       final rec = e as ActivityRecord;
                       return Container(
                         margin: const EdgeInsets.symmetric(horizontal: 1.5),
                         width: 6, 
                         height: 6,
                         decoration: BoxDecoration(
                           shape: BoxShape.circle,
                           color: rec.type == ActivityType.sex ? Colors.purple : Colors.pink,
                         ),
                       );
                    }).toList(),
                  );
                },
              ),
            ),
            const Divider(indent: 16, endIndent: 16),
            Expanded(
              child: events.isEmpty
                  ? Center(child: Text(loc.nothingToday, style: const TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final e = events[index];
                        // 🔥 Відображаємо перекладений підтип
                        final displayedSubtype = loc.translateSubtype(e.subtype);
                        
                        return ListTile(
                          onTap: () {
                             HapticFeedback.lightImpact();
                             _showEditDialog(context, e);
                          },
                          leading: e.type == ActivityType.sex 
                              ? const Icon(Icons.local_fire_department, color: Colors.purple)
                              : const Text('💋', style: TextStyle(fontSize: 20)), 
                          title: Text(displayedSubtype, style: const TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: (e.type == ActivityType.sex && e.orgasmCount > 0) 
                              ? Text(
                                  loc.orgasmsCountShort(e.orgasmCount),
                                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                )
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                               Text(DateFormat('HH:mm').format(e.date), style: const TextStyle(color: Colors.grey)),
                               const SizedBox(width: 8),
                               const Icon(Icons.edit, size: 16, color: Colors.grey),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- SCREEN 3: STATS ---

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with SingleTickerProviderStateMixin {
  int _touchedIndexKiss = -1;
  int _touchedIndexSex = -1;
  
  // Sorting state
  bool _sortAscendingKiss = false;
  bool _sortAscendingSex = false;
  bool _sortByOrgasmsSex = false;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        HapticFeedback.selectionClick();
      }
      setState(() {}); 
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final kissStats = state.getStatsByType(ActivityType.kiss);
    final sexStats = state.getStatsByType(ActivityType.sex);
    final sexOrgasmStats = state.getOrgasmStatsByType(ActivityType.sex);
    // 🔥 Використовуємо AppLocalizations.of(context)! для null safety
    final loc = AppLocalizations.of(context)!;

    final activeColor = _tabController.index == 0 ? Colors.pink : Colors.purple;
    
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: activeColor,
          indicatorWeight: 3,
          labelPadding: EdgeInsets.zero, 
          overlayColor: WidgetStateProperty.all(activeColor.withOpacity(0.1)),
          tabs: [
             Tab(
               child: Row( 
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   const Text('💋', style: TextStyle(fontSize: 20)), 
                   const SizedBox(width: 8), 
                   Text(loc.kissesLabel, style: const TextStyle(color: Colors.pink, fontWeight: FontWeight.w600)),
                 ],
               ),
             ),
             Tab(
               child: Row( 
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   const Icon(Icons.local_fire_department, color: Colors.purple, size: 22),
                   const SizedBox(width: 8), 
                   Text(loc.sexLabel, style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.w600)),
                 ],
               ),
             ), 
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatPage(
            context, // Передаємо context
            data: kissStats,
            orgasmData: null,
            baseColor: Colors.pink,
            touchedIndex: _touchedIndexKiss,
            onTouch: (idx) {
              if (idx != -1 && idx != _touchedIndexKiss) HapticFeedback.selectionClick();
              setState(() => _touchedIndexKiss = idx);
            },
            enableAnimation: state.isAnimationEnabled,
            isAscending: _sortAscendingKiss,
            onSortToggle: () {
               HapticFeedback.selectionClick();
               setState(() => _sortAscendingKiss = !_sortAscendingKiss);
            },
            sortByOrgasms: false,
            onSortByOrgasmsToggle: () {},
          ),
          _buildStatPage(
            context, // Передаємо context
            data: sexStats,
            orgasmData: sexOrgasmStats,
            baseColor: Colors.purple,
            touchedIndex: _touchedIndexSex,
            onTouch: (idx) {
              if (idx != -1 && idx != _touchedIndexSex) HapticFeedback.selectionClick();
              setState(() => _touchedIndexSex = idx);
            },
            enableAnimation: state.isAnimationEnabled,
            isAscending: _sortAscendingSex,
            onSortToggle: () {
              HapticFeedback.selectionClick();
              setState(() {
                 if (_sortByOrgasmsSex) {
                   _sortByOrgasmsSex = false;
                   _sortAscendingSex = false; 
                 } else {
                   _sortAscendingSex = !_sortAscendingSex;
                 }
              });
            },
            sortByOrgasms: _sortByOrgasmsSex,
            onSortByOrgasmsToggle: () {
              HapticFeedback.selectionClick();
              setState(() {
                if (!_sortByOrgasmsSex) {
                  _sortByOrgasmsSex = true;
                  _sortAscendingSex = false; 
                } else {
                  _sortAscendingSex = !_sortAscendingSex;
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatPage(
    BuildContext context, // Приймаємо context
    {
    required Map<String, int> data,
    required Map<String, int>? orgasmData,
    required Color baseColor,
    required int touchedIndex,
    required Function(int) onTouch,
    required bool enableAnimation,
    required bool isAscending,
    required VoidCallback onSortToggle,
    required bool sortByOrgasms, // Чи сортуємо по оргазмах
    required VoidCallback onSortByOrgasmsToggle,
  }) {
    // 🔥 Використовуємо AppLocalizations.of(context)! для null safety
    final loc = AppLocalizations.of(context)!;

    if (data.isEmpty) {
      return Center(child: Text(loc.statsEmpty));
    }

    final totalCount = data.values.fold(0, (sum, val) => sum + val);
    final totalOrgasms = orgasmData?.values.fold(0, (sum, val) => sum + val) ?? 0;

    // Сортуємо дані перед відображенням
    var sortedEntries = data.entries.toList();
    sortedEntries.sort((a, b) {
      int valA, valB;
      
      if (sortByOrgasms && orgasmData != null) {
        valA = orgasmData[a.key] ?? 0;
        valB = orgasmData[b.key] ?? 0;
      } else {
        valA = a.value;
        valB = b.value;
      }

      return isAscending 
          ? valA.compareTo(valB) 
          : valB.compareTo(a.value);
    });

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSummaryCard(loc.summaryTotal, '$totalCount', baseColor),
              if (orgasmData != null) ...[
                const SizedBox(width: 40),
                _buildSummaryCard(loc.summaryOrgasms, '$totalOrgasms', Colors.green),
              ]
            ],
          ),
          
          const SizedBox(height: 20),
          
          SizedBox(
            height: 250, 
            child: PieChart(
              swapAnimationDuration: Duration(milliseconds: enableAnimation ? 500 : 0),
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      return;
                    }
                    
                    if (event is FlPointerHoverEvent) {
                      return;
                    }
                    
                    onTouch(pieTouchResponse.touchedSection!.touchedSectionIndex);
                  },
                ),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: sortedEntries.asMap().entries.map((entry) {
                  final index = entry.key;
                  final kv = entry.value;
                  final isTouched = index == touchedIndex;
                  
                  final color = baseColor.withOpacity(1.0 - (index * 0.15).clamp(0.0, 0.5));
                  
                  final double opacity = (touchedIndex == -1 || isTouched) ? 1.0 : 0.4;
                  final double radius = isTouched && enableAnimation ? 70.0 : 60.0;
                  final double fontSize = isTouched && enableAnimation ? 20.0 : 16.0;

                  return PieChartSectionData(
                    color: color.withOpacity(color.opacity * opacity),
                    value: kv.value.toDouble(),
                    title: '${kv.value}',
                    radius: radius,
                    titleStyle: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(child: Text(loc.statsType, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                
                // Count Header
                InkWell(
                  onTap: onSortToggle,
                  child: SizedBox(
                    width: 70, // Fixed width for alignment
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Center the group
                      children: [
                        // Icon on Left (using Opacity to maintain size when hidden)
                        Opacity(
                          opacity: !sortByOrgasms ? 1.0 : 0.0,
                          child: Icon(
                            isAscending ? Icons.arrow_upward : Icons.arrow_downward, 
                            size: 16, 
                            color: Colors.blue
                          ),
                        ),
                        Text(loc.statsCount, style: TextStyle(fontWeight: FontWeight.bold, color: !sortByOrgasms ? Colors.blue : Colors.grey)),
                      ],
                    ),
                  ),
                ),
                
                // Orgasms Header
                if (orgasmData != null) ...[
                  const SizedBox(width: 10), // Spacing
                  InkWell(
                    onTap: onSortByOrgasmsToggle,
                    child: SizedBox(
                      width: 90, // Fixed width
                      child: Row(
                         mainAxisAlignment: MainAxisAlignment.center, // Center the group
                         children: [
                           // Icon on Left (using Opacity)
                           Opacity(
                             opacity: sortByOrgasms ? 1.0 : 0.0,
                             child: Icon(
                               isAscending ? Icons.arrow_upward : Icons.arrow_downward, 
                               size: 16, 
                               color: Colors.blue
                             ),
                           ),
                           // Text
                           Text(
                             loc.statsOrgasms, 
                             style: TextStyle(fontWeight: FontWeight.bold, color: sortByOrgasms ? Colors.blue : Colors.green)
                           ),
                         ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(), 
              children: sortedEntries.asMap().entries.map((entry) {
                final index = entry.key;
                final e = entry.value;
                final count = e.value;
                final orgasms = orgasmData?[e.key] ?? 0;
                
                final isTouched = index == touchedIndex;
                
                // 🔥 Відображаємо перекладений підтип
                final displayedSubtype = loc.translateSubtype(e.key);

                return Container(
                  color: isTouched ? baseColor.withOpacity(0.1) : null,
                  child: ListTile(
                    onTap: () => onTouch(index == touchedIndex ? -1 : index),
                    leading: CircleAvatar(backgroundColor: baseColor, radius: 5),
                    title: Text(
                      displayedSubtype,
                      style: TextStyle(
                        fontWeight: isTouched ? FontWeight.bold : FontWeight.normal,
                        color: isTouched ? baseColor : Colors.black,
                      ),
                    ),
                    // Centered Values
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                         // Count Value
                         SizedBox(
                           width: 70, 
                           child: Text('$count', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))
                         ),
                         if (orgasmData != null) ...[
                           const SizedBox(width: 10),
                           // Orgasms Value
                           SizedBox(
                             width: 90, 
                             child: Text('$orgasms', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green))
                           ),
                         ]
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}

// 🔥 ДОДАЄМО МЕТОДИ РОЗШИРЕННЯ для AppLocalizations
// Це потрібно для перекладу типів, які не є простими ключами в .arb
extension LocalizationHelpers on AppLocalizations {
  
  // Карта для зворотного перетворення (Ukrainian original -> English)
  static const Map<String, String> _ukToEnMap = {
    'Ніжний': 'Tender',
    'Пристрасний': 'Passionate',
    'Маленький цьом': 'Small Kiss',
    'З язиком': 'French Kiss',
    'Цьом ніби не любить': 'Reluctant Kiss',
    'Вагінальний': 'Vaginal',
    'Оральний (куні)': 'Oral (Cuni)',
    'Оральний (мінет)': 'Oral (Blowjob)',
  };

  // Метод для перекладу підтипів (використовується для відображення)
  String translateSubtype(String originalUkSubtype) {
    if (localeName == 'uk') {
      return originalUkSubtype;
    }
    
    // Якщо мова не UK, шукаємо переклад
    final translation = _ukToEnMap[originalUkSubtype];
    if (translation != null) {
      return translation;
    }
    
    // Fallback: якщо не знайдено, повертаємо оригінал
    return originalUkSubtype;
  }
  
  // Метод для отримання оригінального ключа (використовується при збереженні)
  String getOriginalSubtype(String displayedText) {
    if (localeName == 'uk') {
      return displayedText;
    }

    // Шукаємо оригінальний український ключ за перекладеним значенням
    final originalUkKey = _ukToEnMap.entries.firstWhereOrNull(
        (entry) => entry.value == displayedText,
    )?.key;
    
    // Якщо знайдено, повертаємо його, інакше повертаємо те, що відображалося (на випадок кастомних значень)
    return originalUkKey ?? displayedText;
  }
}