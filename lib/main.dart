import 'package:flutter/material.dart';
import 'dart:async';

import 'package:receive_sharing_intent/receive_sharing_intent.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription _intentSub;
  final _sharedFiles = <SharedMediaFile>[];

  @override
  void initState() {
    super.initState();

    // Listen to media sharing coming from outside the app while the app is in the memory.
    _intentSub = ReceiveSharingIntent.getMediaStream().listen((value) {
      setState(() {
        _sharedFiles.clear();
        _sharedFiles.addAll(value);
      });
    }, onError: (err) {
      throw ("getIntentDataStream error: $err");
    });

    // Get the media sharing coming from outside the app while the app is closed.
    ReceiveSharingIntent.getInitialMedia().then((value) {
      setState(() {
        _sharedFiles.clear();
        _sharedFiles.addAll(value);

        // Tell the library that we are done processing the intent.
        ReceiveSharingIntent.reset();
      });
    });
  }

  @override
  void dispose() {
    _intentSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Example app'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Shared files:",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text("Images"),
            for (var file in _sharedFiles
                .where((element) => element.type == SharedMediaType.image)) ...[
              Text("File: ${file.path}"),
            ],
            const SizedBox(height: 8),
            const Text("Pdfs"),
            for (var file in _sharedFiles
                .where((element) => element.type == SharedMediaType.file)) ...[
              Text("File: ${file.path}"),
            ],
          ],
        ),
      ),
    );
  }
}
