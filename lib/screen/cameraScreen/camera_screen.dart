// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:sign_language_record_app/screen/cameraScreen/countdownScreen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isRecording = false;

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 5), () {
      _onRecordButtonPressed();
    });
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() async {
    CameraDescription description =
        await availableCameras().then((cameras) => cameras[0]);
    _controller = CameraController(description, ResolutionPreset.medium);
    await _controller!.initialize();
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  Future<void> _onRecordButtonPressed() async {

    if (_isRecording) {
      setState(() {
        _isRecording = !_isRecording;
      });
      final video = await _controller!.stopVideoRecording();
      saveVideoToCustomFolder(video.path, "hello", 2.toString());
    } else {
      await _startVideoRecording();
    }
  }

  Future<void> _startVideoRecording() async {
    

    try {
      await _controller!.startVideoRecording();
      setState(() {
        _isRecording = !_isRecording;
      });
    } catch (e) {
     // print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return Container();
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Camera')),
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: [
                    CameraPreview(_controller!),
                    const CountDownScreen(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      color: _isRecording ? Colors.red : Colors.black,
                      child: IconButton(
                        icon: Icon(
                          _isRecording ? Icons.stop : Icons.fiber_manual_record,
                          color: !_isRecording ? Colors.red : Colors.black,
                        ),
                        onPressed: () {
                          _onRecordButtonPressed();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> saveVideoToCustomFolder(
      String videoPath, String customFolder, String customName) async {
    // Get the app's document directory
    List<Directory>? appDocDir = await getExternalStorageDirectories();

    // Create a custom directory inside the app's document directory
    String customDirPath = '${appDocDir![0].path}/$customFolder';
    Directory customDir = Directory(customDirPath);
    if (!customDir.existsSync()) {
      customDir.createSync();
    }

    // Copy the video to the custom directory with the custom name
    String customFilePath = '$customDirPath/$customName.mp4';

    await File(videoPath).copy(customFilePath);

  }
}
