library api_caller;
import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:photo_coach/src/analysis/analysis_page.dart';
import 'package:photo_coach/src/history.dart';

/// Sends the photo at [imgPath] to the backend along with [category] and waits for and handles the response
/// 
/// While awaiting the response from the backend, the APICaller displays a loading wheel and a sequence of tips.
/// Once the backend responds, the APICaller constructs an [AnalysisPage] with the response. If the backend returns an error
/// or the connection fails, [defaultResponse] or [errorResponse] are passed to the AnalysisPage instead.
class APICaller extends StatefulWidget {
  final String imgPath;
  final String category;

  const APICaller({super.key, required this.imgPath, required this.category});

  @override
  State<APICaller> createState() => _CallerState();
}

class _CallerState extends State<APICaller> {
  late Future<Map<String, dynamic>> responseFuture;
  late StreamController<String> tipsController;
  late List<String> tips;
  late int currentTipIndex;
  double opacity = 0.70;
  bool hasNavigated = false;

  static const String url = "http://photocoachcapstone.pythonanywhere.com/fullasyncanalysis";
  
  // Gives a proper response to the AnalysisPage when the backend isn't reached
  static const Map<String, dynamic> defaultResponse = {
    "clip_result": {
      "brightness": 0.7804979681968689,
      "quality": 0.22963981330394745,
      "sharpness": 0.8442980051040649
    },
    "gpt_result":
        "Brightness: Good\nClarity: Fair\nSubject Focus: Poor\n\nAdvice to improve this photo:\n- Orientation: Rotate the camera to properly frame the subject.\n- Composition: Decide on a clear subject and compose the shot to emphasize it.\n- Stability: Keep the camera steady to avoid blur.\n- Cleanliness: Make sure the environment is tidy and free from distractions if that is part of the intended subject.\n- Perspective: Choose an angle that adds interest or importance to the subject."
  };

  // Gives an invalid response to the AnalysisPage, letting the user know the backend wasn't reached
  static const Map<String, dynamic> errorResponse = {
    "clip_result": {
      "brightness": -1.0,
      "quality": -1.0,
      "sharpness": -1.0
    },
    "gpt_result":
        "There was an error connecting to the evaluation service. Please ensure you are connected to the internet and reupload the photo."
  };

  /// Converts a metric's raw numeric score into an associated color value ([0,1] -> [red,green])
  /// to appropriately color the dot on the [HomePage]'s [History].
  /// 
  /// red = [0, 0.3) 
  /// yellow = [0.3, 0.6)
  /// light green = [0.6, 0.8)
  /// green = [0.8, 1.0]
  /// An invalid value returns black.
  Color getColor(double score) {
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

  /// Packages the photo at [imgPath] into a POST request to the backend, sends the request, handles the response,
  /// adds the photo to the [History], and returns the [analysis] response as a [Map]
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

    final HistoryEntry historyEntry = HistoryEntry(imgPath, analysis, getColor(analysis["clip_result"]["quality"]));
    History.append(historyEntry);

    return analysis;
  }

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
                  WidgetsBinding.instance!.addPostFrameCallback((_) {
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
