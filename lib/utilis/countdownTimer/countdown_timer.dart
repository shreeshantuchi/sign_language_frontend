import 'dart:async';

class Counter {
  final int countTimer;
  int count = 0;
  final StreamController<int> counterController = StreamController();

  Counter({required this.countTimer});

  void counterIncrement() {
    count++;

    counterController.add(count);
  }

  Stream<int> get countStream => counterController.stream;

  void startTimer() {
    // Run the program for 5 seconds

    Timer timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      counterIncrement();
    });

    Future.delayed(Duration(seconds: countTimer), () {
      timer.cancel();
    });

    // Cancel the timer and dispose of resources when done
  }
}
