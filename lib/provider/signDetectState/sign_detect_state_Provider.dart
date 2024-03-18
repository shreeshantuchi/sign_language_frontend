// ignore_for_file: file_names

import 'dart:typed_data';

import 'package:flutter/material.dart';

enum StreamState { initial, start, end }

class SignProvider extends ChangeNotifier {
  StreamState? state;
  Uint8List? iamge;
  void updateImage(Uint8List? iamges) {
    iamge = iamges;
    notifyListeners();
  }

  void updateState(StreamState x) {
    state = x;
    notifyListeners();
  }
}
