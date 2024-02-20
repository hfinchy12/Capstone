import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:photo_coach/src/camera/display_picture_screen.dart';
import 'package:path_provider/path_provider.dart';
class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late Future<CameraController> _controllerFuture;

  @override
  void initState() {
    super.initState();
    _controllerFuture = initializeCamera();
  }

  Future<CameraController> initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    // Initialize the camera
    final controller = CameraController(firstCamera, ResolutionPreset.max); //Uses best possible camera resolution
    await controller.initialize();
    return controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera'),
      ),
      body: FutureBuilder<CameraController>(
        future: _controllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final controller = snapshot.data!;
            return Center(
              child: controller.value.isInitialized
                  ? CameraPreview(controller)
                  : CircularProgressIndicator(),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final controller = await _controllerFuture;
          await takePicture(controller);
        },
        child: Icon(Icons.camera),
      ),
    );
  }

  Future<void> takePicture(CameraController controller) async {
    try {
      // ensure that the camera is initialized before attempting to take a picture
      if (!controller.value.isInitialized) {
        return;
      }

      // construct the path where the image will be saved using the path_provider package
      final Directory extDir = await getTemporaryDirectory();
      final String filePath = '${extDir.path}/image.jpg';

      // take the picture
      final XFile pictureFile = await controller.takePicture();

      if (pictureFile != null) {
        // Navigate to a new page to display the captured image
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DisplayPictureScreen(imagePath: pictureFile.path),
          ),
        );
      } else {
        print('Failed to take picture');
      }
    } catch (e) {
      print(e);
    }
  }
}