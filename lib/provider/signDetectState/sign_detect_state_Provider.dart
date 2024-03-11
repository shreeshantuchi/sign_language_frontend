import 'package:flutter/material.dart';

enum StreamState { initial, start, end }

class SignProvider extends ChangeNotifier {
  StreamState? state;

  void updateState(StreamState x) {
    state = x;
    notifyListeners();
  }
}
