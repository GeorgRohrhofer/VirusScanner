//GPTGPTGPTGPTGPTGPTGPTGPTGPTGPTGPTGPTGPTGPTGPTGPTGPTGPTGPTGPTGPTGPTGPTGPTGPTGPTGPTGPTGPTGPTGPTGPTGPTGPTGPTGPTGPTGPTGPTGPTGPTGPTGPTGPTGPTGPTGPTGPT

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'libclamav/clamav.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  String _statusFile = "Idle";
  String _statusFolder = "Idle";

  Future<void> _scanFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result?.files.single.path != null) {
      final path = result!.files.single.path!;
      setState(() => _statusFile = "Scanning: $path");

      final virus = await scanFile(path);
      setState(() => _statusFile = virus ? "Virus detected!" : "Clean");
    }
  }

  Future<void> _scanFolder() async {
    String? path = await FilePicker.platform.getDirectoryPath();

    if (path != null)
    {
      setState(() => _statusFolder = "Scanning: $path");

      final virus = await scanMultipleFiles(path);

      String result;
      if (virus.isEmpty)
      {
        result = 'No Viruses Detected';
      }
      else
      {
        result = '';

        for (var line in virus) {
          result = '$result\n$line';
        }
        
      }
      setState(() => _statusFolder = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scanner")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: _scanFile, child: const Text("Scan File")),
            const SizedBox(height: 5),
            Text("Status: $_statusFile"),

            const SizedBox(height: 20),

            ElevatedButton(onPressed: _scanFolder, child: const Text("Scan Folder")),
            const SizedBox(height: 5),
            Text("Status: $_statusFolder"),
          ],
        ),
      ),
    );
  }
}