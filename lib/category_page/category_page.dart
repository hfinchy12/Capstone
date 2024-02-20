import 'package:flutter/material.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ElevatedButton(
            child: const Text("Back"),
            onPressed: () {
              Navigator.pop(context);
            }));
  }
}
