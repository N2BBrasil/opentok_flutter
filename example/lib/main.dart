import 'dart:async';

import 'package:flutter/material.dart';
import 'package:opentok_flutter/opentok.dart';
import 'package:opentok_flutter/opentok_view.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late OpenTokConfig _config;
  OpenTokController? _controller;
  bool isFullScreen = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initPlatformState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _controller?.resume();
        break;
      case AppLifecycleState.paused:
        _controller?.pause();
        break;
      default:
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    _config = OpenTokConfig(
      apiKey: "47107444",
      sessionId:
          "2_MX40NzEwNzQ0NH5-MTY4OTAxNzY4ODEzN356UzFkVkY4MFVYaFdURHF3NExXYmRTNXl-fn4",
      token:
          "T1==cGFydG5lcl9pZD00NzEwNzQ0NCZzaWc9OGRiM2VlYjE5Yzg1OTgzMDQyZWZjMTIzN2VmNDkxNmNjYzMzZGU1ODpzZXNzaW9uX2lkPTJfTVg0ME56RXdOelEwTkg1LU1UWTRPVEF4TnpZNE9ERXpOMzU2VXpGa1ZrWTRNRlZZYUZkVVJIRjNORXhYWW1SVE5YbC1mbjQmY3JlYXRlX3RpbWU9MTY4OTAxNzcwMiZub25jZT0wLjkyNjU5MDMxMDI2MzYzNDEmcm9sZT1wdWJsaXNoZXImZXhwaXJlX3RpbWU9MTY4OTAzOTMwMSZpbml0aWFsX2xheW91dF9jbGFzc19saXN0PQ==",
    );

    _controller = OpenTokController();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.camera,
        Permission.microphone,
      ].request();
      final isGranted =
          statuses[Permission.camera] == PermissionStatus.granted &&
              statuses[Permission.microphone] == PermissionStatus.granted;
      if (isGranted) {
        _controller?.initSession(_config);
      } else {
        debugPrint(
            "Camera or Microphone permission or both denied by the user!");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
        actions: [
          IconButton(
            onPressed: () => _controller?.initSession(_config),
            icon: const Icon(Icons.video_call_rounded),
          )
        ],
      ),
      body: SizedBox(
        height: isFullScreen
            ? MediaQuery.of(context).size.height
            : MediaQuery.of(context).size.height * 0.5,
        child: OpenTokView(
          controller: _controller ?? OpenTokController(),
          padding: const EdgeInsets.only(bottom: 10),
          onFullScreenButtonTap: () =>
              setState(() => isFullScreen = !isFullScreen),
          onEndButtonTap: () async {
            _controller?.endSession();
          },
          onCameraButtonTap: () {
            // _controller?.setAudioDevice(SoundOutputDevice.SPEAKER);
          },
          onMicButtonTap: (isEnabled) {
            _controller?.toggleAudio(!isEnabled);
          },
          onVideoButtonTap: (isEnabled) => _controller?.toggleVideo(!isEnabled),
        ),
      ),
    );
  }
}
