import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'settingsclass.dart';

class SettingsFileStorage {
  final String filename;

  SettingsFileStorage(this.filename);

  Future<File> get _localFile async {
    final directory = await getApplicationCacheDirectory();
    return File('${directory.path}/$filename');
  }

  Future<void> createFileIfNotExists() async {
    final file = await _localFile;
    if (!await file.exists()) {

      final defaultSettings = Settings
      (
        switchLightAndDarkMode: false,
        themeColor: const Color(0xFF2196F3),
        language: 'en',
      );
      await file.writeAsString(json.encode(defaultSettings.toJson()));
    }
  }

  Future<Settings?> readSettings() async {
    try {
      final file = await _localFile;

      if (!await file.exists()) {
        await createFileIfNotExists();
      }

      final content = await file.readAsString();
      final Map<String, dynamic> jsonMap = json.decode(content);
      return Settings.fromJson(jsonMap);
    } catch (e) {
      debugPrint('Error reading Settings file: $e');
      return null;
    }
  }

  Future<void> writeSettings(Settings settings) async {
    try {
      final file = await _localFile;
      final jsonString = json.encode(settings.toJson());
      await file.writeAsString(jsonString);
    } catch (e) {
      debugPrint('Error writing Settings file: $e');
    }
  }

  Future<void> clearFile() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final defaultSettings = Settings(
          switchLightAndDarkMode: false,
          themeColor: const Color(0xFF2196F3),
          language: 'en',
        );
        await file.writeAsString(json.encode(defaultSettings.toJson()));
      }
    } catch (e) {
      debugPrint('Error clearing Settings file: $e');
    }
  }
}
