//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; 
/* HTTP functionality adapted from ChatGPT's response to
* "How do I make an API call in Flutter?"
* Generated 3/6/24 */
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class AnalysisPage extends StatelessWidget {
  final String imagePath;

  const AnalysisPage({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Results'),
      ),
      body: Column(
        children: <Widget>[
        Image.file(File(imagePath)),
        _MetricBars()
        ]
      )
    );
  }
}

class _MetricBars extends StatefulWidget {
  @override
  MetricBarState createState() => MetricBarState();
}

class MetricBarState extends State<_MetricBars> {
  String _responseData = '';

  /*
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
  Future<void> _fetchData() async {
    try {
      final http.Response response = await http.get(Uri.parse('http://127.0.0.1:5000'));
      if (response.statusCode == 200) {
        setState(() {
          _responseData = response.body;
        });
      } else {
        // Handle errors
        //print('Issue fetching feedback: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exceptions
      //print('Exception occured: $e');
    }
  }

  String getRating(double score){
    if (score < 0.33){
      return 'Poor';
    } else if (score < 0.66) {
      return 'Fair';
    } else {
      return 'Good';
    }
  }
  
  // Based on code from https://api.flutter.dev/flutter/widgets/ListView-class.html
  Widget _addMetrics() {
    _fetchData();
    Map<String, dynamic> jsonData = json.decode(_responseData);
    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ListTile(
          title: Text('brightness: '+getRating(jsonData['brightness']), textAlign: TextAlign.left),
        ),
        const Divider(),
        ListTile(
          title: Text('noisiness: '+getRating(jsonData['noisiness']), textAlign: TextAlign.left),
        ),
        const Divider(),
        ListTile(
          title: Text('quality: '+getRating(jsonData['quality']), textAlign: TextAlign.left),
        ),
        const Divider(),
        ListTile(
          title: Text('sharpness: '+getRating(jsonData['sharpness']), textAlign: TextAlign.left),
        ),
        const Divider(),
        Container(
            height: 100,
            color: Colors.grey[200],
            child: Text(jsonData['gpt_result']['choices'][0]['message']['content'], textAlign: TextAlign.left)
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _addMetrics()
    );
  }

}
