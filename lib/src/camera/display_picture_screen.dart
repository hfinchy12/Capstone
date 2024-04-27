library display_picture_screen;

import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_coach/src/analysis/api_caller.dart';
import 'package:camera/camera.dart';
import 'package:uuid/uuid.dart';

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final String category;
  final CameraLensDirection lensDirection; // Add lens direction parameter

  const DisplayPictureScreen(
      {super.key,
      required this.imagePath,
      required this.category,
      required this.lensDirection});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Retake Photo')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: FutureBuilder<File>(
              future: getFile(imagePath),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text(
                          'Error loading image: ${snapshot.error.toString()}'));
                } else if (snapshot.hasData) {
                  return Transform(
                    transform: lensDirection == CameraLensDirection.front
                        ? Matrix4.rotationY(math.pi)
                        : Matrix4
                            .identity(), // Apply horizontal flip only for front-facing camera
                    alignment: FractionalOffset.center,
                    child: Image.file(snapshot.data!),
                  );
                } else {
                  return const Center(child: Text('Image not found'));
                }
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _saveAndNavigate(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  Colors.green, // Set the button background color to green
            ),
            child: const Text(
              'Analyze Photo',
              style:
                  TextStyle(color: Colors.white), // Set the text color to white
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
      final String newImagePath = "${appDocDir.path}/${const Uuid().v1()}.jpg";
      File imgFile = File(imagePath);
      await imgFile.copy(newImagePath);
      imgFile.delete();

      if (!context.mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => APICaller(
                  imgPath: newImagePath,
                  category: category,
                )),
      );
    } catch (e) {
      log('Error saving image and navigating: $e');
    }
  }
}
