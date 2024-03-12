
// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:sign_language_record_app/utilis/countdownTimer/countdown_timer.dart';

class CountDownScreen extends StatefulWidget {
  const CountDownScreen({super.key});

  @override
  State<CountDownScreen> createState() => _CountDownScreenState();
}

class _CountDownScreenState extends State<CountDownScreen> {
  Counter counter = Counter(countTimer: 5);
  @override
  void initState() {
    counter.startTimer();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: counter.countStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data! <= 4
              ? Scaffold(
                  backgroundColor: Colors.grey.withOpacity(0.7),
                  body: Center(
                      child: Text(
                    snapshot.data.toString(),
                    style: const TextStyle(fontSize: 100),
                  )),
                )
              : const SizedBox.shrink();
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
