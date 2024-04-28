library category_page;

import 'package:flutter/material.dart';
import 'package:photo_coach/src/analysis/api_caller.dart';
import 'package:photo_coach/src/camera/camera.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage(
      {super.key, this.fromUpload = false, this.uploadImagePath = ""});

  final bool fromUpload;
  final String uploadImagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Category'),
      ),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          children: [
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16.0),
              mainAxisSpacing: 20.0,
              crossAxisSpacing: 20.0,
              children: [
                CategoryButton(
                    label: 'Selfie',
                    imageAsset: 'assets/images/selfie.png',
                    category: 'selfie',
                    fromUpload: fromUpload, // Pass the category parameter
                    uploadImagePath: uploadImagePath),
                CategoryButton(
                    label: 'Object Close-Up',
                    imageAsset: 'assets/images/object_closeup.png',
                    category: 'close-up', // Pass the category parameter
                    fromUpload: fromUpload,
                    uploadImagePath: uploadImagePath),
                CategoryButton(
                    label: 'Landscape',
                    imageAsset: 'assets/images/landscape.png',
                    category: 'landscapes', // Pass the category parameter
                    fromUpload: fromUpload,
                    uploadImagePath: uploadImagePath),
                CategoryButton(
                    label: 'General',
                    imageAsset: 'assets/images/general.png',
                    category: 'general', // Pass the category parameter
                    fromUpload: fromUpload,
                    uploadImagePath: uploadImagePath),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryButton extends StatelessWidget {
  final String label;
  final String imageAsset;
  final String category; // Add the category parameter
  final bool fromUpload;
  final String uploadImagePath;

  const CategoryButton(
      {super.key,
      required this.label,
      required this.imageAsset,
      required this.category, // Initialize the category parameter
      required this.fromUpload,
      required this.uploadImagePath});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return TextButton(
      key: Key(category),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            if (fromUpload) {
              return APICaller(imgPath: uploadImagePath, category: category);
            }
            return CameraPage(category: category);
          }, // Pass the category parameter
        ));
      },
      style: ButtonStyle(
        padding: MaterialStateProperty.all<EdgeInsets>(
          const EdgeInsets.all(16.0),
        ),
        backgroundColor: MaterialStateProperty.all<Color>(
          theme.cardColor,
        ),
        foregroundColor: MaterialStateProperty.all<Color>(
          theme.textTheme.labelLarge!.color!,
        ),
        shape: MaterialStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imageAsset,
            width: 120,
            height: 108,
          ),
          const SizedBox(height: 10),
          Text(label),
        ],
      ),
    );
  }
}
