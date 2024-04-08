import 'dart:developer';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/material.dart';
//import 'package:photo_coach/src/analysis/API_caller.dart';
import 'package:photo_coach/src/history.dart';
import 'dart:io';
import 'package:photo_coach/src/home_page/home_page.dart';

String _getRating(double score) {
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

Color _getColor(String rating) {
    if (rating == "Poor") {
      return Colors.red; // Poor
    } else if (rating == "Fair") {
      return Colors.yellow; // Fair
    } else if (rating == "Good") {
      return Colors.green[300]!; // Good
    } else if (rating == "Excellent") {
      return Colors.green; // Excellent
    } else {
      return Colors.black; // Error
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
        padding: const EdgeInsets.all(4),
        children: <Widget>[
          _MetricBar(
              title: "Brightness: ",
              rating: _getRating(analysis["clip_result"]["brightness"]),
              explanation: "Brightness refers to the amount of light in the photo. An adequate brightness level ensures that objects in the photo can be seen clearly."),
          //const Divider(),
          _MetricBar(
              title: "Quality: ",
              rating: _getRating(analysis["clip_result"]["quality"]),
              explanation: "This refers to the overall quality of the photo and its composition."),
          //const Divider(),
          _MetricBar(
              title: "Sharpness: ",
              rating: _getRating(analysis["clip_result"]["sharpness"]),
              explanation: "Sharpness refers to how distinct and clear the objects in the photo are. Moving the camera while taking the photo blurs the image, which lowers the sharpness."),
          const Divider(),
          Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
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
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                          title: const Text("Delete Analysis"),
                          content: const Text(
                              "Would you like to delete this photo analysis result?"),
                          actions: [
                            TextButton(
                              child: const Text("Cancel"),
                              onPressed: () => Navigator.pop(context),
                            ),
                            TextButton(
                              child: const Text("Delete",
                                  style: TextStyle(color: Colors.red)),
                              onPressed: () async {
                                await History.remove(historyIndex);

                                if (!context.mounted) {
                                  return;
                                }

                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const HomePage()),
                                    (Route<dynamic> route) => false);
                              },
                            ),
                          ]));
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
  //bool _expanded = false;

  @override
  void initState() {
    super.initState();
    //_expanded = false;
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      // Adapted from https://stackoverflow.com/a/55778274
      title: RichText(
        text: TextSpan(
          text: widget.title,
          style: const TextStyle(color: Colors.black),
          children: <TextSpan>[
            TextSpan(
              text: widget.rating, 
              style: TextStyle(color: _getColor(widget.rating))
            ),
          ],
        ),
      ),
      subtitle: SizedBox(
        height: 8.0,
        width: MediaQuery.of(context).size.width,
        child: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Colors.red, Colors.yellow, Colors.green[300]!, Colors.green]
              )
            ),
          ),
          Positioned(
            left: (String rating){
              if (rating == "Poor") {
                return 0.0; // All the way left
              } else if (rating == "Fair") {
                return MediaQuery.of(context).size.width/4; // Partially left
              } else if (rating == "Good") {
                return MediaQuery.of(context).size.width/2; // Partially right
              } else if (rating == "Excellent") {
                return MediaQuery.of(context).size.width*0.755; // All the way right
              } else {
                return double.infinity; // Error
              }
            }(widget.rating), // Position marker based on rating
            child: Container(
              width: 8, // Width of the marker
              height: 8, // Height of the marker
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black, // Color of the marker
              ),
            ),
          )]
        ),
      ),
      children: <Widget>[
        Text(widget.explanation)
      ],
    );
    
    /* return GestureDetector(
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
                      ]))); */
  }
}
