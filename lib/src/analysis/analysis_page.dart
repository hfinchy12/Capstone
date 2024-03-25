import 'package:flutter/material.dart';
import 'dart:io';

String getRating(double score) {
  if (score < 0.3) {
    return 'Poor';
  } else if (score < 0.6) {
    return 'Fair';
  } else if (score < 0.8) {
    return 'Good';
  } else {
    return 'Excellent';
  }
}

class AnalysisPage extends StatelessWidget {
  final String imgPath;
  final Map<String, dynamic> analysis;

  const AnalysisPage(
      {super.key, required this.imgPath, required this.analysis});

  Widget _addMetrics(Map<String, dynamic> analysis) {
    print(analysis);
    return Expanded(
        child: ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        _MetricBar(
            title: "Brightness: ",
            rating: analysis["clip_result"]["brightness"].toString(),
            explanation: "How bright the pic is"),
        const Divider(),
        _MetricBar(
            title: "Quality: ",
            rating: analysis["clip_result"]["quality"].toString(),
            explanation: "How good the pic is"),
        const Divider(),
        _MetricBar(
            title: "Sharpness: ",
            rating: analysis["clip_result"]["sharpness"].toString(),
            explanation: "How sharp the pic is"),
        const Divider(),
        Expanded(
            child: Container(
                color: Colors.grey[200],
                child: Text(
                    analysis['gpt_result']['choices'][0]['message']['content'],
                    textAlign: TextAlign.left)))
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Analysis Results'),
        ),
        body: Column(children: <Widget>[
          SizedBox(
              height: 200,
              child: Card(
                  clipBehavior: Clip.none,
                  elevation: 0.0,
                  child: Image.file(File(imgPath)))),
          const Divider(),
          _addMetrics(analysis)
        ]));
  }
}

/* MetricBar functionality adapted from ChatGPT's response to
* "How would I go about making a page with an image at the top and different
  expandable textboxes in rows below that image?"
* Generated 2/26/24 */
class _MetricBar extends StatefulWidget {
  final String title;
  final String rating;
  final String explanation;

  const _MetricBar(
      {required this.title, required this.rating, required this.explanation});

  @override
  State<_MetricBar> createState() => _MetricBarState();
}

class _MetricBarState extends State<_MetricBar> {
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _expanded = false;
  }

  @override
  void initState() {
    super.initState();
    _expanded = false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          setState(() {
            _expanded = !_expanded;
          });
        },
        child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
            ),
            child: _expanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text(widget.title + widget.rating,
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            )),
                        Text(widget.explanation,
                            style: const TextStyle(fontSize: 16.0))
                      ])
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text(widget.title + widget.rating,
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            )),
                      ])));
  }
}
