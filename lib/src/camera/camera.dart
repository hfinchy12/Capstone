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
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _showPopup();
    });
  }


  Future<CameraController> initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    final controller = CameraController(
      cameras[1], // camera![1] means front camera
      ResolutionPreset.max,
    );
    await controller.initialize();
    return controller;
  }

  Future<void> _showPopup() async {
    final PageController _pageController = PageController();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Selfie Tips"),
            content: SingleChildScrollView(
              child: SizedBox(
                height: 350, // Set a fixed height for the content area
                width: MediaQuery.of(context).size.width * 2, // Set width to accommodate two pages
                child: Column(
                  children: [
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Good Lighting: Natural light is often the most flattering. Avoid harsh overhead lighting or direct sunlight.\n\n"
                                      "Angle: Typically, holding the camera slightly above eye level and angling your face slightly can help accentuate your features.\n\n"
                                      "Expression: Smile naturally or convey the mood you want to express in the selfie.\n\n"
                                      "Framing: Center yourself in the frame or use the rule of thirds to create a visually pleasing composition.",
                                ),
                                // Add content for the first page here
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Close"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera'),
        actions: [
          TextButton(
            onPressed: _showPopup,
            child: Text('Tips', style: TextStyle(color: Colors.black)),
          ),
        ],
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
      floatingActionButton: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              width: 70,
              height: 70,
              child: FloatingActionButton(
                onPressed: () async {
                  final controller = await _controllerFuture;
                  await takePicture(controller);
                },
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.photo_camera,
                  size: 35,
                ),
                shape: CircleBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Future<void> takePicture(CameraController controller) async {
    try {
      if (!controller.value.isInitialized) {
        return;
      }
      final Directory extDir = await getTemporaryDirectory();
      final String filePath = '${extDir.path}/image.jpg';
      final XFile pictureFile = await controller.takePicture();
      if (pictureFile != null) {
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
