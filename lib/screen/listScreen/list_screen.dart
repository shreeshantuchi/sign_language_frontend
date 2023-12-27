// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sign_language_record_app/Api/dictionary_api.dart';
import 'package:provider/provider.dart';
import 'package:sign_language_record_app/widget/app_button.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key, required this.fileList});
  final List<File> fileList;
  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  FutureBuilder(
                      future: context.read<DictionaryAPi>().getDectionary(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: AppButton(
                                    vPadding: 20,
                                    text: snapshot.data![index].name,
                                    onPressed: () async {
                                      context.read<DictionaryAPi>().uploadVideo(
                                          widget.fileList[0],
                                          snapshot.data![index].id.toString());
                                    }),
                              );
                            },
                            shrinkWrap: true,
                          );
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      })
                ],
              ),
            ),
          ),
        ),
        SwitchWidget(),
        Text(context.watch<DictionaryAPi>().state.toString()),
      ],
    );
  }
}

class SwitchWidget extends StatelessWidget {
  final String switchCase =
      'case1'; // Change this value based on your condition

  @override
  Widget build(BuildContext context) {
    switch (context.watch<DictionaryAPi>().state) {
      case 1:
        return SizedBox.shrink();
      case 2:
        return Scaffold(
          backgroundColor: Colors.grey.withOpacity(0.6),
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );

      default:
        return Container(
          color: Colors.red,
          alignment: Alignment.center,
          child: Text(
            'Default Widget',
            style: TextStyle(color: Colors.white),
          ),
        );
    }
  }
}
