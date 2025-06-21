import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'libclamav/clamav.dart';

void main() async{
  if (kIsWeb || (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS)){
    return;
  }

  final result = await clamAVInstalled();

  if (!result){
    return;
  }

  debugPrint('Starting Scan...');
  debugPrint('Virus detected: ${await scanFile('..\\eicar.com')}');
  debugPrint('Scan finished!');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'ICVS – Inefficient ClamAV Scanner'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          ],
        ),
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
