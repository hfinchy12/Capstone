import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:photo_coach/src/analysis/analysis_page.dart';
import 'package:photo_coach/src/history.dart';

class APICaller extends StatefulWidget {
  final String imgPath;
  final String category;

  const APICaller({Key? key, required this.imgPath, required this.category})
      : super(key: key);

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

  static const String url =
      "http://photocoachcapstone.pythonanywhere.com/fullasyncanalysis";
  static const Map<String, dynamic> defaultResponse = {
    "clip_result": {
      "brightness": 0.7804979681968689,
      "quality": 0.22963981330394745,
      "sharpness": 0.8442980051040649
    },
    "gpt_result":
        "Brightness: Good\nClarity: Fair\nSubject Focus: Poor\n\nAdvice to improve this photo:\n- Orientation: Rotate the camera to properly frame the subject.\n- Composition: Decide on a clear subject and compose the shot to emphasize it.\n- Stability: Keep the camera steady to avoid blur.\n- Cleanliness: Make sure the environment is tidy and free from distractions if that is part of the intended subject.\n- Perspective: Choose an angle that adds interest or importance to the subject."
  };

  Color getColor(double score) {
    if (score < 0.3) {
      return Colors.red; // Poor
    } else if (score < 0.6) {
      return Colors.yellow; // Fair
    } else if (score < 0.8) {
      return Colors.green[300]!; // Good
    } else {
      return Colors.green; // Excellent
    }
  }

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

      log("${response.statusCode} ${response.statusMessage ?? ""}");
      analysis = response.statusCode == 200 ? response.data : defaultResponse;
    } catch (e) {
      log(e.toString());
      analysis = defaultResponse;
    }

    final HistoryEntry historyEntry = HistoryEntry(
        imgPath, analysis, getColor(analysis["clip_result"]["quality"]));
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
    currentTipIndex = 0;
    tipsController = StreamController<String>();
    tipsController.add(tips[currentTipIndex]);
    // Fade out after 4 seconds
    Timer(Duration(seconds: 4), () {
      setState(() {
        opacity = 0.0;
      });
    });
    Timer.periodic(Duration(seconds: 5), (_) {
      currentTipIndex = (currentTipIndex + 1) % tips.length;
      tipsController.add(tips[currentTipIndex]);
      // Fade in
      setState(() {
        opacity = 0.70;
      });
      // Fade out after 4 seconds
      Timer(Duration(seconds: 4), () {
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
                return CircularProgressIndicator();
              },
            ),
            SizedBox(height: 20),
            StreamBuilder<String>(
              stream: tipsController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return AnimatedOpacity(
                    duration: Duration(milliseconds: 500),
                    opacity: opacity,
                    curve: Curves.easeInOut,
                    child: Text(
                      snapshot.data!,
                      style: TextStyle(
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
