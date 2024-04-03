import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:photo_coach/src/history.dart';
import 'dart:io';
import 'package:photo_coach/src/home_page/home_page.dart';

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
  final int historyIndex;

  const AnalysisPage(
      {super.key,
      required this.imgPath,
      required this.analysis,
      required this.historyIndex});

  Widget _addMetrics(Map<String, dynamic> analysis) {
    log(analysis.toString());
    return ListView(
        primary: false,
        shrinkWrap: true,
        padding: const EdgeInsets.all(8),
        children: <Widget>[
          _MetricBar(
              title: "Brightness: ",
              rating: getRating(analysis["clip_result"]["brightness"]),
              explanation: "How bright the pic is"),
          const Divider(),
          _MetricBar(
              title: "Quality: ",
              rating: getRating(analysis["clip_result"]["quality"]),
              explanation: "How good the pic is"),
          const Divider(),
          _MetricBar(
              title: "Sharpness: ",
              rating: getRating(analysis["clip_result"]["sharpness"]),
              explanation: "How sharp the pic is"),
          const Divider(),
          Container(
              color: Colors.grey[200],
              child: Text(analysis['gpt_result'], textAlign: TextAlign.left))
        ]);
  }

  Widget _deleteButton(BuildContext context) {
    return Container(
        width: 250.0,
        height: 50.0,
        margin: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 5.0),
        child: ElevatedButton.icon(
            icon: Image.asset("assets/images/delete_ico.png"),
            label: const Text("Delete",
                style: TextStyle(fontSize: 24.0, color: Colors.white)),
            style: IconButton.styleFrom(
              shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              await History.remove(historyIndex);

              if (!context.mounted) {
                return;
              }

              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (Route<dynamic> route) => false);
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Analysis Results'),
          leading: IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (Route<dynamic> route) => false);
            },
          ),
        ),
        body: Column(children: <Widget>[
          SizedBox(
              height: 200,
              child: Card(
                  clipBehavior: Clip.none,
                  elevation: 0.0,
                  child: Image.file(File(imgPath)))),
          const Divider(),
          Expanded(
              child: SingleChildScrollView(
                  child: Column(children: [
            _addMetrics(analysis),
            const Divider(),
            _deleteButton(context)
          ])))
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
