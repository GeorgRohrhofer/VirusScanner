import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:virus_scanner/json_reader_and_filepicker/filereader.dart';
import 'package:virus_scanner/json_reader_and_filepicker/scan_history.dart';
import 'dart:io';
import 'libclamav/clamav.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();
  windowManager.setTitle('ICVS - Inefficient ClamAV Scanner');

  if (kIsWeb ||
      (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS)) {
    return;
  }

  final result = await clamAVInstalled();

  if (!result) {
    return;
  }

  //debugPrint('Starting Scan...');
  //debugPrint('Virus detected: ${await scanFile('..\\eicar.com')}');
  //debugPrint('Scan finished!');

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeData _myTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    brightness: Brightness.light,
  );

  void _changeTheme(ThemeData mode) {
    setState(() {
      _myTheme = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: _myTheme,
      home: MyHomePage(
        title: 'ICVS – Inefficient ClamAV Scanner',
        changeTheme: _changeTheme,
      ),
    );
  }
}

enum ButtonState { file, directory, memory }

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.changeTheme});

  final String title;
  final void Function(ThemeData) changeTheme;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ButtonState currentButtonState = ButtonState.file;
  Brightness darkLightMode = Brightness.light;
  String currentScanPath = '';
  bool scanActive = false;
  String scanHistory = '';
  String activeScan = '';
  JsonFileStorage fileReader = JsonFileStorage('scan_history.json');
  final ScrollController _scanHistoryHorizontalController = ScrollController();

  @override
  void initState() {
    super.initState();

    loadScanHistory();
  }

  void loadScanHistory() async {
    List<ScanHistory> scanHistoryList = await fileReader.readScanHistoryList();

    for (var historyElement in scanHistoryList) {
      addToScanHistory(historyElement);
    }
  }

  void fileButtonPressed() {
    debugPrint('File Button Pressed');
    setState(() {
      currentButtonState = ButtonState.file;
      currentScanPath = ''; // Reset path when switching to file mode
    });
  }

  void dirButtonPressed() {
    debugPrint('Directory Button Pressed');
    setState(() {
      currentButtonState = ButtonState.directory;
      currentScanPath = ''; // Reset path when switching to directory mode
    });
  }

  void memButtonPressed() {
    debugPrint('Memory Button Pressed');
    setState(() {
      currentButtonState = ButtonState.memory;
    });
  }

  void settingsButtonPressed() {
    debugPrint('Settings Button Pressed');

    if (darkLightMode == Brightness.light) {
      makeDarkMode();
      darkLightMode = Brightness.dark;
    } else {
      makeLightMode();
      darkLightMode = Brightness.light;
    }
  }

  void pathButtonPressed() async {
    debugPrint('Choose Path Button Pressed');

    if (currentButtonState == ButtonState.file) {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        setState(() {
          currentScanPath = result.files.single.path!;
        });
      }
    } else if (currentButtonState == ButtonState.directory) {
      String? result = await FilePicker.platform.getDirectoryPath();
      if (result != null) {
        setState(() {
          currentScanPath = result;
        });
      }
    }
  }

  void scanButtonPressed() {
    debugPrint('Scan Button Pressed');

    setState(() {
      scanActive = !scanActive;
    });

    if (scanActive) {
      startScan();
    } else {
      debugPrint('Scan cannot be aborted, lol :(');
    }
  }

  void startScan() {
    switch (currentButtonState) {
      case ButtonState.file:
        _scanFile();
        break;
      case ButtonState.directory:
        _scanDirectory();
        break;
      case ButtonState.memory:
        _scanMemory();
        break;
    }
  }

  void _scanFile() async {
    String scanPath = currentScanPath;
    final virus = await scanFile(scanPath);
    debugPrint('scan result: $virus');

    addToScanHistory(
      ScanHistory(
        inputPath: scanPath,
        date: DateTime.now(),
        wasInfected: virus,
      ),
    );
  }

  void _scanDirectory() async {
    String scanPath = currentScanPath;
    final virus = await scanMultipleFiles(scanPath);
    bool wasInfected = true;

    String result;
    if (virus.isEmpty) {
      result = 'No Viruses Detected';
      wasInfected = false;
    } else {
      result = '';
      for (var line in virus) {
        result = '$result\n$line';
      }
    }
    debugPrint('Scan Result: $result');

    addToScanHistory(
      ScanHistory(
        inputPath: scanPath,
        date: DateTime.now(),
        wasInfected: wasInfected,
      ),
    );
  }

  void _scanMemory() async {
    final List<String> results = await scanMemory(ScanMemoryOptions.none);
    debugPrint('Scan Result: $results');

    addToScanHistory(
      ScanHistory(
        inputPath: 'Memory',
        date: DateTime.now(),
        wasInfected: results.isNotEmpty,
      ),
    );
  }

  void makeLightMode() {
    ThemeData lightTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.light,
      ),
    );

    debugPrint('Changing to Light Mode');

    setState(() {
      widget.changeTheme(lightTheme);
    });
  }

  void makeDarkMode() {
    ThemeData darkTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
    );

    debugPrint('Changing to Dark Mode');

    setState(() {
      widget.changeTheme(darkTheme);
    });
  }

  void changeColors(Color newColor) {
    ThemeData darkTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: newColor,
        brightness: darkLightMode,
      ),
    );

    debugPrint('Changing Color');
    widget.changeTheme(darkTheme);
  }

  void addToScanHistory(ScanHistory newElement) {
    setState(() {
      scanHistory = '$newElement\n$scanHistory';
    });

    fileReader.appendScanHistory(newElement);
  }

  void clearScanHistory() {
    setState(() {
      scanHistory = '';
    });
    fileReader.clearFile();
  }

  bool canStartScan(){
    if (currentButtonState == ButtonState.memory)
    {
      return true;
    }

    if (currentScanPath.isEmpty) {
      return false;
    }
    else
    {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color buttonBackground = Theme.of(context).colorScheme.inversePrimary;
    Color buttonBackgroundPressed = Theme.of(context).colorScheme.primary;
    Color buttonForeGround = Theme.of(context).colorScheme.primary;
    Color buttonForeGroundPressed = Theme.of(
      context,
    ).colorScheme.inversePrimary;
    Color boxBorderColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   title: Text(widget.title),
      //   toolbarHeight: 25,
      //   titleTextStyle: TextStyle(
      //     fontSize: 15,
      //     color: Theme.of(context).colorScheme.primary,
      //   ),
      // ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          children: [
            SizedBox(
              width: 140,
              child: Column(
                children: [
                  SizedBox(
                    width: 120,
                    child: ElevatedButton(
                      onPressed: () => fileButtonPressed(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentButtonState == ButtonState.file
                            ? buttonBackgroundPressed
                            : buttonBackground,
                        foregroundColor: currentButtonState == ButtonState.file
                            ? buttonForeGroundPressed
                            : buttonForeGround,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                      ),
                      child: const Text('File'),
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: ElevatedButton(
                      onPressed: () => dirButtonPressed(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            currentButtonState == ButtonState.directory
                            ? buttonBackgroundPressed
                            : buttonBackground,
                        foregroundColor:
                            currentButtonState == ButtonState.directory
                            ? buttonForeGroundPressed
                            : buttonForeGround,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                      ),
                      child: const Text('Directory'),
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: ElevatedButton(
                      onPressed: () => memButtonPressed(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            currentButtonState == ButtonState.memory
                            ? buttonBackgroundPressed
                            : buttonBackground,
                        foregroundColor:
                            currentButtonState == ButtonState.memory
                            ? buttonForeGroundPressed
                            : buttonForeGround,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                      ),
                      child: const Text('Memory'),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: currentButtonState == ButtonState.memory
                        ? null
                        : () => pathButtonPressed(),
                    child: const Text('Choose Path'),
                  ),
                  currentButtonState == ButtonState.memory
                      ? SizedBox(height: 14)
                      : currentScanPath.isEmpty
                      ? const Text(
                          'No Path Selected',
                          style: TextStyle(fontSize: 10),
                        )
                      : Text(currentScanPath, style: TextStyle(fontSize: 10)),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: canStartScan() ? () => scanButtonPressed() : null,
                    child: scanActive
                        ? const Text('Abort Scan')
                        : const Text('Start Scan'),
                  ),
                  SizedBox(height: 10),
                  scanActive
                      ? CircularProgressIndicator()
                      : SizedBox(height: 36),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text('Active Scan:'),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 42),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: boxBorderColor),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: SingleChildScrollView(child: Text(activeScan)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text('Scan History:'),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: boxBorderColor),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Scrollbar(
                          thumbVisibility: true,
                          controller: _scanHistoryHorizontalController,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            controller: _scanHistoryHorizontalController,
                            child: Text(scanHistory),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Tooltip(
                        message: 'Permanently Delete History',
                        child: SizedBox(
                          width: 40,
                          child: ElevatedButton(
                            onPressed: () => clearScanHistory(),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              alignment: Alignment.center,
                            ),
                            child: Icon(Icons.delete),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 60,
              child: Column(
                children: [
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: Tooltip(
                      message: 'Open Settings',
                      child: ElevatedButton(
                        onPressed: () => settingsButtonPressed(),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          alignment: Alignment.center,
                        ),
                        child: Icon(Icons.settings, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
