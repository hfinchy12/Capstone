import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:photo_coach/src/history.dart';
import 'dart:io';
import 'package:photo_coach/src/home_page/home_page.dart';

String _getRating(double score) {
  if (score < 0.0 || score > 1.0){
    return 'Error';
  } else if (score < 0.3) {
    return 'Poor';
  } else if (score < 0.6) {
    return 'Fair';
  } else if (score < 0.8) {
    return 'Good';
  } else if (score <= 1.0) {
    return 'Excellent';
  } else {
    return 'Error';
  }
}

Color _getColor(double score) {
  if (score < 0.0 || score > 1.0){
    return Colors.black; // Error
  } else if (score < 0.3) {
    return Colors.red; // Poor
  } else if (score < 0.6) {
    return Colors.yellow; // Fair
  } else if (score < 0.8) {
    return Colors.green[300]!; // Good
  } else if (score <= 1.0) {
    return Colors.green; // Excellent
  } else {
    return Colors.black; // Should not be possible, but removes the non-null return warning
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
              title: "Overall Quality: ",
              rating: analysis["clip_result"]["quality"],
              explanation:
                  "Overall quality refers to the composition and clarity of the photo. It can be improved by using composition techniques like \"The Rule of Thirds\" (Placing the focus of your image on an intersection of the gridlines)"),
          _MetricBar(
              title: "Brightness: ",
              rating: analysis["clip_result"]["brightness"],
              explanation:
                  "Brightness refers to the amount of light in the photo. An adequate brightness level ensures that objects in the photo can be seen clearly."),
          _MetricBar(
              title: "Sharpness: ",
              rating: analysis["clip_result"]["sharpness"],
              explanation:
                  "Sharpness refers to how distinct and clear the objects in the photo are. Moving the camera while taking the photo blurs the image, which lowers the sharpness."),
          const Divider(),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Feedback", //Feedback header
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    fontSize: 20, // Adjust the font size as needed
                  ),
                ),
                SizedBox(height: 8), // Adjust the spacing between "Feedback" and the GPT response
                RichText(
                  text: TextSpan(
                    text: analysis['gpt_result'],
                    style: TextStyle(
                      color: Colors.black, // Set the text color to black
                    ),
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),

        ]);
  }

  Widget _deleteIconButton(BuildContext context) {
    return IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () async {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                      title: const Text("Delete Analysis"),
                      content: const Text(
                          "Would you like to delete this photo analysis result?"),
                      actions: [
                        TextButton(
                          child: const Text("Cancel",
                              style: TextStyle(color: Colors.blue)),
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
        });
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
            actions: [_deleteIconButton(context)]),
        body: Column(children: <Widget>[
          GestureDetector(
            child: SizedBox(
                height: 200,
                child: Card(
                    clipBehavior: Clip.none,
                    elevation: 0.0,
                    child: Image.file(File(imgPath)))),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ImagePage(imgPath: imgPath))),
          ),
          const Divider(),
          Expanded(
              child: SingleChildScrollView(
                  child: Column(children: [
            _addMetrics(analysis),
            const Divider(),
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
  final double rating;
  final String explanation;

  const _MetricBar(
      {required this.title, required this.rating, required this.explanation});

  @override
  State<_MetricBar> createState() => _MetricBarState();
}

class _MetricBarState extends State<_MetricBar> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      // RichText structure adapted from https://stackoverflow.com/a/55778274
      title: RichText(
        text: TextSpan(
          text: widget.title,
          style: const TextStyle(color: Colors.black),
          children: <TextSpan>[
            TextSpan(
                text: _getRating(widget.rating),
                style: TextStyle(color: _getColor(widget.rating))),
          ],
        ),
      ),
      subtitle: SizedBox(
          height: 8.0,
          width: MediaQuery.of(context).size.width,
          child: LayoutBuilder(
            builder: (context, constraints) =>
                Stack(// Gradient bar & score marker
                    children: [
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.red,
                          Colors.yellow,
                          Colors.green[300]!,
                          Colors.green
                        ],
                        stops: const [
                          0.0,
                          0.45,
                          0.7,
                          1.0
                        ])),
              ),
              Positioned(
                left: constraints.maxWidth * widget.rating, // Position marker based on rating
                child: Container(
                  width: 8, // Width of the marker
                  height: 8, // Height of the marker
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black, // Color of the marker
                  ),
                ),
              )
            ]),
          )),
      children: <Widget>[Text('Numeric Score: ${widget.rating}\n${widget.explanation}')],
    );
  }
}

class ImagePage extends StatelessWidget {
  final String imgPath;

  const ImagePage({super.key, required this.imgPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: Center(
          child: Hero(tag: 'imageHero', child: Image.file(File(imgPath))),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
