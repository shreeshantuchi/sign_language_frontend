import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sign_language_record_app/modle/dictionary_modle.dart';

enum DictionaryState { initial, fetch, done }

enum UploadVideoState { initial, upload, done }

class DictionaryAPi with ChangeNotifier {
  DictionaryState dictionaryState = DictionaryState.initial;
  UploadVideoState uploadVideoState = UploadVideoState.initial;
  List<DisctionaryModel> filteredDictionary = [];
  List<DisctionaryModel> dictionary = [];

  Future<List<DisctionaryModel>> getDectionary() async {
    dictionary = [];
    final response =
        await http.get(Uri.parse('http://10.0.2.2:8000/dictionary/video'));
    //print("object2");

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      List<dynamic> data = json.decode(response.body);
      // print(data);
      for (var element in data) {
        print(element["name"]);
        dictionary.add(
          DisctionaryModel(
              name: element["name"],
              id: element["id"],
              videoUrl: element["best_video_link"]),
        );
      }
      filteredDictionary = dictionary;

      return dictionary;
    } else {
      // If the server did not return a 200 OK response,
      // throw an exception.
      throw Exception('Failed to load data');
    }
  }

  void updateUploadVideoState(UploadVideoState state) {
    uploadVideoState = state;
    notifyListeners();
  }

  void filterSearch(String text) {
    if (text.isEmpty) {
      filteredDictionary = dictionary;
    } else {
      filteredDictionary = dictionary
          .where((element) =>
              element.name.toLowerCase().contains(text.toLowerCase()))
          .toList();
      // print(filteredDictionary);
    }
    notifyListeners();
  }

  Future<void> uploadVideo(File file, String id) async {
    updateUploadVideoState(UploadVideoState.upload);
    var url = Uri.parse('http://10.0.2.2:8000/sign/upload/');

    var request = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath('video_file', file.path))
      ..fields['dictionary_name'] = id;

    try {
      var response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 201) {
        updateUploadVideoState(UploadVideoState.done);
        // print('File uploaded successfully');
      } else {
        //print('Failed to upload file. Status code: ${response!.statusCode}');
      }
    } catch (e) {
      // print('Error uploading file: $e');
    }
    notifyListeners();
  }

  bool isVideoFile(File file) {
    // Define a list of video file extensions
    List<String> videoExtensions = ['mp4', 'mkv', 'avi', 'mov', 'wmv'];

    // Get the file extension
    String extension = file.path.split('.').last.toLowerCase();

    // Check if the extension is in the list of video extensions
    return videoExtensions.contains(extension);
  }
}
