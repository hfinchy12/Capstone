import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:photo_coach/src/camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.appTitle = ""});

  @override
  State<HomePage> createState() => _HomePageState();

  final String appTitle;
}

class _HomePageState extends State<HomePage> {
  final historyKey = "history";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.appTitle),
          centerTitle: true,
        ),
        body: Column(children: [
          Row(
            children: [uploadButton(context), cameraButton(context)],
          ),
          Expanded(child: history())
        ]));
  }

  Widget uploadButton(BuildContext context) {
    return Expanded(
        child: Container(
            margin: const EdgeInsets.all(20.0),
            child: IconButton(
                icon: Image.asset("assets/images/photo_icon.png"),
                style: IconButton.styleFrom(
                    shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(100.0))),
                onPressed: () {
                  uploadImage();
                })));
  }

  Widget cameraButton(BuildContext context) {
    return Expanded(
        child: Container(
            margin: const EdgeInsets.all(20.0),
            child: IconButton(
                icon: Image.asset("assets/images/camera_icon.png"),
                style: IconButton.styleFrom(
                    shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(100.0))),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              CameraPage())); //This needs to route to "const CategoryPage()" once CategoryPage is created
                })));
  }

  void appendHistory(String imgPath) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> historyPaths = List.empty(growable: true);

    if (prefs.containsKey(historyKey) &&
        prefs.getStringList(historyKey) != null) {
      historyPaths = prefs.getStringList(historyKey)!.toList(growable: true);
    }

    historyPaths.insert(0, imgPath);
    prefs.setStringList(historyKey, historyPaths);
  }

  void removeHistory(int index) async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(historyKey) &&
        prefs.getStringList(historyKey) != null) {
      List<String> historyPaths =
          prefs.getStringList(historyKey)!.toList(growable: true);
      historyPaths.removeAt(index);
      prefs.setStringList(historyKey, historyPaths);
    }
  }

  Future<List<String>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? historyPaths = prefs.getStringList(historyKey);
    return historyPaths == null ? [] : historyPaths.toList();
  }

  void uploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      appendHistory(pickedFile.path);
      setState(() {});
    }
  }

  Widget history() {
    return FutureBuilder(
        future: historyFuture(),
        initialData: const Text("Loading History..."),
        builder: (BuildContext context, AsyncSnapshot<Widget> widget) {
          return widget.requireData;
        });
  }

  Future<Widget> historyFuture() async {
    List<String> historyPaths = await getHistory();
    List<Image> historyImages = List.empty(growable: true);

    for (final String path in historyPaths) {
      historyImages.add(Image.file(File(path)));
    }

    return GridView.count(crossAxisCount: 2, children: [
      for (int i = 0; i < historyImages.length; i++)
        GestureDetector(
            child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Card(
                    clipBehavior: Clip.hardEdge,
                    child:
                        FittedBox(fit: BoxFit.fill, child: historyImages[i]))),
            onLongPressStart: (LongPressStartDetails details) {
              showMenu(
                  context: context,
                  items: [
                    PopupMenuItem(
                        child: TextButton(
                            child: const Text("Delete"),
                            onPressed: () {
                              Navigator.pop(context); // Close showMenu popup
                              removeHistory(i);
                              setState(() {});
                            }))
                  ],
                  position: RelativeRect.fromLTRB(
                      details.globalPosition.dx,
                      details.globalPosition.dy,
                      details.globalPosition.dx,
                      details.globalPosition.dy));
            })
    ]);
  }
}
