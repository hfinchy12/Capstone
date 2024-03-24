import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_coach/src/analysis/API_caller.dart';
//import 'package:photo_coach/src/analysis/analysis_page.dart';
import 'package:camera/camera.dart';

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final String category;
  final CameraLensDirection lensDirection; // Add lens direction parameter

  const DisplayPictureScreen({Key? key, required this.imagePath, required this.category, required this.lensDirection}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Retake Photo')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: FutureBuilder<File>(
              future: getFile(imagePath),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading image: ${snapshot.error.toString()}'));
                } else if (snapshot.hasData) {
                  return Transform(
                    transform: lensDirection == CameraLensDirection.front
                        ? Matrix4.rotationY(math.pi)
                        : Matrix4.identity(), // Apply horizontal flip only for front-facing camera
                    alignment: FractionalOffset.center,
                    child: Image.file(snapshot.data!),
                  );
                } else {
                  return Center(child: Text('Image not found'));
                }
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _saveAndNavigate(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green, // Set the button background color to green
            ),
            child: Text(
              'Analyze Photo',
              style: TextStyle(color: Colors.white), // Set the text color to white
            ),
          ),
        ],
      ),
    );
  }

  Future<File> getFile(String imagePath) async {
    final file = File(imagePath);
    return file;
  }

  Future<void> _saveAndNavigate(BuildContext context) async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String newImagePath = '${appDocDir.path}/image.jpg';
      final File imageFile = File(imagePath);
      await imageFile.copy(newImagePath);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => APICaller(imagePath: newImagePath, category: category,)),
      );
    } catch (e) {
      print('Error saving image and navigating: $e');
    }
  }
}
