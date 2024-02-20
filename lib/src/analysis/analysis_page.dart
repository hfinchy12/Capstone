import 'package:flutter/material.dart';

class AnalysisPage extends StatelessWidget {
  final String imagePath;

  const AnalysisPage({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analysis Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Analysis Page'),
          ],
        ),
      ),
    );
  }
}
