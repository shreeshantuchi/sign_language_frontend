import 'dart:convert';
import 'dart:isolate';
import 'dart:io';
import 'package:sign_language_record_app/provider/signDetectState/sign_detect_state_Provider.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'package:provider/provider.dart';

import 'dart:typed_data';
import 'package:image/image.dart' as img;

class SignLanguageScreen extends StatefulWidget {
  final CameraDescription? camera;
  const SignLanguageScreen({super.key, this.camera});

  @override
  State<SignLanguageScreen> createState() => _SignLanguageScreenState();
}

class _SignLanguageScreenState extends State<SignLanguageScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late IOWebSocketChannel _channel;
  late Isolate _imageProcessingIsolate;
  late SendPort _imageProcessingSendPort;
  late ReceivePort _imageProcessingReceivePort;
  late Isolate _yuvIsolate;
  late SendPort _yuvSendPort;
  late ReceivePort _yuvReceivePort;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera!,
      ResolutionPreset.low,
    );
    _initializeControllerFuture = _controller.initialize();
    _channel = IOWebSocketChannel.connect("ws://10.0.2.2:8000/ws/stream/");
    // Initialize isolate and communication ports
    _initIsolates();
  }

  @override
  void dispose() {
    _controller.dispose();
    _channel.sink.close();
    _imageProcessingIsolate.kill(priority: Isolate.immediate);
    _yuvIsolate.kill(priority: Isolate.immediate);
    _imageProcessingReceivePort.close();
    _yuvReceivePort.close();
    super.dispose();
  }

  // Initialize the image processing isolate and communication ports
  void _initIsolates() async {
    _imageProcessingReceivePort = ReceivePort();
    _yuvReceivePort = ReceivePort();

    _imageProcessingIsolate = await Isolate.spawn(
      _imageProcessingEntryPoint,
      _imageProcessingReceivePort.sendPort,
    );
    _yuvIsolate = await Isolate.spawn(
      _convertYUVIsolateEntryPoint,
      _yuvReceivePort.sendPort,
    );

    _imageProcessingSendPort = await _imageProcessingReceivePort.first;
    _yuvSendPort = await _yuvReceivePort.first;
    context.read<SignProvider>().updateState(StreamState.initial);
  }
  // Send camera image to image processing isolate for conversion

  // Send bytes to server

  void _startStreaming() async {
    _channel = IOWebSocketChannel.connect("ws://10.0.2.2:8000/ws/stream/")
    print("connected");
    await _initializeControllerFuture;
    _controller.startImageStream((CameraImage image) {
      _sendCameraImageToIsolate(
          image, _imageProcessingSendPort, context, _channel);
      _sendYUVToIsolate(image, _yuvSendPort);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Live Video Streaming')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Consumer<IProvider>(builder: (context, ref, child) {
            //   if (ref.image != null) {
            //     return Column(
            //       children: [
            //         Text(ref.count.toString()),
            //         Image.memory(
            //           ref.image!,
            //           height: 300,
            //           width: 300,
            //         ),
            //       ],
            //     );
            //   } else {
            //     return Text("this is video");
            //   }
            // }),
            FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return RotatedBox(
                    child: CameraPreview(_controller),
                    quarterTurns: -1,
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),

            context.watch<SignProvider>().state == StreamState.initial ||
                    context.watch<SignProvider>().state == StreamState.start
                ? Consumer<SignProvider>(builder: (context, ref, child) {
                    if (ref.state == StreamState.initial) {
                      return ElevatedButton(
                        onPressed: () {
                          ref.updateState(StreamState.start);
                          _startStreaming();
                        },
                        child: Text("Start Stream"),
                      );
                    } else {
                      return ElevatedButton(
                        onPressed: () async {
                          ref.updateState(StreamState.initial);
                          await _channel.sink.close();
                        },
                        child: Text("Stop Stream"),
                      );
                    }
                  })
                : CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

void _sendVideoStream(
    Uint8List? data, BuildContext context, IOWebSocketChannel _channel) {
  if (data != null && context.read<SignProvider>().state == StreamState.start) {
    String new_data = base64Encode(data);
    _channel.sink.add(new_data);
    // context.read<IProvider>().updateImage(data);
  }
}

void _sendCameraImageToIsolate(
    CameraImage image,
    SendPort _imageProcessingSendPort,
    BuildContext context,
    IOWebSocketChannel _channel) async {
  final replyPort = ReceivePort();
  _imageProcessingSendPort
      .send(_ImageProcessingMessage(image, replyPort.sendPort));
  final Uint8List? bytes = await replyPort.first;
  if (bytes != null) {
    _sendVideoStream(Uint8List.fromList(bytes), context, _channel);
  }
  replyPort.close();
}

void _imageProcessingEntryPoint(SendPort sendPort) async {
  final receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);

  await for (dynamic message in receivePort) {
    if (message is _ImageProcessingMessage) {
      final Uint8List? bytes =
          await _convertCameraImageToBytes(message.cameraImage);
      message.replyPort.send(bytes);
    }
  }
}

void _sendYUVToIsolate(
  CameraImage image,
  SendPort _yuvSendPort,
) async {
  final replyPort = ReceivePort();
  _yuvSendPort.send(_YUVProcessingMessage(image, replyPort.sendPort));
  final img.Image? convertedImage = await replyPort.first;
  if (convertedImage != null) {
    // Do something with the converted image
  }
  replyPort.close();
}

void _convertYUVIsolateEntryPoint(SendPort sendPort) async {
  final receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);

  await for (dynamic message in receivePort) {
    if (message is _YUVProcessingMessage) {
      final img.Image convertedImage =
          convertYUV420ToImage(message.cameraImage);
      message.replyPort.send(convertedImage);
    }
  }
}

Future<Uint8List?> _convertCameraImageToBytes(CameraImage image) async {
  // Convert YUV420 to RGB

  img.Image imageData = convertYUV420ToImage(image);

  // Encode RGB image to JPEG
  Uint8List bytes = Uint8List.fromList(img.encodeJpg(imageData, quality: 60));
  return bytes;
}

img.Image convertYUV420ToImage(CameraImage cameraImage) {
  final imageWidth = cameraImage.width;
  final imageHeight = cameraImage.height;

  final yBuffer = cameraImage.planes[0].bytes;
  final uBuffer = cameraImage.planes[1].bytes;
  final vBuffer = cameraImage.planes[2].bytes;

  final int yRowStride = cameraImage.planes[0].bytesPerRow;
  final int yPixelStride = cameraImage.planes[0].bytesPerPixel!;

  final int uvRowStride = cameraImage.planes[1].bytesPerRow;
  final int uvPixelStride = cameraImage.planes[1].bytesPerPixel!;

  final image = img.Image(width: imageWidth, height: imageHeight);

  for (int h = 0; h < imageHeight; h++) {
    int uvh = (h / 2).floor();

    for (int w = 0; w < imageWidth; w++) {
      int uvw = (w / 2).floor();

      final yIndex = (h * yRowStride) + (w * yPixelStride);

      // Y plane should have positive values belonging to [0...255]
      final int y = yBuffer[yIndex];

      // U/V Values are subsampled i.e. each pixel in U/V chanel in a
      // YUV_420 image act as chroma value for 4 neighbouring pixels
      final int uvIndex = (uvh * uvRowStride) + (uvw * uvPixelStride);

      // U/V values ideally fall under [-0.5, 0.5] range. To fit them into
      // [0, 255] range they are scaled up and centered to 128.
      // Operation below brings U/V values to [-128, 127].
      final int u = uBuffer[uvIndex];
      final int v = vBuffer[uvIndex];

      // Compute RGB values per formula above.
      int r = (y + v * 1436 / 1024 - 179).round();
      int g = (y - u * 46549 / 131072 + 44 - v * 93604 / 131072 + 91).round();
      int b = (y + u * 1814 / 1024 - 227).round();

      r = r.clamp(0, 255);
      g = g.clamp(0, 255);
      b = b.clamp(0, 255);

      // Use 255 for alpha value, no transparency.
      image.setPixelRgb(w, h, r, g, b);
    }
  }

  return image;
}

class _ImageProcessingMessage {
  final CameraImage cameraImage;
  final SendPort replyPort;

  _ImageProcessingMessage(this.cameraImage, this.replyPort);
}

class _YUVProcessingMessage {
  final CameraImage cameraImage;
  final SendPort replyPort;

  _YUVProcessingMessage(this.cameraImage, this.replyPort);
}
