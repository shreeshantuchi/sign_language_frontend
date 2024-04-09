// ignore_for_file: use_build_context_synchronously

import 'dart:async';
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
    _initializeCameraController();
  }

  Future<void> _initializeCameraController() async {
    _controller = CameraController(
      widget.camera!,
      ResolutionPreset.low,
    );

    _channel = IOWebSocketChannel.connect("ws://10.0.2.2:8000/ws/stream/");
    // Initialize isolate and communication ports
    _initIsolates();
  }

  @override
  void dispose() async {
    super.dispose();
    await _channel.sink.close();
    _imageProcessingIsolate.kill(priority: Isolate.immediate);
    _yuvIsolate.kill(priority: Isolate.immediate);
    _imageProcessingReceivePort.close();
    _yuvReceivePort.close();
    await _controller.dispose();
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
    await _controller.initialize();
    context.read<SignProvider>().updateState(StreamState.start);
    _startStreaming();
    await Future.delayed(const Duration(seconds: 3));
    await _stopStreaming();
    _startStreaming();
    await Future.delayed(const Duration(seconds: 3));
    _stopStreaming();
    context.read<SignProvider>().updateState(StreamState.initial);
    context.read<SignProvider>().updateCameraState(CameraControllerState.start);
  }
  // Send camera image to image processing isolate for conversion

  // Send bytes to server

  Future<void> _startStreaming() async {
    print("streaming start");
    if (!_controller.value.isInitialized) {
      print("not initialized");
      return;
    }
    print("a");
    await _controller.startImageStream((CameraImage image) {
      if (!mounted) {
        print("unmounted");
        return;
      }
      print("image streaming started");
      _sendCameraImageToIsolate(
          image, _imageProcessingSendPort, context, _channel);
      _sendYUVToIsolate(image, _yuvSendPort);
    });
  }

  Future<void> _stopStreaming() async {
    if (_controller.value.isStreamingImages) {
      await _controller.stopImageStream();

      // Clear the message queues of the isolates
      _imageProcessingReceivePort.close();
      _imageProcessingReceivePort = ReceivePort();
      _yuvReceivePort.close();
      _yuvReceivePort = ReceivePort();
      print("stopped image stream");

      // Wait for the isolates to clear their message queues
      //await Future.delayed(Duration(milliseconds: 50));
    }
    if (_controller.value.isStreamingImages) {
      await _controller.stopImageStream();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.pinkAccent,
          titleTextStyle: const TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
          title: const Text('Sign -> Text'),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20), // Adjust the radius as needed
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Consumer<SignProvider>(builder: (context, ref, child) {
                if (ref.cameraState == CameraControllerState.start) {
                  return RotatedBox(
                    quarterTurns: 3,
                    child: CameraPreview(_controller),
                  );
                } else {
                  return Container(
                    height: 500,
                    width: 400,
                    color: Colors.grey,
                  );
                  //
                }
              }),

              context.watch<SignProvider>().state == StreamState.initial ||
                      context.watch<SignProvider>().state == StreamState.start
                  ? Consumer<SignProvider>(builder: (context, ref, child) {
                      if (ref.state == StreamState.initial) {
                        return ElevatedButton(
                          onPressed: () async {
                            await _stopStreaming();
                            await _stopStreaming();
                            await _startStreaming();
                            ref.updateState(StreamState.start);
                          },
                          child: const Text("Start Stream"),
                        );
                      } else {
                        return ElevatedButton(
                          onPressed: () async {
                            await _stopStreaming();
                            ref.updateState(StreamState.initial);
                          },
                          child: const Text("Stop Stream"),
                        );
                      }
                    })
                  : const SizedBox.shrink(),
              const SizedBox(
                height: 40,
              ),
              StreamBuilder(
                  stream: _channel.stream,
                  builder: (context, snapshot) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.black, // Border color
                          width: 2.0, // Border width
                        ),
                      ),
                      height: 100,
                      width: 400,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          snapshot.hasData
                              ? snapshot.data.toString()
                              : "Reverse SIgn Text",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  }),
              // Consumer<SignProvider>(builder: (context, ref, child) {
              //   if (ref.iamge != null) {
              //     return Image.memory(ref.iamge!);
              //   } else {
              //     return CircularProgressIndicator();
              //   }
              // }),
            ],
          ),
        ),
      ),
    );
  }

  void resetstream() async {
    await _startStreaming();
    context.read<SignProvider>().updateState(StreamState.start);
    print("here");
    await Future.delayed(const Duration(seconds: 1));
    await _stopStreaming();
    context.read<SignProvider>().updateState(StreamState.initial);
    print("there");
  }
}

void _sendVideoStream(
    Uint8List? data, BuildContext context, IOWebSocketChannel channel) {
  print("data :" + data.toString());
  if (data != null && context.read<SignProvider>().state == StreamState.start) {
    String newData = base64Encode(data);
    channel.sink.add(newData);

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

  if (bytes != null &&
      context.read<SignProvider>().state == StreamState.start) {
    //context.read<SignProvider>().updateImage(bytes);
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

class _MediaSizeClipper extends CustomClipper<Rect> {
  final Size mediaSize;
  const _MediaSizeClipper(this.mediaSize);
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, mediaSize.width, mediaSize.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}
