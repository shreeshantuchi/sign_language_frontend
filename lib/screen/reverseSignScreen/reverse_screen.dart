import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:searchfield/searchfield.dart';
import 'package:sign_language_record_app/Api/dictionary_api.dart';
import 'package:sign_language_record_app/provider/reverseScreenProvider/reverese_screen_provider.dart';
import 'package:sign_language_record_app/provider/signDetectState/sign_detect_state_Provider.dart';
import 'package:sign_language_record_app/screen/videoEditorScreen/video_editor_screen.dart';
import 'package:sign_language_record_app/screen/videoPlayerScreen/video_player.dart';
import 'package:sign_language_record_app/widget/app_button.dart';
import 'package:provider/provider.dart';

class ReverseScreen extends StatefulWidget {
  const ReverseScreen({super.key});

  @override
  State<ReverseScreen> createState() => _ReverseScreenState();
}

class _ReverseScreenState extends State<ReverseScreen> {
  Future? _future;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    _future = context.read<DictionaryAPi>().getDectionary();
    // TODO: implement initState
    super.initState();
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
    List<String> listWords = [];
    return Row(
      children: [
        SizedBox(
          width: 400,
          child: FutureBuilder(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return SearchFieldSample(
                    textEditingController: textEditingController,
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }),
          //  TextField(
          //   onTap: () => context.read<SignProvider>().updateFocus(true),
          //   onSubmitted: (value) {
          //     context.read<SignProvider>().updateFocus(false);
          //     context
          //         .read<RevereseScreenProvider>()
          //         .getReverseSignVideo(textEditingController.text);
          //   },
          //   decoration: const InputDecoration(
          //       hintText: "Enter Your Text",
          //       border: OutlineInputBorder(
          //           borderSide: BorderSide(
          //               width: 3.0,
          //               color: Colors.black // Adjust the width of the border
          //               ),
          //           borderRadius: BorderRadius.all(const Radius.circular(20)))),
          //   controller: textEditingController,
          // ),
        ),
      ],
    );
  }
}

class SearchFieldSample extends StatefulWidget {
  const SearchFieldSample({
    super.key,
    required this.textEditingController,
  });
  final TextEditingController textEditingController;

  @override
  State<SearchFieldSample> createState() => _SearchFieldSampleState();
}

class _SearchFieldSampleState extends State<SearchFieldSample> {
  List<String> individualString = [];
  int suggestionsCount = 12;
  final focus = FocusNode();

  @override
  void initState() {
    suggestions =
        List.generate(suggestionsCount, (index) => 'suggestion $index');
    super.initState();
  }

  String joinWords(List<String> words) {
    return words.join(' ');
  }

  List<String> stringToListOfWords(String sentence) {
    // Split the sentence into words based on whitespace
    List<String> words = sentence.split(' ');
    return words;
  }

  String getLastWord(String sentence) {
    // Split the sentence into words
    List<String> words = sentence.split(' ');

    // Get the last word
    String lastWord = words.isNotEmpty ? words.last : '';

    return lastWord;
  }

  var suggestions = <String>[];
  @override
  Widget build(BuildContext context) {
    Widget searchChild(x) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12),
          child: Text(x,
              style: const TextStyle(fontSize: 24, color: Colors.black)),
        );
    return Row(
      children: [
        Container(
          width: 250,
          child: SearchField(
            suggestionDirection: SuggestionDirection.up,
            onSearchTextChanged: (query) {
              individualString = stringToListOfWords(query);

              context.read<DictionaryAPi>().filterSearch(getLastWord(query));
              return context
                  .read<DictionaryAPi>()
                  .filteredDictionary
                  .map((e) => SearchFieldListItem<String>(e.name,
                      child: searchChild(e.name)))
                  .toList();
            },
            onTap: () {},
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null || value.length < 4) {
                return 'error';
              }
              return null;
            },
            key: const Key('searchfield'),
            hint: 'Enter your Text',
            controller: textEditingController,
            itemHeight: 50,
            scrollbarDecoration: ScrollbarDecoration(),
            //   thumbVisibility: true,
            //   thumbColor: Colors.red,
            //   fadeDuration: const Duration(milliseconds: 3000),
            //   trackColor: Colors.blue,
            //   trackRadius: const Radius.circular(10),
            // ),
            onTapOutside: (x) {},
            suggestionStyle: const TextStyle(fontSize: 24, color: Colors.black),
            searchInputDecoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(
                  width: 1,
                  color: Colors.orange,
                  style: BorderStyle.solid,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(
                  width: 1,
                  color: Colors.black,
                  style: BorderStyle.solid,
                ),
              ),
              fillColor: Colors.white,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
            ),
            suggestionsDecoration: SuggestionDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.orange),
              borderRadius: BorderRadius.circular(12),
            ),
            suggestions: context
                .read<DictionaryAPi>()
                .filteredDictionary
                .map((e) => SearchFieldListItem<String>(e.name,
                    child: searchChild(e.name)))
                .toList(),
            focusNode: focus,
            suggestionState: Suggestion.expand,
            onSuggestionTap: (SearchFieldListItem<String> x) {
              print(textEditingController.text);
              if (textEditingController.text.isNotEmpty) {
                individualString.removeLast();
              }
              individualString.add(x.searchKey);
              textEditingController.text = joinWords(individualString);
            },
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
            return const VideoStack();
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
}

class SwitchVideoWidget extends StatelessWidget {
  const SwitchVideoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<RevereseScreenProvider>(
      builder: (context, provider, child) {
        print(provider.change);
        switch (provider.change) {
          case ChangeState.first:
            return VideoPlayerScreen(
                key: UniqueKey(),
                scalVideo: true,
                videoUrl:
                    "http://10.0.2.2:8000/media/output/stick_figure_video.mp4");
          case ChangeState.second:
            print("second");
            return VideoPlayerScreen(
                key: UniqueKey(),
                scalVideo: false,
                videoUrl: "http://10.0.2.2:8000/media/output/normal_video.mp4");
          default:
            return const SizedBox.shrink();
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
        const SwitchVideoWidget(),
        IconButton(
          onPressed: () =>
              context.read<RevereseScreenProvider>().change == ChangeState.first
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
                ? Colors.white.withOpacity(0.5)
                : Colors.black.withOpacity(0.5),
          ),
        )
      ],
    );
  }
}
