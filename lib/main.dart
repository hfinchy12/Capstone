import 'package:flutter/material.dart';
import 'package:photo_coach/src/backend/api_service.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'src/backend/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() async {
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Backend Test App'),
        ),
        body: Center(
          child: ImageUploadWidget(),
        ),
      ),
    );
  }
}

class TestBackendButton extends StatefulWidget {
  @override
  _TestBackendButtonState createState() => _TestBackendButtonState();
}

class _TestBackendButtonState extends State<TestBackendButton> {
  String _response = "No data fetched yet.";
  final ApiService _apiService = ApiService();

  void _fetchData() async {
    try {
      final String data = await _apiService.fetchData();
      setState(() {
        _response = data;
      });
    } catch (e) {
      setState(() {
        _response = "Failed to fetch data. Error: $e";
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
          onPressed: _fetchData, // Use _fetchData which wraps the call to ApiService.fetchData
          child: Text('Fetch Data from Backend'),
        ),
        SizedBox(height: 20), // Add some spacing between the button and response text
        Text(_response), // Display the fetched data or error message
      ],
    );
  }
}

class ImageUploadWidget extends StatefulWidget {
  @override
  _ImageUploadWidgetState createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = ApiService();
  XFile? _image;

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = pickedFile;
    });
  }

  // This function is called when the "Upload Image" button is pressed
  void _tryUploadImage() {
    if (_image != null) {
      _apiService.uploadImage(_image!.path).then((_) {
        // Handle success or failure
      }).catchError((error) {
        // Handle error
      });
    } else {
      // Handle case when no image is selected
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _pickImage,
          child: Text('Pick Image'),
        ),
        if (_image != null) Image.file(File(_image!.path)),
        // Add a button here to call a function to upload the image
        ElevatedButton(
          onPressed: _tryUploadImage, // This button triggers image upload
          child: Text('Upload Image'),
        ),
      ],
    );
  }
}