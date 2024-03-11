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
    TextEditingController textEditingController = TextEditingController();
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                decoration: const InputDecoration(hintText: "Enter Your Text"),
                controller: textEditingController,
              ),
              const SizedBox(
                height: 20,
              ),
              AppButton(
                  text: "Submit",
                  onPressed: () {
                    context
                        .read<DictionaryAPi>()
                        .getReverseSignVideo(textEditingController.text);
                  }),
              const SizedBox(
                height: 40,
              ),
              const SwitchWidget(),
              Text(
                  context.watch<DictionaryAPi>().reverseScreenState.toString()),
            ],
          ),
        ),
      ),
    );
  }
}

class SwitchWidget extends StatelessWidget {
  final String switchCase = 'case1';

  const SwitchWidget({super.key}); // Change this value based on your condition

  @override
  Widget build(BuildContext context) {
    switch (context.watch<DictionaryAPi>().reverseScreenState) {
      case ReverseScreenState.initial:
        return const SizedBox.shrink();
      case ReverseScreenState.fetch:
        return const CircularProgressIndicator();
      case ReverseScreenState.done:
        return const VideoPlayerScreen(
            videoUrl: "http://10.0.2.2:8000/media/output/video.mp4");

      default:
        return const SizedBox.shrink();
    }
  }
}
