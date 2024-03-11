import 'dart:io';

import 'package:flutter/material.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key, required this.allSelectedFile});

  final List<File> allSelectedFile;

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
          itemCount: widget.allSelectedFile.length,
          itemBuilder: (context, index) {
            return const CircularProgressIndicator();
          }),
    );
  }
}
