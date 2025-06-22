// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScanHistory _$ScanHistoryFromJson(Map<String, dynamic> json) => ScanHistory(
  inputPath: json['inputPath'] as String,
  date: DateTime.parse(json['date'] as String),
  wasInfected: json['wasInfected'] as bool,
);

Map<String, dynamic> _$ScanHistoryToJson(ScanHistory instance) =>
    <String, dynamic>{
      'inputPath': instance.inputPath,
      'date': instance.date.toIso8601String(),
      'wasInfected': instance.wasInfected,
    };
