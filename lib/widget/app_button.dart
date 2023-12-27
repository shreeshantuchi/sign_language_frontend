import 'dart:ffi';

import 'package:flutter/material.dart';

// ignore: must_be_immutable
class AppButton extends StatelessWidget {
  AppButton(
      {super.key,
      required this.text,
      this.color = Colors.amber,
      this.textColor = Colors.white,
      this.width = 200.0,
      this.vPadding = 10,
      required this.onPressed});
  final String text;
  Color? color;
  Color? textColor;
  double vPadding;
  double width;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(12)),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: vPadding),
            child: Text(
              text,
              style: TextStyle(fontSize: 16, color: textColor),
            ),
          ),
        ),
      ),
    );
  }
}
