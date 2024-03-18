// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:isolate';
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

  Future<void> _startStreaming() async {
    await _initializeControllerFuture;
    // Check if the widget is still mounted before starting the image stream
    if (!mounted) return;
    _controller.startImageStream((CameraImage image) {
      // Check if the widget is still mounted before processing the image
      if (!mounted) {
        _controller
            .stopImageStream(); // Stop the image stream if the widget is unmounted
        return;
      }

      _sendCameraImageToIsolate(
          image, _imageProcessingSendPort, context, _channel);
      _sendYUVToIsolate(image, _yuvSendPort);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Video Streaming')),
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
                    quarterTurns: -1,
                    child: CameraPreview(_controller),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),

            context.watch<SignProvider>().state == StreamState.initial ||
                    context.watch<SignProvider>().state == StreamState.start
                ? Consumer<SignProvider>(builder: (context, ref, child) {
                    if (ref.state == StreamState.initial) {
                      return ElevatedButton(
                        onPressed: () async {
                          await _startStreaming();
                          ref.updateState(StreamState.start);
                        },
                        child: const Text("Start Stream"),
                      );
                    } else {
                      return ElevatedButton(
                        onPressed: () async {
                          await _controller.stopImageStream();
                          ref.updateState(StreamState.initial);
                        },
                        child: const Text("Stop Stream"),
                      );
                    }
                  })
                : const CircularProgressIndicator(),
            StreamBuilder(
                stream: _channel.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      snapshot.data.toString(),
                      style: const TextStyle(fontSize: 24),
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                }),
            Consumer<SignProvider>(builder: (context, ref, child) {
              if (ref.iamge != null) {
                return Image.memory(ref.iamge!);
              } else {
                return CircularProgressIndicator();
              }
            }),
          ],
        ),
      ),
    );
  }
}

void _sendVideoStream(
    Uint8List? data, BuildContext context, IOWebSocketChannel channel) {
  if (data != null && context.read<SignProvider>().state == StreamState.start) {
    String newData = base64Encode(data);
    // channel.sink.add(newData);
    // context.read<IProvider>().updateImage(data);
  }
}

void _sendCameraImageToIsolate(
    CameraImage image,
    SendPort imageProcessingSendPort,
    BuildContext context,
    IOWebSocketChannel channel) async {
  final replyPort = ReceivePort();
  imageProcessingSendPort
      .send(_ImageProcessingMessage(image, replyPort.sendPort));
  final Uint8List? bytes = await replyPort.first;
  context.read<SignProvider>().updateImage(bytes);
  if (bytes != null) {
    _sendVideoStream(Uint8List.fromList(bytes), context, channel);
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
  SendPort yuvSendPort,
) async {
  final replyPort = ReceivePort();
  yuvSendPort.send(_YUVProcessingMessage(image, replyPort.sendPort));
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
