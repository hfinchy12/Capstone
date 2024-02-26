import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_coach/src/analysis/analysis_page.dart';

import 'package:photo_coach/src/category_page/category_page.dart';
import 'package:photo_coach/src/history.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.appTitle = ""});

  @override
  State<HomePage> createState() => _HomePageState();

  final String appTitle;
}

class _HomePageState extends State<HomePage> {
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

  void uploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      History.appendHistory(pickedFile.path,
          ""); // This needs to be moved to the analysis page later
      setState(() {});

      // Must be mounted to use the Navigator in an async function
      if (!mounted) {
        return;
      }
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CategoryPage(
                  fromUpload: true, uploadImagePath: pickedFile.path)));
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
    List<String> historyPaths = await History.getHistoryPaths();
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
                        FittedBox(fit: BoxFit.cover, child: historyImages[i]))),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AnalysisPage(imagePath: historyPaths[i])));
            },
            onLongPressStart: (LongPressStartDetails details) {
              showMenu(
                  context: context,
                  items: [
                    PopupMenuItem(
                        child: TextButton(
                            child: const Text("Delete"),
                            onPressed: () {
                              Navigator.pop(context); // Close showMenu popup
                              History.removeHistory(i);
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
