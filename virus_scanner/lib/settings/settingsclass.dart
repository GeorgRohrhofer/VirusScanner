import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'settingsclass.g.dart';

@JsonSerializable()
class Settings {
  final bool switchLightAndDarkMode;

  @JsonKey(fromJson: _colorFromHex, toJson: _colorToHex)
  final Color themeColor;

  final String language;
  final String historyPath;

  Settings({
    required this.switchLightAndDarkMode,
    required this.themeColor,
    required this.language,
    required this.historyPath,
  });

  factory Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsToJson(this);

  static Color _colorFromHex(String hexString) 
  {
    final buffer = StringBuffer();

    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');

    hexString = hexString.replaceFirst('#', '');

    buffer.write(hexString);

    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static String _colorToHex(Color color) =>
      '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
}