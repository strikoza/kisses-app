import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../models/activity_record.dart';
import '../state/app_state.dart';

/// Settings: language, toggles, bulk delete, and the about section.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '...';
  String _buildNumber = '';

  // Tap counter for the version easter egg.
  int _easterEggTapCount = 0;

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _appVersion = info.version;
      _buildNumber = info.buildNumber;
    });
  }

  void _confirmDelete(BuildContext context, String title, VoidCallback onConfirm) {
    final loc = AppLocalizations.of(context)!;
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.deleteConfirmTitle(title)),
        content: Text(loc.deleteConfirmContent),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text(loc.cancelButton)),
          TextButton(
            onPressed: () {
              HapticFeedback.heavyImpact();
              final messenger = ScaffoldMessenger.of(context);
              onConfirm();
              Navigator.pop(ctx);
              messenger.showSnackBar(
                  SnackBar(content: Text(loc.dataDeletedMessage)));
            },
            child:
                Text(loc.deleteButton, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEasterEgg(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Text('🤫 '),
            Text(loc.easterEggTitle),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              loc.easterEggContent,
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
              loc.easterEggSubtitle,
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
            child: Text(loc.easterEggButton),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.settingsTitle)),
      body: ListView(
        children: [
          const SizedBox(height: 10),
          _buildSectionTitle(context, loc.generalSection),
          // Language selector
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
              ].map<DropdownMenuItem<String>>((map) {
                return DropdownMenuItem<String>(
                  value: map['code'],
                  child: Text(map['name']!),
                );
              }).toList(),
            ),
          ),
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
          _buildSectionTitle(context, loc.dataManagementSection,
              color: Colors.red.shade700),
          ListTile(
            leading: const Icon(Icons.delete_sweep, color: Colors.pink),
            title: Text(loc.deleteKissesTitle),
            onTap: () => _confirmDelete(context, loc.kissesLabel,
                () => state.clearDataByType(ActivityType.kiss)),
          ),
          ListTile(
            leading: const Icon(Icons.local_fire_department, color: Colors.purple),
            title: Text(loc.deleteSexTitle),
            onTap: () => _confirmDelete(context, loc.sexLabel,
                () => state.clearDataByType(ActivityType.sex)),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: Text(loc.deleteAllTitle),
            onTap: () => _confirmDelete(
                context, loc.deleteAllTitle, () => state.clearAllData()),
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
              final Uri url =
                  Uri.parse('https://github.com/strikoza/kisses-app');
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
              setState(() => _easterEggTapCount++);

              if (_easterEggTapCount >= 5) {
                _showEasterEgg(context);
                _easterEggTapCount = 0;
              } else if (_easterEggTapCount >= 2) {
                final remaining = 5 - _easterEggTapCount;
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(loc.easterEggHint(remaining)),
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
                    _buildTechRow(loc.platformLabel,
                        kIsWeb ? 'Web' : defaultTargetPlatform.name),
                    _buildTechRow(loc.frameworkLabel, 'Flutter Stable'),
                    const SizedBox(height: 8),
                    const Text(
                      'Libs: provider, fl_chart, table_calendar, audioplayers, '
                      'shared_preferences, url_launcher',
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
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                  fontSize: 13)),
        ],
      ),
    );
  }
}
