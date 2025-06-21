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
  String _status = "Idle";

  Future<void> _scanFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result?.files.single.path != null) {
      final path = result!.files.single.path!;
      setState(() => _status = "Scanning: $path");

      final virus = await scanFile(path);
      setState(() => _status = virus ? "Virus detected!" : "Clean");
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
            const SizedBox(height: 20),
            Text("Status: $_status"),
          ],
        ),
      ),
    );
  }
}