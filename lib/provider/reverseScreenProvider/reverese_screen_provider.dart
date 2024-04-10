import 'package:flutter/material.dart';

class RevereseScreenProvider with ChangeNotifier {
  bool change = false;

  void toggle() {
    change = !change;
    notifyListeners();
  }
}
