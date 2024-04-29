library api_caller;

import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:photo_coach/src/analysis/analysis_page.dart';
import 'package:photo_coach/src/history.dart';

/// Sends the image stored at [imgPath] and the image [category] to the backend server, waits for, then handles the response.
///
/// While awaiting the response from the backend, the widget displays a loading wheel and a sequence of tips.
/// Once the backend responds, the APICaller constructs an [AnalysisPage] with the response.
class APICaller extends StatefulWidget {
  /// The path on disk of the image.
  final String imgPath;

  /// The category of the image.
  final String category;

  /// Constructs the [APICaller] and sets the [imgPath] and [category].
  const APICaller({super.key, required this.imgPath, required this.category});

  @override
  State<APICaller> createState() => APICallerState();
}

/// Contains the functionality for the [APICaller] class.
class APICallerState extends State<APICaller> {
  /// The analysis response returned by the backend.
  late Future<Map<String, dynamic>> responseFuture;

  /// Controller for the sequence of tips.
  late StreamController<String> tipsController;

  /// The sequence of tips.
  late List<String> tips;

  /// The index of the current tip displayed.
  late int currentTipIndex;

  /// The opacity of the tips text.
  double opacity = 0.70;

  /// Whether a different page has been navigated to.
  bool hasNavigated = false;

  /// The URL endpoint for the backend.
  static const String url =
      "http://photocoachcapstone.pythonanywhere.com/fullasyncanalysis";

  /// The default response when the backend cannot be reached.
  static const Map<String, dynamic> errorResponse = {
    "clip_result": {"brightness": -1.0, "quality": -1.0, "sharpness": -1.0},
    "gpt_result":
        "There was an error connecting to the evaluation service. Please ensure you are connected to the internet and reupload the photo."
  };

  /// Packages the photo at [imgPath] into a POST request to the backend, sends the request, handles the response,
  /// adds the photo to the [History], and returns the analysis response as a [Map]
  Future<Map<String, dynamic>> _sendPicture(
      String imgPath, String category) async {
    Map<String, dynamic> analysis;

    try {
      FormData formData = FormData.fromMap({
        "picture": await MultipartFile.fromFile(imgPath),
        "category": category,
        "comp_level": 4
      });
      BaseOptions options =
          BaseOptions(connectTimeout: const Duration(seconds: 5));
      final response = await Dio(options).post(url, data: formData);

      developer.log("${response.statusCode} ${response.statusMessage ?? ""}");
      analysis = response.statusCode == 200 ? response.data : errorResponse;
    } catch (e) {
      developer.log(e.toString());
      analysis = errorResponse;
    }

    final HistoryEntry historyEntry = HistoryEntry(
        imgPath, analysis, getColor(analysis["clip_result"]["quality"]));
    History.append(historyEntry);

    return analysis;
  }

  /// Sets the default state of the widget.
  ///
  /// Creates and starts the sequence of tips.
  @override
  void initState() {
    super.initState();
    responseFuture = _sendPicture(widget.imgPath, widget.category);

    tips = [
      "Tip: Use both hands to stabilize your phone.",
      "Tip: Utilize tap-to-focus to put emphasis on objects.",
      "Tip: Try to limit zoom usage to preserve image quality.",
      "Tip: Use natural lighting to elevate your photos.",
      "Tip: Use the leveler and grid to get the best orientation and framing.",
      "Tip: Avoid relying on camera flash for lighting when possible."
    ];
    currentTipIndex = Random().nextInt(tips.length);
    tipsController = StreamController<String>();
    tipsController.add(tips[currentTipIndex]);

    // Fade out after 4 seconds
    Timer(const Duration(seconds: 4), () {
      if (!mounted) {
        return;
      }
      setState(() {
        opacity = 0.0;
      });
    });

    Timer.periodic(const Duration(seconds: 5), (_) {
      currentTipIndex = (currentTipIndex + 1) % tips.length;
      tipsController.add(tips[currentTipIndex]);
      if (!mounted) {
        return;
      }
      // Fade in
      setState(() {
        opacity = 0.70;
      });

      // Fade out after 4 seconds
      Timer(const Duration(seconds: 4), () {
        if (!mounted) {
          return;
        }
        setState(() {
          opacity = 0.0;
        });
      });
    });
  }

  /// Builds the widget to be displayed in the UI.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder(
              future: responseFuture,
              builder: (BuildContext context,
                  AsyncSnapshot<Map<String, dynamic>> snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    !hasNavigated) {
                  hasNavigated = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AnalysisPage(
                          imgPath: widget.imgPath,
                          analysis: snapshot.data!,
                          historyIndex: 0,
                        ),
                      ),
                    ).then((_) {
                      // Reset hasNavigated when user navigates back from AnalysisPage
                      hasNavigated = false;
                    });
                  });
                }
                return const CircularProgressIndicator();
              },
            ),
            const SizedBox(height: 20),
            StreamBuilder<String>(
              stream: tipsController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: opacity,
                    curve: Curves.easeInOut,
                    child: Text(
                      snapshot.data!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  return Container(); // Or any placeholder for when there's no data
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
