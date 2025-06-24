// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settingsclass.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Settings _$SettingsFromJson(Map<String, dynamic> json) => Settings(
  switchLightAndDarkMode: json['switchLightAndDarkMode'] as bool,
  themeColor: Settings._colorFromHex(json['themeColor'] as String),
  language: json['language'] as String,
);

Map<String, dynamic> _$SettingsToJson(Settings instance) => <String, dynamic>{
  'switchLightAndDarkMode': instance.switchLightAndDarkMode,
  'themeColor': Settings._colorToHex(instance.themeColor),
  'language': instance.language,
};
