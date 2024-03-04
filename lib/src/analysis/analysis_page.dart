// import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnalysisPage extends StatelessWidget {
  final String imagePath;

  const AnalysisPage({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Results'),
      ),
      body: _MetricBar()
    );
  }
}

class _MetricBar extends StatefulWidget {
  @override
  MetricBarState createState() => MetricBarState();
}

class MetricBarState extends State<_MetricBar> {
  // Based on code from https://api.flutter.dev/flutter/widgets/ListView-class.html
  Widget _addMetrics() {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        const ListTile(
          title: Text('Metric A: Poor', textAlign: TextAlign.left),
        ),
        const Divider(),
        const ListTile(
          title: Text('Metric B: Fair', textAlign: TextAlign.left),
        ),
        const Divider(),
        const ListTile(
          title: Text('Metric C: Good', textAlign: TextAlign.left),
        ),
        const Divider(),
        Container(
            height: 100,
            color: Colors.grey[200],
            child: const Text("GPT-4 Feedback", textAlign: TextAlign.left)
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Image.asset(imagePath)
      body: _addMetrics()
    );
  }

}
