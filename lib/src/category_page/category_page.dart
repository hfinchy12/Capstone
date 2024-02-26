import 'package:flutter/material.dart';
import 'package:photo_coach/src/analysis/analysis_page.dart';
import 'package:photo_coach/src/camera/camera.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage(
      {Key? key, this.fromUpload = false, this.uploadImagePath = ""})
      : super(key: key);

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
                    imageAsset: 'assets/images/selfie.jpg',
                    category: 'selfie',
                    fromUpload: fromUpload, // Pass the category parameter
                    uploadImagePath: uploadImagePath),
                CategoryButton(
                    label: 'Food',
                    imageAsset: 'assets/images/food.png',
                    category: 'food', // Pass the category parameter
                    fromUpload: fromUpload,
                    uploadImagePath: uploadImagePath),
                CategoryButton(
                    label: 'Landscapes',
                    imageAsset: 'assets/images/landscape.jpg',
                    category: 'landscapes', // Pass the category parameter
                    fromUpload: fromUpload,
                    uploadImagePath: uploadImagePath),
                CategoryButton(
                    label: 'Objects',
                    imageAsset: 'assets/images/dog.png',
                    category: 'objects', // Pass the category parameter
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
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            if (fromUpload) {
              return AnalysisPage(imagePath: uploadImagePath);
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
            height: 120,
          ),
          const SizedBox(height: 10),
          Text(label),
        ],
      ),
    );
  }
}
