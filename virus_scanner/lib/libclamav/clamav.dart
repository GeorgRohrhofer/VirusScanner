import 'dart:convert';
import 'dart:io'; 

enum ScanMemoryOptions {
  none, 
  kill,
  unload
} 

Process? _process;

Future<bool> clamAVInstalled() async {
  try {
    await Process.run('clamscan', ['--version']);
  }
  catch (e){
    return false;
  }

  try {
    await Process.run('freshclam', ['--version']);
  }
  catch (e){
    return false;
  }

  return true;
}

Future<bool> updateDatabase() async{
  final result = await Process.run('freshclam', []); 

  if (result.exitCode == 0){
    return true;
  }
  else if (result.exitCode == 1){
    return false;
  }
  else {
    throw Exception('Error while updating: ${result.stderr}');
  }
}

/// Scan a single file.
/// Returns true if a virus is detected, otherwise false
/// Raises an Exception if scan failes
Future<bool> scanFile(String filePath) async{
  final result = await Process.run('clamscan', [filePath]);

  if (result.exitCode == 0){
    return false;
  }
  else if (result.exitCode == 1) {
    return true;
  }  
  else {
    throw Exception('Error while scanning: ${result.stderr}');
  }
} 

/// Scan the files in this and all subdirectories.
/// Returns a list of filepaths
Future<List<String>> scanMultipleFiles(String rootPath) async {
  final processResult = await Process.run('clamscan', ['--recursive', '-i', rootPath]);

  if (processResult.exitCode != 0 && processResult.exitCode != 1){
    throw Exception('Error while scanning: ${processResult.stderr}');
  }

  if(processResult.stdout is String){
    String output = processResult.stdout;
    final lines = output.split('\n');

    final pathRegex = RegExp(r'([a-zA-Z]:\\[^\s]+|\/[^\s]+)');

    final pathLines = lines.where((line) => pathRegex.hasMatch(line)).map((line) => line.split(':').first).toList();

    return pathLines; 
  }

  throw TypeError();
}

/// Scan multiple files and get live output updated in [ouputLines].
/// Returns a list of filepaths of infected files.
/// [onUpdate] - This function should is called, if a new line is added. Use this function to react to changes in output.
Future<List<String>> scanMultipleFilesLive(String rootPath, List<String> outputLines, void Function() onUpdate) async {
  _process = await Process.start('clamscan', ['--recursive', rootPath]); 

  _process!.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
    outputLines.add(line);
    onUpdate();
  });

  await _process!.exitCode;

  final pathLines = outputLines.where((line) => line.contains('FOUND')).map((line) => line.split(':').first).toList();
  return pathLines; 
}

bool stopLiveScanProcess(){
  if (_process != null && _process!.kill()){
    _process = null;
    return true;
  } 
  return false;
}

Future<List<String>> scanMemory(ScanMemoryOptions option) async {
  ProcessResult processResult;
  
  switch (option)
  {
    case ScanMemoryOptions.none:  
      processResult = await Process.run('clamscan', ['--memory']);

    case ScanMemoryOptions.kill:
      processResult = await Process.run('clamscan', ['--memory', '--kill']);

    case ScanMemoryOptions.unload:
      processResult = await Process.run('clamscan', ['--memory', '--unload']);
  }

  if (processResult.exitCode != 0 && processResult.exitCode != 1){
    throw Exception('Error while scanning memory with option $option: ${processResult.stderr}');
  } 

  if(processResult.stdout is String){
    String output = processResult.stdout;
    final lines = output.split('\n');

    final pathRegex = RegExp(r'([a-zA-Z]:\\[^\s]+|\/[^\s]+)');

    final pathLines = lines.where((line) => pathRegex.hasMatch(line)).toList();

    return pathLines; 
  }

  throw TypeError();
}