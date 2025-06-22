import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart'; // optional color picker package
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:virus_scanner/settings/settingsclass.dart';
import 'package:virus_scanner/settings/settings_file_reader.dart';  // Your Settings class
import 'package:virus_scanner/json_reader_and_filepicker/filereader.dart';  // Your JsonFileStorage class

class SettingsPage extends StatefulWidget {
  final Settings? initialSettings;
  final SettingsFileStorage storage;
  final ValueChanged<Settings> onSettingsChanged;

  const SettingsPage({
    super.key,
    this.initialSettings,
    required this.storage,
    required this.onSettingsChanged,
  });

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  bool? switchLightAndDarkMode;
  Color? themeColor;
  String? language;
  bool isLoading = true;
  TextEditingController? historyPathController;

  late JsonFileStorage scanStorage; // Scan history storage

  final List<String> languages = ['en', 'de', 'fr', 'es'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final loadedSettings = await widget.storage.readSettings();

    final settings = loadedSettings ??
        Settings(
          switchLightAndDarkMode: false,
          themeColor: Colors.blue,
          language: 'en',
          historyPath: '',  // fallback, should not be empty ideally
        );

    setState(() {
      switchLightAndDarkMode = settings.switchLightAndDarkMode;
      themeColor = settings.themeColor;
      language = settings.language;
      historyPathController = TextEditingController(text: settings.historyPath);
      isLoading = false;
    });

    await _initScanStorage(settings.historyPath);
  }

  Future<void> _initScanStorage(String historyPath) async {
    if (historyPath.isEmpty) {
      debugPrint('History path is empty, scanStorage not initialized.');
      return;
    }

    final dir = Directory(historyPath);

   /* final scanHistoryFilePath = p.join(historyPath, 'scan_history.json');
    scanStorage = JsonFileStorage(scanHistoryFilePath);
    debugPrint('ScanStorage initialized at: $scanHistoryFilePath'); */
  }

  Future<void> _saveSettings() async {
    if (switchLightAndDarkMode == null ||
        themeColor == null ||
        language == null ||
        historyPathController == null) return;

    final newSettings = Settings(
      switchLightAndDarkMode: switchLightAndDarkMode!,
      themeColor: themeColor!,
      language: language!,
      historyPath: historyPathController!.text,
    );

    await widget.storage.writeSettings(newSettings);
    widget.onSettingsChanged(newSettings);

    // Update scanStorage if historyPath changed
    await _initScanStorage(newSettings.historyPath);
  }

  @override
  void dispose() {
    historyPathController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (switchLightAndDarkMode == null ||
        themeColor == null ||
        language == null ||
        historyPathController == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Settings')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: themeColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: Text('Light/Dark Mode'),
              value: switchLightAndDarkMode!,
              onChanged: (val) {
                setState(() {
                  switchLightAndDarkMode = val;
                });
                _saveSettings();
              },
            ),
            ListTile(
              title: Text('Theme Color'),
              trailing: ColorIndicator(
                width: 30,
                height: 30,
                color: themeColor!,
                onSelect: () async {
                  Color? picked = await showColorPickerDialog(
                    context,
                    themeColor!,
                    title: const Text('Select Theme Color'),
                    enableShadesSelection: true,
                    showColorName: true,
                    showColorCode: true,
                  );
                  if (picked != themeColor) {
                    setState(() {
                      themeColor = picked;
                    });
                    _saveSettings();
                  }
                },
              ),
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Language'),
              value: language,
              items: languages
                  .map((lang) => DropdownMenuItem(
                        value: lang,
                        child: Text(lang.toUpperCase()),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    language = val;
                  });
                  _saveSettings();
                }
              },
            ),
            /*TextFormField(
              controller: historyPathController,
              decoration: InputDecoration(labelText: 'History Path'),
              onFieldSubmitted: (_) => _saveSettings(),
            ),*/
          ],
        ),
      ),
    );
  }
}
