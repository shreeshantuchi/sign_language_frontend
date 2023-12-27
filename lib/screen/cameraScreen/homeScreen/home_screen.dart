// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:sign_language_record_app/screen/listScreen/list_screen.dart';
import 'package:sign_language_record_app/screen/videoEditorScreen/video_editor_screen.dart';
import 'package:sign_language_record_app/widget/app_button.dart';

import 'package:file_picker/file_picker.dart';

import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();

  void _pickVideo() async {
    final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);

    if (mounted && file != null) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => VideoEditor(file: File(file.path)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          AppButton(
              text: "Upload NSL Videos",
              onPressed: () async {
                FilePickerResult? result =
                    await FilePicker.platform.pickFiles(allowMultiple: true);

                if (result != null) {
                  List<File> files =
                      result.paths.map((path) => File(path!)).toList();
                  // ignore: use_build_context_synchronously
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ListScreen(
                                fileList: files,
                              )));
                } else {
                  // User canceled the picker
                }
              }),
          const SizedBox(
            height: 12,
          ),
          AppButton(text: "Trim Videos", onPressed: () => _pickVideo()),
        ]),
      ),
    );
  }
}
