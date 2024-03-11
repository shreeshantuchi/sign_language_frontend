import 'package:flutter/material.dart';

class Dropdown extends ChangeNotifier {
  String selected = "Namaste";

  void updateSelectedItem(String item) {
    selected = item;
    notifyListeners();
  }
}
