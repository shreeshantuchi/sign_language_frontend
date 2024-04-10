// ignore_for_file: file_names

import 'dart:typed_data';

import 'package:flutter/material.dart';

enum StreamState { initial, start, end }

enum InitializingState { initial, done }

enum CameraControllerState { initial, start }

class SignProvider extends ChangeNotifier {
  bool isTextFieldFocus = false;
  String signText = "";
  List<String> receivedSignText = [];
  List<String> listSignText = [];

  void clearReceivedSignText() {
    receivedSignText.clear();
    notifyListeners();
  }

  void addsignText(String text) {
    listSignText.add(text);
    signText = listSignText.join(" ");
    notifyListeners();
  }

  void addReceivedSignText(String text) {
    if (!receivedSignText.contains(text)) {
      if (receivedSignText.length > 2) {
        receivedSignText.removeAt(0);
      }
      receivedSignText.add(text);
      receivedSignText = removeDuplicates(receivedSignText);
    }
    notifyListeners();
  }

  void deleteSignText() {
    if (listSignText.isNotEmpty) {
      listSignText.removeLast();
    }
    signText = listSignText.join(" ");

    notifyListeners();
  }

  List<T> removeDuplicates<T>(List<T> list) {
    // Convert the list to a set to remove duplicates
    Set<T> set = list.toSet();
    // Convert the set back to a list
    return set.toList();
  }

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
