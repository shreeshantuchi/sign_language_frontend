import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

// ignore: must_be_immutable
class AppButton extends StatelessWidget {
  AppButton(
      {super.key,
      required this.text,
      this.color = const Color(0xff365486),
      this.textColor = Colors.white,
      this.width = 200.0,
      this.height = 50,
      this.vPadding = 10,
      this.icon,
      this.fontSize = 16,
      required this.onPressed});
  final String text;
  Color? color;
  Color? textColor;
  double vPadding;
  double width;
  double height;
  IconData? icon;
  double fontSize;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(12)),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: vPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon == null
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: PhosphorIcon(
                          icon!,
                          color: Colors.white,
                          size: 70,
                        ),
                      ),
                Text(
                  text,
                  style: TextStyle(fontSize: fontSize, color: textColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
