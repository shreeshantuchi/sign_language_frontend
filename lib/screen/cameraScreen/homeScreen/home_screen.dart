// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:sign_language_record_app/screen/listScreen/list_screen.dart';
import 'package:sign_language_record_app/screen/reverseSignScreen/reverse_screen.dart';
import 'package:sign_language_record_app/screen/signLanguageScreen/si_language_screen.dart';
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
      backgroundColor: const Color(0xffDCF2F1),
      appBar: AppBar(
        backgroundColor: const Color(0xffDCF2F1),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: buttonList(),
        // child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        //   Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       AppButton(
        //           icon: PhosphorIcons.upload(),
        //           height: 150,
        //           width: 150,
        //           text: "Upload NSL Videos",
        //           onPressed: () async {
        //             FilePickerResult? result = await FilePicker.platform
        //                 .pickFiles(allowMultiple: true);

        //             if (result != null) {
        //               List<File> files =
        //                   result.paths.map((path) => File(path!)).toList();
        //               // ignore: duplicate_ignore
        //               // ignore: use_build_context_synchronously
        //               Navigator.push(
        //                   context,
        //                   MaterialPageRoute(
        //                       builder: (context) => ListScreen(
        //                             fileList: files,
        //                           )));
        //             } else {
        //               // User canceled the picker
        //             }
        //           }),
        //       AppButton(
        //         height: 150,
        //         width: 150,
        //         icon: PhosphorIcons.scissors(),
        //         text: "Trim Videos",
        //         onPressed: () => _pickVideo(),
        //       ),
        //     ],
        //   ),
        //   const SizedBox(
        //     height: 30,
        //   ),
        //   Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [

        //       AppButton(
        //         height: 150,
        //         width: 150,
        //         icon: PhosphorIcons.video(),
        //         text: "Reverse Sign",
        //         onPressed: () => Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //             builder: (cobetext) => const ReverseScreen(),
        //           ),
        //         ),
        //       ),
        //       AppButton(
        //           height: 150,
        //           width: 150,
        //           text: "Detect\nSign Language",
        //           onPressed: () async {
        //             final cameras = await availableCameras();
        //             final camera = cameras.first;
        //             Navigator.push(
        //               context,
        //               MaterialPageRoute(
        //                 builder: (cobetext) => SignLanguageScreen(
        //                   camera: camera,
        //                 ),
        //               ),
        //             );
        //           }),
        //     ],
        //   ),
        // ]),
      ),
    );
  }

  Widget buttonList() {
    return Column(
      children: [
        CustomButton(
            height: 250,
            width: 400,
            color: Colors.redAccent,
            textColor: Colors.white,
            text: "Sign\nTo\nText",
            onTap: () async {
              final cameras = await availableCameras();
              final camera = cameras.first;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (cobetext) => SignLanguageScreen(
                    camera: camera,
                  ),
                ),
              );
            }),
        const SizedBox(
          height: 20,
        ),
        CustomButton(
            height: 180,
            width: 400,
            color: Colors.pinkAccent,
            textColor: Colors.white,
            text: "Text\nTo\nSign",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (cobetext) => const ReverseScreen(),
                ),
              );
            }),
        const SizedBox(
          height: 20,
        ),
        CustomButton(
            height: 180,
            width: 400,
            color: Colors.blueAccent,
            textColor: Colors.white,
            text: "Dictionary",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (cobetext) => const ListScreen(
                    fileList: [],
                  ),
                ),
              );
            }),
      ],
    );
  }
}

class CustomButton extends StatelessWidget {
  const CustomButton(
      {super.key,
      required this.height,
      required this.width,
      required this.color,
      required this.textColor,
      required this.text,
      required this.onTap});
  final double height;
  final double width;
  final Color color;
  final Color textColor;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadiusDirectional.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: textColor),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    size: 30,
                    Icons.arrow_right_alt,
                    color: textColor,
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
