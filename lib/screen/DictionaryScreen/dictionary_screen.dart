import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_language_record_app/Api/dictionary_api.dart';
import 'package:sign_language_record_app/modle/dictionary_modle.dart';
import 'package:sign_language_record_app/provider/reverseScreenProvider/reverese_screen_provider.dart';
import 'package:sign_language_record_app/provider/signDetectState/sign_detect_state_Provider.dart';
import 'package:sign_language_record_app/screen/videoPlayerScreen/video_player.dart';
import 'package:sign_language_record_app/widget/app_button.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.blueAccent,
          titleTextStyle: const TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
          title: const Text('Dictionary'),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20), // Adjust the radius as needed
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FutureBuilder(
                        future: context.read<DictionaryAPi>().getDectionary(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return GridView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: 4.5,
                                crossAxisCount: 1, // Number of columns
                                crossAxisSpacing:
                                    10.0, // Spacing between columns
                                // Spacing between rows
                              ),
                              itemCount: context
                                  .watch<DictionaryAPi>()
                                  .filteredDictionary
                                  .length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 3),
                                  child: AppButton(
                                      height: 80,
                                      vPadding: 20,
                                      text: context
                                          .watch<DictionaryAPi>()
                                          .filteredDictionary[index]
                                          .name,
                                      onPressed: () async {
                                        modelSheet(context
                                            .read<DictionaryAPi>()
                                            .filteredDictionary[index]);
                                      }),
                                );
                              },
                              shrinkWrap: true,
                            );
                          } else {
                            return Padding(
                              padding: EdgeInsetsDirectional.only(top: 300),
                              child: Center(
                                child: Column(
                                  children: [
                                    CircularProgressIndicator(),
                                  ],
                                ),
                              ),
                            );
                          }
                        })
                  ],
                ),
              ),
            ),
            AnimatedPositioned(
              bottom: 0,
              duration: const Duration(milliseconds: 300),
              left: 0,
              child: searchField(),
            ),
          ],
        ),
      ),
    );
  }

  Widget searchField() {
    TextEditingController textEditingController = TextEditingController();
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            child: SizedBox(
              width: 250,
              child: TextField(
                onTap: () => context.read<SignProvider>().updateFocus(true),
                onSubmitted: (value) {
                  context.read<SignProvider>().updateFocus(false);
                  context.read<DictionaryAPi>().filterSearch(value);
                },
                onChanged: (value) =>
                    context.read<DictionaryAPi>().filterSearch(value),
                decoration: const InputDecoration(
                    hintText: "Enter Your Text",
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                            width: 3.0,
                            color:
                                Colors.black // Adjust the width of the border
                            ),
                        borderRadius:
                            BorderRadius.all(const Radius.circular(20)))),
                controller: textEditingController,
              ),
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
                    .read<DictionaryAPi>()
                    .filterSearch(textEditingController.text);
              }),
        ],
      ),
    );
  }

  Future modelSheet(DisctionaryModel disctionaryModel) {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        if (disctionaryModel.stick_url != null) {
          return Container(
            height: 900,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  VideoStack(
                    disctionaryModel: disctionaryModel,
                  ),
                ],
              ),
            ),
          );
        } else {
          return Container(
            height: 500,
            child: Center(
              child: Text("Video is Unavailable"),
            ),
          );
        }
        // Return the content of the bottom sheet
      },
    );
  }
}

class SwitchVideoWidget extends StatelessWidget {
  final DisctionaryModel disctionaryModel;
  const SwitchVideoWidget({Key? key, required this.disctionaryModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<RevereseScreenProvider>(
      builder: (context, provider, child) {
        print(provider.change);
        switch (provider.change) {
          case ChangeState.first:
            return VideoPlayerScreen(
                key: UniqueKey(),
                scalVideo: false,
                videoUrl: disctionaryModel.stick_url!);
          case ChangeState.second:
            print("second");
            return VideoPlayerScreen(
                key: UniqueKey(),
                scalVideo: false,
                videoUrl: disctionaryModel.videoUrl!);
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
}

class VideoStack extends StatefulWidget {
  final DisctionaryModel disctionaryModel;
  const VideoStack({
    super.key,
    required this.disctionaryModel,
  });

  @override
  State<VideoStack> createState() => _VideoStackState();
}

class _VideoStackState extends State<VideoStack> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SwitchVideoWidget(
          disctionaryModel: widget.disctionaryModel,
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            color: context.watch<RevereseScreenProvider>().change !=
                    ChangeState.first
                ? Colors.white.withOpacity(1)
                : Color.fromARGB(255, 0, 0, 0).withOpacity(1),
          ),
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
              size: 50,
              color: context.watch<RevereseScreenProvider>().change ==
                      ChangeState.first
                  ? Colors.white.withOpacity(1)
                  : Color.fromARGB(255, 0, 0, 0).withOpacity(1),
            ),
          ),
        )
      ],
    );
  }
}
