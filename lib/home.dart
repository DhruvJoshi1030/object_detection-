import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:object_detection/main.dart';
import 'package:tflite_v2/tflite_v2.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  void initState() {
    super.initState();
    loadcamera();
    loadmodel();
  }

  CameraImage? cameraimage;
  CameraController? cameracontroller;
  String output = '';
  loadmodel() async {
    try {
      String res;

      res = (await Tflite.loadModel(
          model:
              'assets/lite-model_object_detection_mobile_object_localizer_v1_1_metadata_2.tflite',
          labels: 'assets/labels.txt'))!;
      print("Models loading status: $res");
    } catch (e) {
      print("appp crashin becose: $e");
    }
  }

  loadcamera() async {
    try {
      cameracontroller = CameraController(cameras![0], ResolutionPreset.medium);
      await cameracontroller!.initialize().then((value) {
        if (!mounted) {
          return;
        } else {
          cameracontroller!.startImageStream((imageStream) {
            cameraimage = imageStream;
            print("camera loading status: sucess");
            runmodel();
          });
        }
      });
    } catch (e) {
      print("appp crashin becose of loadcamera: $e");
    }
  }

  runmodel() async {
    try {
      if (cameraimage != null) {
        var predictions = await Tflite.runModelOnFrame(
          bytesList: cameraimage!.planes.map((plane) => plane.bytes).toList(),
          imageHeight: cameraimage!.height,
          imageWidth: cameraimage!.width,
          imageMean: 127.5,
          imageStd: 127.5,
          rotation: 90,
          numResults: 1,
          threshold: 0.4,
          asynch: false,
        );
        if (predictions != null && predictions.isNotEmpty) {
          setState(() {
            output = predictions[0]['labels'];
          });
        }
      }
      print("model running status: sucess");
    } catch (e) {
      print("Error running model: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              output,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            // width: MediaQuery.of(context).size.width * 0.75,
            // child: (!cameracontroller!.value.isInitialized)
            //     ? Container(
            //         child: CameraPreview(cameracontroller!),
            //       )
            //     : AspectRatio(
            //         aspectRatio: cameracontroller!.value.aspectRatio,
            //         child: CameraPreview(cameracontroller!),
            //       ),
            // : AspectRatio(
            //     aspectRatio: cameracontroller!.value.aspectRatio,
            //     child: CameraPreview(cameracontroller!),
            //   ),
          ),
        ],
      ),
    );
  }
}
