import 'package:flutter/material.dart';
import 'package:photo_coach/src/camera/camera.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Category'),
      ),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          children: [
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              padding: EdgeInsets.all(16.0),
              mainAxisSpacing: 20.0,
              crossAxisSpacing: 20.0,
              children: [
                CategoryButton(
                  label: 'Selfie',
                  imageAsset: 'assets/images/selfie.jpg',
                  category: 'selfie', // Pass the category parameter
                ),
                CategoryButton(
                  label: 'Food',
                  imageAsset: 'assets/images/food.png',
                  category: 'food', // Pass the category parameter
                ),
                CategoryButton(
                  label: 'Landscapes',
                  imageAsset: 'assets/images/landscape.jpg',
                  category: 'landscapes', // Pass the category parameter
                ),
                CategoryButton(
                  label: 'Objects',
                  imageAsset: 'assets/images/dog.png',
                  category: 'objects', // Pass the category parameter
                ),
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

  const CategoryButton({
    required this.label,
    required this.imageAsset,
    required this.category, // Initialize the category parameter
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CameraPage(category: category)), // Pass the category parameter
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imageAsset,
            width: 120,
            height: 120,
          ),
          SizedBox(height: 10),
          Text(label),
        ],
      ),
      style: ButtonStyle(
        padding: MaterialStateProperty.all<EdgeInsets>(
          EdgeInsets.all(16.0),
        ),
        backgroundColor: MaterialStateProperty.all<Color>(
          theme.cardColor,
        ),
        foregroundColor: MaterialStateProperty.all<Color>(
          theme.textTheme.button!.color!,
        ),
        shape: MaterialStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }
}
