import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_coach/src/analysis/analysis_page.dart';

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Display Picture')),
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
                  return Image.file(snapshot.data!);
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
            child: Text('Analyze'),
          ),
        ],
      ),
    );
  }

  Future<File> getFile(String imagePath) async {
    print('Image path: $imagePath'); // Print imagePath for debugging
    final file = File(imagePath);
    print('File exists: ${await file.exists()}'); // Check if file exists
    return file;
  }

  Future<void> _saveAndNavigate(BuildContext context) async {
    try {
      // Copy the image to a permanent location
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String newImagePath = '${appDocDir.path}/image.jpg';
      final File imageFile = File(imagePath);
      await imageFile.copy(newImagePath);

      // Navigate to the analysis page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AnalysisPage(imagePath: newImagePath)),
      );
    } catch (e) {
      print('Error saving image and navigating: $e');
    }
  }
}
