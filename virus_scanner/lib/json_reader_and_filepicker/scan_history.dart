import 'package:json_annotation/json_annotation.dart';

part 'scan_history.g.dart';

@JsonSerializable()
class ScanHistory {
  final String inputPath;
  final DateTime date;
  final bool wasInfected;

  ScanHistory({
    required this.inputPath,
    required this.date,
    required this.wasInfected,
  });

  @override
  String toString() {
    if (wasInfected){
      return '$date | $inputPath | ⚠️)';
    }
    else
    {
      return '$date | $inputPath | ✅)';
    }
    
  }

  factory ScanHistory.fromJson(Map<String, dynamic> json) =>
      _$ScanHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$ScanHistoryToJson(this);
}
