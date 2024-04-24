import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

enum ReverseScreenState { initial, fetch, done }

enum ChangeState {
  first,
  second,
}

class RevereseScreenProvider with ChangeNotifier {
  ReverseScreenState reverseScreenState = ReverseScreenState.initial;

  ChangeState change = ChangeState.first;

  void updateReverseScreenState(ReverseScreenState state) {
    reverseScreenState = state;
    notifyListeners();
  }

  void toggle(ChangeState state) {
    change = state;
    print(change);
    notifyListeners();
  }

  void getReverseSignVideo(String text) async {
    updateReverseScreenState(ReverseScreenState.fetch);
    notifyListeners();
    final response =
        await http.get(Uri.parse('http://10.0.2.2:8000/search2/$text'));
    //  print("object2");

    if (response.statusCode == 200) {
      updateReverseScreenState(ReverseScreenState.done);
      //(reverseScreenState.toString());
      notifyListeners();
      // If the server returns a 200 OK response, parse the JSON
    } else {
      // If the server did not return a 200 OK response,
      // throw an exception.
      throw Exception('Failed to load data');
    }
    notifyListeners();
  }
}
