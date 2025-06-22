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

  Future<void> createFileIfNotExists() async {
    final file = await _localFile;
    if (!await file.exists()) {
      // Leere JSON-Liste schreiben
      await file.writeAsString(json.encode([]));
    }
  }

  /// JSON-Datei lesen und als Liste von Maps zurückgeben
  Future<List<Map<String, dynamic>>> readJson() async {
    try {
      final file = await _localFile;

      if (!await file.exists()) {
        await createFileIfNotExists(); // Wenn Datei nicht existiert, anlegen
      }

      final content = await file.readAsString();
      final List<dynamic> jsonList = json.decode(content);
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error reading JSON file: $e');
      return [];
    }
  }

  /// Liste von JSON-Objekten (Maps) in Datei schreiben
  Future<void> writeJson(List<Map<String, dynamic>> dataList) async {
    try {
      final file = await _localFile;
      final jsonString = json.encode(dataList);
      await file.writeAsString(jsonString);
    } catch (e) {
      debugPrint('Error writing JSON file: $e');
    }
  }

  /// Datei leeren (leere Liste schreiben)
  Future<void> clearFile() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        await file.writeAsString(json.encode([]));
      }
    } catch (e) {
      debugPrint('Error clearing file: $e');
    }
  }
}
