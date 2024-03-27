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
      "brightness": 1.0,
      "noisiness": 1.0,
      "quality": 1.0,
      "sharpness": 1.0
    },
    "gpt_result": {
      "choices": [
        {
          "finish_reason": "stop",
          "index": 0,
          "message": {
            "content":
                "Brightness: Good\nClarity: Good\nOrientation: Good\n\nThis photo appears to be well-executed with a high dynamic range capturing the rich colors in the sky and the reflections on the water. The photo is clear and seems to be taken with a steady hand or a tripod, and the orientation with the pier leading into the image provides a strong composition.\n\nAdvice for improvement would depend on the artistic intent and personal preference. However, it's already a strong image. If the photographer wanted to try different looks, they could consider experimenting with different exposure times to either capture more texture in the water or create an even smoother effect. Another aspect to experiment with could be the white balance to alter the mood of the picture, making it warmer or cooler depending on the desired atmosphere.",
            "role": "assistant"
          }
        }
      ],
      "created": 1709563319,
      "id": "chatcmpl-8z3nrwbsf96kNOvIOO4JUzbyPDM33",
      "model": "gpt-4-1106-vision-preview",
      "object": "chat.completion",
      "usage": {
        "completion_tokens": 155,
        "prompt_tokens": 466,
        "total_tokens": 621
      }
    }
  };

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
        imgPath, analysis, Colors.green); // TODO: calculate rating color
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
