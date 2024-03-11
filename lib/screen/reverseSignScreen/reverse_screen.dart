import 'package:flutter/material.dart';
import 'package:sign_language_record_app/Api/dictionary_api.dart';
import 'package:sign_language_record_app/screen/videoPlayerScreen/video_player.dart';
import 'package:sign_language_record_app/widget/app_button.dart';
import 'package:provider/provider.dart';

class ReverseScreen extends StatefulWidget {
  const ReverseScreen({super.key});

  @override
  State<ReverseScreen> createState() => _ReverseScreenState();
}

class _ReverseScreenState extends State<ReverseScreen> {
  @override
  Widget build(BuildContext context) {
    TextEditingController _textEditingController = TextEditingController();
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SwitchWidget(),
            SizedBox(
              width: 20,
            ),
            Text("Enter your text"),
            TextField(
              controller: _textEditingController,
            ),
            SizedBox(
              height: 20,
            ),
            AppButton(
                text: "Submit",
                onPressed: () {
                  context
                      .read<DictionaryAPi>()
                      .getReverseSignVideo(_textEditingController.text);
                }),
            Text(context.watch<DictionaryAPi>().state.toString()),
          ],
        ),
      ),
    );
  }
}

class SwitchWidget extends StatelessWidget {
  final String switchCase =
      'case1'; // Change this value based on your condition

  @override
  Widget build(BuildContext context) {
    switch (context.watch<DictionaryAPi>().state) {
      case 3:
        return SizedBox.shrink();
      case 4:
        return VideoPlayerScreen(
            videoUrl: "http://10.0.2.2:8000/media/output/video.mp4");

      default:
        return SizedBox.shrink();
    }
  }
}
