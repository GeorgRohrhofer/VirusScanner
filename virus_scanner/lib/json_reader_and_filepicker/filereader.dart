import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart'; // für debugPrint

class JsonFileStorage {
  final String filename;

  JsonFileStorage(this.filename);

  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$filename');
  }

  Future<void> createFileIfNotExists() async
  {
    final file = await _localFile;
    if (!await file.exists()) {
      // Datei mit leerem JSON-Objekt anlegen
      await file.writeAsString(json.encode({}));
    }
  }

  /// JSON-Datei lesen und als Map zurückgeben
  Future<Map<String, dynamic>?> readJson() async {
    try {
      final file = await _localFile;

      if (!await file.exists()) {
        return null; // Datei existiert nicht
      }

      final content = await file.readAsString();
      return json.decode(content) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error reading JSON file: $e');
      return null;
    }
  }

  /// JSON-Daten (Map) in Datei schreiben
  Future<void> writeJson(Map<String, dynamic> data) async {
    try {
      final file = await _localFile;
      final jsonString = json.encode(data);
      await file.writeAsString(jsonString);
    } catch (e) {
      debugPrint('Error writing JSON file: $e');
    }
  }

  /// Datei leeren (löschen)
  Future<void> clearFile() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        await file.writeAsString(''); // Dateiinhalt löschen
      }
    } catch (e) {
      debugPrint('Error clearing file: $e');
    }
  }
}
