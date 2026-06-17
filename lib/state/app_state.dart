import 'dart:convert';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/activity_record.dart';

/// App-wide state: persisted activity records and user settings, plus the
/// derived statistics used by the screens.
class AppState extends ChangeNotifier {
  static const _dataKey = 'kisses_app_data';
  static const _animationKey = 'setting_animation';
  static const _soundKey = 'setting_sound';
  static const _languageKey = 'setting_language';

  List<ActivityRecord> _records = [];
  bool _isLoading = true;

  // Settings
  bool _isAnimationEnabled = true;
  bool _isSoundEnabled = true;
  String _languageCode = 'uk';

  // A single reusable player; recreating one per tap leaked native resources.
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Random _random = Random();

  List<ActivityRecord> get records => _records;
  bool get isLoading => _isLoading;
  bool get isAnimationEnabled => _isAnimationEnabled;
  bool get isSoundEnabled => _isSoundEnabled;
  String get languageCode => _languageCode;

  Locale get currentLocale =>
      _languageCode == 'en' ? const Locale('en') : const Locale('uk');

  AppState() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final String? data = prefs.getString(_dataKey);
    if (data != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(data) as List<dynamic>;
        _records = jsonList
            .map((e) => ActivityRecord.fromJson(e as Map<String, dynamic>))
            .toList();
        // Persist any legacy -> key subtype migration applied during decode.
        await _saveData();
      } catch (e) {
        debugPrint('Failed to load saved data: $e');
        _records = [];
      }
    }

    _isAnimationEnabled = prefs.getBool(_animationKey) ?? true;
    _isSoundEnabled = prefs.getBool(_soundKey) ?? true;
    _languageCode = prefs.getString(_languageKey) ?? 'uk';

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(_records.map((e) => e.toJson()).toList());
    await prefs.setString(_dataKey, data);
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_animationKey, _isAnimationEnabled);
    await prefs.setBool(_soundKey, _isSoundEnabled);
    await prefs.setString(_languageKey, _languageCode);
  }

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

  // --- Data modification ---

  void addRecord(ActivityType type, String subtype, DateTime date,
      {int orgasms = 0}) {
    _records.add(ActivityRecord(
      id: _generateId(),
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

  // --- Sound ---

  /// Plays the feedback sound for [type] when sound is enabled. Fire-and-forget
  /// (errors are swallowed) so callers don't have to await across UI frames.
  Future<void> playActivitySound(ActivityType type) async {
    if (!_isSoundEnabled) return;
    try {
      final soundPath =
          type == ActivityType.sex ? 'sounds/sex.mp3' : 'sounds/kiss.mp3';
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(soundPath));
    } catch (e) {
      debugPrint('Audio error: $e');
    }
  }

  // --- Derived data ---

  List<ActivityRecord> getRecordsForDay(DateTime day) {
    return _records.where((r) => isSameDay(r.date, day)).toList();
  }

  Map<String, int> getStatsByType(ActivityType type) {
    final filtered = _records.where((r) => r.type == type);
    return groupBy(filtered, (ActivityRecord r) => r.subtype)
        .map((key, value) => MapEntry(key, value.length));
  }

  Map<String, int> getOrgasmStatsByType(ActivityType type) {
    final filtered = _records.where((r) => r.type == type);
    return groupBy(filtered, (ActivityRecord r) => r.subtype).map(
        (key, value) =>
            MapEntry(key, value.fold(0, (sum, r) => sum + r.orgasmCount)));
  }

  // Timestamp + random suffix avoids the id collisions possible with the old
  // `DateTime.now().toString()` when records are added in quick succession.
  String _generateId() =>
      '${DateTime.now().microsecondsSinceEpoch}-${_random.nextInt(1000000000)}';

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
