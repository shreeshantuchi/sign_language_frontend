// ignore_for_file: file_names

import 'dart:typed_data';

import 'package:flutter/material.dart';

enum StreamState { initial, start, end }

enum InitializingState { initial, done }

enum CameraControllerState { initial, start }

class SignProvider extends ChangeNotifier {
  bool isTextFieldFocus = false;

  StreamState? state;
  InitializingState? initializingState;

  CameraControllerState? cameraState;
  Uint8List? iamge;

  void updateFocus(bool focus) {
    isTextFieldFocus = focus;
    notifyListeners();
  }

  void updateImage(Uint8List? iamges) {
    iamge = iamges;
    notifyListeners();
  }

  void updateState(StreamState x) {
    state = x;
    notifyListeners();
  }

  void updateInitializingState(InitializingState x) {
    initializingState = x;
    notifyListeners();
  }

  void updateCameraState(CameraControllerState x) {
    cameraState = x;
    notifyListeners();
  }
}
