import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_language_record_app/Api/dictionary_api.dart';
import 'package:sign_language_record_app/modle/dictionary_modle.dart';
import 'package:sign_language_record_app/provider/signDetectState/sign_detect_state_Provider.dart';
import 'package:sign_language_record_app/screen/videoPlayerScreen/video_player.dart';
import 'package:sign_language_record_app/widget/app_button.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  Future<List<DisctionaryModel>> apiText() async {
    List<DisctionaryModel> testList = [
      DisctionaryModel(
        name: "Namaste",
        id: 2,
        videoUrl:
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
      ),
      DisctionaryModel(
        name: "Namaste",
        id: 2,
        videoUrl: "https://www.youtube.com/watch?v=uEz8ob2aXoo",
      ),
      DisctionaryModel(
        name: "Namaste",
        id: 2,
        videoUrl: "https://www.youtube.com/watch?v=uEz8ob2aXoo",
      ),
      DisctionaryModel(
        name: "Namaste",
        id: 2,
        videoUrl: "https://www.youtube.com/watch?v=uEz8ob2aXoo",
      ),
      DisctionaryModel(
        name: "Namaste",
        id: 2,
        videoUrl: "https://www.youtube.com/watch?v=uEz8ob2aXoo",
      ),
      DisctionaryModel(
          name: "Namaste",
          id: 2,
          videoUrl: "https://www.youtube.com/watch?v=uEz8ob2aXoo"),
      DisctionaryModel(
          name: "Namaste",
          id: 2,
          videoUrl: "https://www.youtube.com/watch?v=uEz8ob2aXoo"),
      DisctionaryModel(
          name: "Namaste",
          id: 2,
          videoUrl: "https://www.youtube.com/watch?v=uEz8ob2aXoo"),
      DisctionaryModel(
          name: "Namaste",
          id: 2,
          videoUrl: "https://www.youtube.com/watch?v=uEz8ob2aXoo"),
      DisctionaryModel(
          name: "Namaste",
          id: 2,
          videoUrl: "https://www.youtube.com/watch?v=uEz8ob2aXoo"),
      DisctionaryModel(
          name: "Namaste",
          id: 2,
          videoUrl: "https://www.youtube.com/watch?v=uEz8ob2aXoo"),
      DisctionaryModel(
          name: "Namaste",
          id: 2,
          videoUrl: "https://www.youtube.com/watch?v=uEz8ob2aXoo"),
      DisctionaryModel(
          name: "Namaste",
          id: 2,
          videoUrl: "https://www.youtube.com/watch?v=uEz8ob2aXoo"),
    ];
    await Future.delayed(Duration(seconds: 5));
    return testList;
  }

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
                        future:
                            apiText(), //context.read<DictionaryAPi>().getDectionary(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return GridView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, // Number of columns
                                crossAxisSpacing:
                                    10.0, // Spacing between columns
                                mainAxisSpacing: 10.0, // Spacing between rows
                              ),
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: AppButton(
                                      height: 80,
                                      vPadding: 20,
                                      text:
                                          snapshot.data![index].name, // context
                                      //.watch<DictionaryAPi>()
                                      //.filteredDictionary[index]
                                      //.name,
                                      onPressed: () async {
                                        modelSheet(
                                            snapshot.data![index].videoUrl);
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

  Future modelSheet(String? url) {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        if (url != null) {
          return Container(
            height: 900,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  VideoPlayerScreen(videoUrl: url),
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
