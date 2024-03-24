//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; 
/* HTTP functionality adapted from ChatGPT's response to
* "How do I make an API call in Flutter?"
* Generated 3/6/24 */
import 'dart:convert';
import 'dart:io';

String getRating(double score){
  if (score < 0.33){
    return 'Poor';
  } else if (score < 0.66) {
    return 'Fair';
  } else {
    return 'Good';
  }
}

class AnalysisPage extends StatelessWidget {
  final String imagePath;
  final String responseStr;

  const AnalysisPage({Key? key, required this.imagePath, required this.responseStr}) : super(key: key);

  // Based on code from https://api.flutter.dev/flutter/widgets/ListView-class.html
  Widget _addMetrics(String jsonStr) {
    //_sendPicture(imgPath, category);
    Map<String, dynamic> jsonData = json.decode(jsonStr);
    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ListTile(
          title: Text('brightness: ${getRating(jsonData['brightness'])}', textAlign: TextAlign.left),
        ),
        const Divider(),
        ListTile(
          title: Text('noisiness: ${getRating(jsonData['noisiness'])}', textAlign: TextAlign.left),
        ),
        const Divider(),
        ListTile(
          title: Text('quality: ${getRating(jsonData['quality'])}', textAlign: TextAlign.left),
        ),
        const Divider(),
        ListTile(
          title: Text('sharpness: ${getRating(jsonData['sharpness'])}', textAlign: TextAlign.left),
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
      appBar: AppBar(
        title: const Text('Analysis Results'),
      ),
      body: Column(
        children: <Widget>[
        Image.file(File(imagePath)),
        _addMetrics(responseStr)
        ]
      )
    );
  }
}

/* class AnalysisPage extends StatefulWidget {
  final String imagePath;
  final String category;

  const AnalysisPage({Key? key, required this.imagePath, required this.category}) : super(key: key);

  //const AnalysisPage.oldAnalysis({Key? key, required this.imagePath, required this.responseStr}) : category="", super(key: key);

  // Based on code from https://api.flutter.dev/flutter/widgets/ListView-class.html
  Widget _addMetrics(String jsonStr) {
    //_sendPicture(imgPath, category);
    Map<String, dynamic> jsonData = json.decode(jsonStr);
    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ListTile(
          title: Text('brightness: ${getRating(jsonData['brightness'])}', textAlign: TextAlign.left),
        ),
        const Divider(),
        ListTile(
          title: Text('noisiness: ${getRating(jsonData['noisiness'])}', textAlign: TextAlign.left),
        ),
        const Divider(),
        ListTile(
          title: Text('quality: ${getRating(jsonData['quality'])}', textAlign: TextAlign.left),
        ),
        const Divider(),
        ListTile(
          title: Text('sharpness: ${getRating(jsonData['sharpness'])}', textAlign: TextAlign.left),
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
  Future<String> _sendPicture(String imagePath, String category) async {
    String template = "{\"clip_result\": {\"brightness\": 0.9661136269569397,\"noisiness\": 0.9101740121841431,\"quality\": 0.9934787750244141,\"sharpness\": 0.9975830316543579},\"gpt_result\": {\"choices\": [{\"finish_reason\": \"stop\",\"index\": 0,\"message\": {\"content\": \"Brightness: Good\nClarity: Good\nOrientation: Good\n\nThis photo appears to be well-executed with a high dynamic range capturing the rich colors in the sky and the reflections on the water. The photo is clear and seems to be taken with a steady hand or a tripod, and the orientation with the pier leading into the image provides a strong composition.\n\nAdvice for improvement would depend on the artistic intent and personal preference. However, it's already a strong image. If the photographer wanted to try different looks, they could consider experimenting with different exposure times to either capture more texture in the water or create an even smoother effect. Another aspect to experiment with could be the white balance to alter the mood of the picture, making it warmer or cooler depending on the desired atmosphere.\",\"role\": \"assistant\"}}],\"created\": 1709563319,\"id\": \"chatcmpl-8z3nrwbsf96kNOvIOO4JUzbyPDM33\",\"model\": \"gpt-4-1106-vision-preview\",\"object\": \"chat.completion\",\"usage\": {\"completion_tokens\": 155,\"prompt_tokens\": 466,\"total_tokens\": 621}}}";
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
  State<AnalysisPage> createState() => _AnalysisState();
}


/* Asynchronous initialization adapted from ChatGPT's response to
* "You said, 'If you need to initialize a variable asynchronously, 
  you can use late with a Future and handle the asynchronous initialization in the initState method of a StatefulWidget instead.'
  Explain how to do this and provide context, please."
* Generated 3/22/24 */
class _AnalysisState extends State<AnalysisPage> {
  late Future<String> responseFuture;
  late String responseStr;

  @override
  void initState() {
    super.initState();
    responseFuture = widget._sendPicture(widget.imagePath, widget.category);
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Results'),
      ),
      body: Column(
        children: <Widget>[
        Image.file(File(widget.imagePath)),
        FutureBuilder(future: responseFuture, 
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              responseStr = snapshot.data!; // Store data in _data variable
            }
          }),
        widget._addMetrics(responseStr)
        ]
      )
    );
  }
} */

/* MetricBar functionality adapted from ChatGPT's response to
* "How would I go about making a page with an image at the top and different
  expandable textboxes in rows below that image?"
* Generated 2/26/24 */
class _MetricBar extends StatefulWidget {
  final String title;
  final String rating;
  final String explanation;

  const _MetricBar({required this.title, required this.rating, required this.explanation});
 
  @override
  State<_MetricBar> createState() => _MetricBarState();
}

class _MetricBarState extends State<_MetricBar> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title + widget.rating, style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,), ),
            _expanded ? Text(widget.explanation, style: const TextStyle(fontSize: 16.0), ) : Container(),
          ],
        ),
      ),
    );
  }
}
