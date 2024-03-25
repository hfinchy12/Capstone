/* HTTP functionality adapted from ChatGPT's response to
* "How do I make an API call in Flutter?"
* Generated 3/6/24 */
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:photo_coach/src/analysis/analysis_page.dart';
import 'dart:convert';
//import 'dart:io';

class APICaller extends StatefulWidget {
  final String imagePath;
  final String category;

  const APICaller({Key? key, required this.imagePath, required this.category}) : super(key: key);
    
  @override
  State<APICaller> createState() => _CallerState();
}

/* Asynchronous initialization adapted from ChatGPT's response to
* "You said, 'If you need to initialize a variable asynchronously, 
  you can use late with a Future and handle the asynchronous initialization in the initState method of a StatefulWidget instead.'
  Explain how to do this and provide context, please."
* Generated 3/22/24 */
class _CallerState extends State<APICaller> {
  late Future<String> responseFuture;
  
  /* Response template
  {
    "clip_result": {
        "brightness": double [0,1],
        "noisiness": double [0,1],
        "quality": double [0,1],
        "sharpness": double [0,1]
    },
    "gpt_result": {
        "choices": [
            {
                "finish_reason": "stop",
                "index": 0,
                "message": {
                    "content": "Brightness: Good\nClarity: Good\nOrientation: Good\n\nThis photo appears to be well-executed with a high dynamic range capturing the rich colors in the sky and the reflections on the water. The photo is clear and seems to be taken with a steady hand or a tripod, and the orientation with the pier leading into the image provides a strong composition.\n\nAdvice for improvement would depend on the artistic intent and personal preference. However, it's already a strong image. If the photographer wanted to try different looks, they could consider experimenting with different exposure times to either capture more texture in the water or create an even smoother effect. Another aspect to experiment with could be the white balance to alter the mood of the picture, making it warmer or cooler depending on the desired atmosphere.",
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
    }
  */
  Future<String> _sendPicture(String imagePath, String category) async {
    String template = "{\"clip_result\": {\"brightness\": 0.966113,\"noisiness\": 0.9101740,\"quality\": 0.99347877,\"sharpness\": 0.99758303},\"gpt_result\": {\"choices\": [{\"finish_reason\": \"stop\",\"index\": 0,\"message\": {\"content\": \"Brightness: Good\\nClarity: Good\\nOrientation: Good\\n\\nThis photo appears to be well-executed with a high dynamic range capturing the rich colors in the sky and the reflections on the water. The photo is clear and seems to be taken with a steady hand or a tripod, and the orientation with the pier leading into the image provides a strong composition.\\n\\nAdvice for improvement would depend on the artistic intent and personal preference. However, it's already a strong image. If the photographer wanted to try different looks, they could consider experimenting with different exposure times to either capture more texture in the water or create an even smoother effect. Another aspect to experiment with could be the white balance to alter the mood of the picture, making it warmer or cooler depending on the desired atmosphere.\",\"role\": \"assistant\"}}],\"created\": 1709563319,\"id\": \"chatcmpl-8z3nrwbsf96kNOvIOO4JUzbyPDM33\",\"model\": \"gpt-4-1106-vision-preview\",\"object\": \"chat.completion\",\"usage\": {\"completion_tokens\": 155,\"prompt_tokens\": 466,\"total_tokens\": 621}}}";
    try {
      final http.Response response = await http.post(
        Uri.parse('http://127.0.0.1:5000/testupload'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'picture': imagePath,
          'comp_level': '2',
          'category': category,
        }),
      );
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return template;
      }
    } catch (e) {
      return template;
    }
  }

  @override
  void initState() {
    super.initState();
    responseFuture = _sendPicture(widget.imagePath, widget.category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(future: responseFuture, 
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              String responseStr = snapshot.data!;
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return AnalysisPage(imagePath: widget.imagePath, responseStr: snapshot.data!,);
                }, // Pass the category parameter
              ));
              return Text(responseStr);
            }
          })
    );
  }
}