import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_coach/category_page/category_page.dart';
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
                          builder: (context) => const CategoryPage()));
                })));
  }

  void appendHistory(String imgPath) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> historyPaths = List.empty(growable: true);

    if (prefs.containsKey(historyKey) &&
        prefs.getStringList(historyKey) != null) {
      historyPaths = prefs.getStringList(historyKey)!.toList(growable: true);
    }

    historyPaths.add(imgPath);
    prefs.setStringList(historyKey, historyPaths);
  }

  void removeHistory(int index) async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(historyKey) &&
        prefs.getStringList(historyKey) != null) {
      List<String> historyPaths =
          prefs.getStringList(historyKey)!.toList(growable: true);
      historyPaths.removeAt(index);
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

    return GridView.count(crossAxisCount: 2, children: historyImages);
  }
}
