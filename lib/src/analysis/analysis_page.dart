library analysis_page;

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:photo_coach/src/history.dart';
import 'dart:io';
import 'package:photo_coach/src/home_page/home_page.dart';

/// Converts a metric's raw numeric score into a verbal rating.
///
/// Poor = [0, 0.3)
/// Fair = [0.3, 0.6)
/// Good = [0.6, 0.8)
/// Excellent = [0.8, 1.0]
/// An invalid value returns "Error".
String getRating(double score) {
  if (score < 0.0 || score > 1.0) {
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

/// Converts a metric's raw numeric score into an associated color value ([0,1] -> [red,green])
/// to appropriately color the rating on the [MetricBar].
///
/// red = [0, 0.3)
/// yellow = [0.3, 0.6)
/// light green = [0.6, 0.8)
/// green = [0.8, 1.0]
/// An invalid value returns black.
Color getColor(double score) {
  if (score < 0.0 || score > 1.0) {
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
    return Colors
        .black; // Should not be possible, but removes the non-null return warning
  }
}

/// The AnalysisPage widget renders a page to display the contents of the [analysis] to the user.
class AnalysisPage extends StatelessWidget {
  /// The path on disk of the analyzed image.
  final String imgPath;

  /// The analysis data for the image
  final Map<String, dynamic> analysis;

  /// The index in the [History] on disk that the current result is stored.
  final int historyIndex;

  /// Constructs the [AnalysisPage] and sets the [imgPath], [analysis], and [historyIndex].
  const AnalysisPage(
      {super.key,
      required this.imgPath,
      required this.analysis,
      required this.historyIndex});

  /// [addMetrics] creates three [MetricBar]s for the CLIPiqa evaluation and a textbox for the GPT-4 feedback.
  ///
  /// This function is called by the [AnalysisPage.build] function to display the [MetricBar]s and GPT-4 feedback textbox in the UI.
  Widget addMetrics(Map<String, dynamic> analysis) {
    log(analysis.toString());
    return ListView(
        primary: false,
        shrinkWrap: true,
        padding: const EdgeInsets.all(4),
        children: <Widget>[
          MetricBar(
              title: "Overall Quality: ",
              rating: analysis["clip_result"]["quality"],
              explanation:
                  "Overall quality refers to the composition and clarity of the photo. It can be improved by using composition techniques like \"The Rule of Thirds\" (Placing the focus of your image on an intersection of the gridlines)"),
          MetricBar(
              title: "Brightness: ",
              rating: analysis["clip_result"]["brightness"],
              explanation:
                  "Brightness refers to the amount of light in the photo. An adequate brightness level ensures that objects in the photo can be seen clearly."),
          MetricBar(
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
                const Text(
                  "Feedback", //Feedback header
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    fontSize: 20, // Adjust the font size as needed
                  ),
                ),
                const SizedBox(
                    height:
                        8), // Adjust the spacing between "Feedback" and the GPT response
                RichText(
                  text: TextSpan(
                    text: analysis['gpt_result'],
                    style: const TextStyle(
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

  /// Deletes the current analysis results from the [History].
  ///
  /// Tapping the button first displays an [AlertDialog] so the user can confirm that they want to delete the evaluation.
  Widget deleteIconButton(BuildContext context) {
    return IconButton(
        key: const Key("delete_button"),
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
                          key: const Key("delete_confirmation_button"),
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

  /// Builds the widget to be displayed in the UI.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text('Analysis Results'),
            leading: IconButton(
              key: const Key("home_button"),
              icon: const Icon(Icons.home),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                    (Route<dynamic> route) => false);
              },
            ),
            actions: [deleteIconButton(context)]),
        body: Column(children: <Widget>[
          GestureDetector(
            key: const Key("image_preview"),
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
            addMetrics(analysis),
            const Divider(),
          ])))
        ]));
  }
}

/* MetricBar functionality adapted from ChatGPT's response to
* "How would I go about making a page with an image at the top and different
  expandable textboxes in rows below that image?"
* Generated 2/26/24 */

/// The [MetricBar] widget renders a widget that displays the [rating] and [explanation] of a single evaluation metric.
///
/// Future Consideration: It may no longer be necessary for [MetricBar] to extend [StatefulWidget], as opposed to [StatelessWidget].
/// The current extension is an artifact of trying to implement the [ExpansionTile]'s functionality before ExpansionTile was directly included.
class MetricBar extends StatefulWidget {
  /// Title of the metric.
  final String title;

  /// Rating for the metric.
  final double rating;

  /// Explanation of what the metric is.
  final String explanation;

  /// Constructs a [MetricBar] and sets the [title], [rating], and [explanation].
  const MetricBar(
      {super.key,
      required this.title,
      required this.rating,
      required this.explanation});

  @override
  State<MetricBar> createState() => _MetricBarState();
}

class _MetricBarState extends State<MetricBar> {
  @override
  void initState() {
    super.initState();
  }

  /// Builds the widget to be displayed in the UI.
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      key: Key(widget.title),
      // RichText structure adapted from https://stackoverflow.com/a/55778274
      title: RichText(
        text: TextSpan(
          text: widget.title,
          style: const TextStyle(color: Colors.black),
          children: <TextSpan>[
            TextSpan(
                text: getRating(widget.rating),
                style: TextStyle(color: getColor(widget.rating))),
          ],
        ),
      ),
      subtitle: SizedBox(
          height: 8.0,
          width: MediaQuery.of(context).size.width,
          child: LayoutBuilder(
            builder: (context, constraints) =>
                // Gradient bar & score marker
                Stack(children: [
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
                left: constraints.maxWidth *
                    widget.rating, // Position marker based on rating
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
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Score: '
                        '${(widget.rating * 100).toStringAsFixed(2)}%',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              widget.explanation,
            ),
          ],
        ),
      ],
    );
  }
}

/// The [ImagePage] widget renders a full-screen view of the image displayed on the [AnalysisPage] when the image is clicked on.
class ImagePage extends StatelessWidget {
  /// The path on disk of the image to display.
  final String imgPath;

  /// Constructs the [ImagePage] and sets the [imgPath].
  const ImagePage({super.key, required this.imgPath});

  /// Builds the widget to be displayed in the UI.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        key: const Key("big_preview"),
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
