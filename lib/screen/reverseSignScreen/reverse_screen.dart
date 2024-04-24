import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sign_language_record_app/Api/dictionary_api.dart';
import 'package:sign_language_record_app/provider/reverseScreenProvider/reverese_screen_provider.dart';
import 'package:sign_language_record_app/provider/signDetectState/sign_detect_state_Provider.dart';
import 'package:sign_language_record_app/screen/videoPlayerScreen/video_player.dart';
import 'package:sign_language_record_app/widget/app_button.dart';
import 'package:provider/provider.dart';

class ReverseScreen extends StatefulWidget {
  const ReverseScreen({super.key});

  @override
  State<ReverseScreen> createState() => _ReverseScreenState();
}

class _ReverseScreenState extends State<ReverseScreen> {
  TextEditingController textEditingController = TextEditingController();
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context
            .read<RevereseScreenProvider>()
            .updateReverseScreenState(ReverseScreenState.initial);
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: AppBar(
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.white),
            backgroundColor: Colors.redAccent,
            titleTextStyle: const TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
            title: const Text('Text -> Sign'),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20), // Adjust the radius as needed
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
          child: Stack(
            children: [
              const SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    SwitchWidget(),
                    SizedBox(
                      height: 250,
                    ),
                  ],
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                bottom: 0,
                left: 15,
                child: searchField(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Row searchField() {
    return Row(
      children: [
        SizedBox(
          width: 250,
          child: TextField(
            onTap: () => context.read<SignProvider>().updateFocus(true),
            onSubmitted: (value) {
              context.read<SignProvider>().updateFocus(false);
              context
                  .read<RevereseScreenProvider>()
                  .getReverseSignVideo(textEditingController.text);
            },
            decoration: const InputDecoration(
                hintText: "Enter Your Text",
                border: OutlineInputBorder(
                    borderSide: BorderSide(
                        width: 3.0,
                        color: Colors.black // Adjust the width of the border
                        ),
                    borderRadius: BorderRadius.all(const Radius.circular(20)))),
            controller: textEditingController,
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        AppButton(
            width: 90,
            text: "Submit",
            onPressed: () {
              FocusScope.of(context).unfocus();
              context.read<SignProvider>().updateFocus(false);
              context
                  .read<RevereseScreenProvider>()
                  .getReverseSignVideo(textEditingController.text);
            }),
      ],
    );
  }
}

class SwitchWidget extends StatelessWidget {
  const SwitchWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<RevereseScreenProvider>(
      builder: (context, provider, child) {
        switch (provider.reverseScreenState) {
          case ReverseScreenState.initial:
            return Container(
              height: 300,
              width: 400,
              color: Colors.grey[400],
            );
          case ReverseScreenState.fetch:
            return Container(
              height: 300,
              width: 400,
              color: Colors.grey[400],
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            );
          case ReverseScreenState.done:
            return VideoStack();
          default:
            return SizedBox.shrink();
        }
      },
    );
  }
}

class VideoStack extends StatefulWidget {
  const VideoStack({
    super.key,
  });

  @override
  State<VideoStack> createState() => _VideoStackState();
}

class _VideoStackState extends State<VideoStack> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        VideoPlayerScreen(
          scalVideo: true,
          videoUrl:
              context.read<RevereseScreenProvider>().change == ChangeState.first
                  ? "http://10.0.2.2:8000/media/output/stick_figure_video.mp4"
                  : "http://10.0.2.2:8000/media/output/video.mp4",
        ),
        Positioned(
          top: 10,
          right: 10,
          child: IconButton(
            onPressed: () => context.read<RevereseScreenProvider>().change ==
                    ChangeState.first
                ? context
                    .read<RevereseScreenProvider>()
                    .toggle(ChangeState.second)
                : context
                    .read<RevereseScreenProvider>()
                    .toggle(ChangeState.first),
            icon: Icon(
              Icons.change_circle,
              size: 30,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        )
      ],
    );
  }
}
