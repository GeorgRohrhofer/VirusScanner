import 'dart:io'; 

enum ScanMemoryOptions {
  none, 
  kill,
  unload
}

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

Future<bool> scanFile(String filePath) async{
  final result = await Process.run('clamscan', [filePath]);

  if (result.exitCode == 0){
    return true;
  }
  else if (result.exitCode == 1) {
    return false;
  }  
  else {
    throw Exception('Error while scanning: ${result.stderr}');
  }
} 

Future<List<String>> scanMultipleFiles(String rootPath) async {
  var result = <String>[];

  final processResult = await Process.run('clamscan', ['--recursive', rootPath]);

  if (processResult.exitCode != 0 && processResult.exitCode != 1){
    throw Exception('Error while scanning: ${processResult.stderr}');
  }

  //TODO: Filter output to return infected files

  return result;
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

  //TODO: Filter output to return infected memory items
  return <String>[];
}