import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:photo_coach/src/analysis/analysis_page.dart';
import 'package:photo_coach/src/history.dart';

class APICaller extends StatefulWidget {
  final String imgPath;
  final String category;

  const APICaller({super.key, required this.imgPath, required this.category});

  @override
  State<APICaller> createState() => _CallerState();
}

class _CallerState extends State<APICaller> {
  late Future<Map<String, dynamic>> responseFuture;

  static const String url =
      "http://photocoachcapstone.pythonanywhere.com/fullanalysis";
  static const Map<String, dynamic> defaultResponse = {
    "clip_result": {
        "brightness": 0.7804979681968689,
        "quality": 0.22963981330394745,
        "sharpness": 0.8442980051040649
    },
    "gpt_result": "Brightness: Good\nClarity: Fair\nSubject Focus: Poor\n\nAdvice to improve this photo:\n- Orientation: Rotate the camera to properly frame the subject.\n- Composition: Decide on a clear subject and compose the shot to emphasize it.\n- Stability: Keep the camera steady to avoid blur.\n- Cleanliness: Make sure the environment is tidy and free from distractions if that is part of the intended subject.\n- Perspective: Choose an angle that adds interest or importance to the subject."
  };

  Color getColor(double score){
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
        "comp_level": 2
      });
      BaseOptions options =
          BaseOptions(connectTimeout: const Duration(seconds: 360));
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
            future: responseFuture,
            builder: (BuildContext context,
                AsyncSnapshot<Map<String, dynamic>> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AnalysisPage(
                            imgPath: widget.imgPath,
                            analysis: snapshot.data!)));
              }
              return const CircularProgressIndicator();
            }));
  }
}
