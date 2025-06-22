import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart'; // optional color picker package
import 'package:virus_scanner/settings/settingsclass.dart';  // Your Settings class

class SettingsPage extends StatefulWidget {
  final Settings initialSettings;
  final ValueChanged<Settings> onSettingsChanged;

  const SettingsPage({
    super.key,
    required this.initialSettings,
    required this.onSettingsChanged,
  });

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  late bool switchLightAndDarkMode;
  late Color themeColor;
  late String language;
  late TextEditingController historyPathController;

  final List<String> languages = ['en', 'de', 'fr', 'es'];

  @override
  void initState() {
    super.initState();
    switchLightAndDarkMode = widget.initialSettings.switchLightAndDarkMode;
    themeColor = widget.initialSettings.themeColor;
    language = widget.initialSettings.language;
    historyPathController = TextEditingController(text: widget.initialSettings.historyPath);
  }

  void _saveSettings() {
    final newSettings = Settings(
      switchLightAndDarkMode: switchLightAndDarkMode,
      themeColor: themeColor,
      language: language,
      historyPath: historyPathController.text,
    );
    widget.onSettingsChanged(newSettings);
  }

  @override
  void dispose() {
    historyPathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: themeColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Light/Dark mode switch
            SwitchListTile(
              title: Text('Light/Dark Mode'),
              value: switchLightAndDarkMode,
              onChanged: (val) {
                setState(() {
                  switchLightAndDarkMode = val;
                });
                _saveSettings();
              },
            ),

            // Color picker
            ListTile(
              title: Text('Theme Color'),
              trailing: ColorIndicator(
                width: 30,
                height: 30,
                color: themeColor,
                onSelect: () async {
                  Color? picked = await showColorPickerDialog(
                    context,
                    themeColor,
                    title: const Text('Select Theme Color'),
                    enableShadesSelection: true,
                    showColorName: true,
                    showColorCode: true,
                  );
                  if (picked != themeColor) 
                  {
                    setState(() {
                      themeColor = picked;
                    });
                    _saveSettings();
                  }
                },
              ),
            ),

            // Language dropdown
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

            // History Path input
            TextFormField(
              controller: historyPathController,
              decoration: InputDecoration(labelText: 'History Path'),
              onFieldSubmitted: (_) => _saveSettings(),
            ),
          ],
        ),
      ),
    );
  }
}
