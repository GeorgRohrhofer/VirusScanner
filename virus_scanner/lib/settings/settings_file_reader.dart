import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'settingsclass.dart'; // Make sure this contains your Settings class with fromJson/toJson

class SettingsFileStorage {
  final String filename;

  SettingsFileStorage(this.filename);

  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$filename');
  }

  Future<void> createFileIfNotExists() async {
    final file = await _localFile;
    if (!await file.exists()) {
      // Write a default Settings JSON structure
      final defaultSettings = Settings(
        switchLightAndDarkMode: false,
        themeColor: const Color.fromARGB(0, 255, 255, 255),
        language: 'en',
        historyPath: '',
      );
      await file.writeAsString(json.encode(defaultSettings.toJson()));
    }
  }

  /// Read Settings object from file
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

  /// Write Settings object to file
  Future<void> writeSettings(Settings settings) async {
    try {
      final file = await _localFile;
      final jsonString = json.encode(settings.toJson());
      await file.writeAsString(jsonString);
    } catch (e) {
      debugPrint('Error writing Settings file: $e');
    }
  }

  /// Clear settings file (write default settings)
  Future<void> clearFile() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final defaultSettings = Settings(
          switchLightAndDarkMode: false,
          themeColor: const Color(0xFF2196F3),
          language: 'en',
          historyPath: '',
        );
        await file.writeAsString(json.encode(defaultSettings.toJson()));
      }
    } catch (e) {
      debugPrint('Error clearing Settings file: $e');
    }
  }
}
