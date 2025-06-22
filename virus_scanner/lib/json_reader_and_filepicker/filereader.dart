import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'scan_history.dart';

class JsonFileStorage 
{
  final String filename;

  JsonFileStorage(this.filename);

  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$filename');
  }

  Future<void> createFileIfNotExists() async {
    final file = await _localFile;
    if (!await file.exists()) {
      await file.writeAsString(json.encode([]));
    }
  }

  /// Liste von ScanHistory lesen
  Future<List<ScanHistory>> readScanHistoryList() async 
  {
    try {
      final file = await _localFile;

      if (!await file.exists()) 
      {
        await createFileIfNotExists();
      }

      final content = await file.readAsString();

      final List<dynamic> jsonList = json.decode(content);

      return jsonList
          .map((item) => ScanHistory.fromJson(item as Map<String, dynamic>))
          .toList();
    } 
    catch (e) 
    {
      debugPrint('Error reading JSON file: $e');
      return [];
    }
  }

  /// Liste von ScanHistory schreiben
  Future<void> writeScanHistoryList(List<ScanHistory> dataList) async
  {
    try 
    {
      final file = await _localFile;
      final jsonList = dataList.map((e) => e.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await file.writeAsString(jsonString);
    } 
    catch (e) 
    {
      debugPrint('Error writing JSON file: $e');
    }
  }

  Future<void> clearFile() async 
  {
    try 
    {
      final file = await _localFile;
      if (await file.exists()) 
      {
        await file.writeAsString(json.encode([]));
      }
    } 
    catch (e) 
    {
      debugPrint('Error clearing file: $e');
    }
  }
}
