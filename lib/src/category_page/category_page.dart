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
      body: SingleChildScrollView( // Wrap with SingleChildScrollView
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
                ),
                CategoryButton(
                  label: 'Food',
                  imageAsset: 'assets/images/food.png',
                ),
                CategoryButton(
                  label: 'Landscapes',
                  imageAsset: 'assets/images/landscape.jpg',
                ),
                CategoryButton(
                  label: 'Objects',
                  imageAsset: 'assets/images/dog.png',
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

  const CategoryButton({
    required this.label,
    required this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return TextButton(
      onPressed: () {
        if (label == 'Selfie') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CameraPage()),
          );
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imageAsset,
            width: 120, // Adjust the size according to your needs
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
          theme.cardColor, // Use cardColor or any other color property from the theme
        ),
        foregroundColor: MaterialStateProperty.all<Color>(
          theme.textTheme.button!.color!,
        ),
        shape: MaterialStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // Adjust border radius for square corners
          ),
        ),
      ),
    );
  }
}

