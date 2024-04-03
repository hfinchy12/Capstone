import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_coach/src/analysis/analysis_page.dart';

import 'package:photo_coach/src/category_page/category_page.dart';
import 'package:photo_coach/src/history.dart';
import 'package:uuid/uuid.dart';

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
        body: SingleChildScrollView(
            child: Column(children: [
          uploadButton(context),
          cameraButton(context),
          history()
        ])));
  }

  Widget uploadButton(BuildContext context) {
    return Container(
        width: 500.0,
        height: 100.0,
        margin: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
        child: ElevatedButton.icon(
            icon: Image.asset("assets/images/photo_ico.png"),
            label: const Text("Upload Photo", style: TextStyle(fontSize: 24.0)),
            style: IconButton.styleFrom(
                shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0))),
            onPressed: () {
              uploadImage();
            }));
  }

  Widget cameraButton(BuildContext context) {
    return Container(
        width: 500.0,
        height: 100.0,
        margin: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
        child: ElevatedButton.icon(
            icon: Image.asset("assets/images/camera_ico.png"),
            label: const Text("Take Photo", style: TextStyle(fontSize: 24.0)),
            style: IconButton.styleFrom(
                shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0))),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CategoryPage()));
            }));
  }

  void uploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String newImgPath = "${appDocDir.path}/${const Uuid().v1()}";
      File imgFile = File(pickedFile.path);
      await imgFile.copy(newImgPath);
      imgFile.delete();

      if (!mounted) {
        return;
      }
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  CategoryPage(fromUpload: true, uploadImagePath: newImgPath)));
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
    List<HistoryEntry> history = await History.getHistory();

    return GridView.count(
        crossAxisCount: 3,
        primary: false,
        shrinkWrap: true,
        children: [
          for (int i = 0; i < history.length; i++)
            GestureDetector(
                child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Card(
                        clipBehavior: Clip.hardEdge,
                        elevation: 10.0,
                        child: Stack(fit: StackFit.passthrough, children: [
                          FittedBox(
                            fit: BoxFit.cover,
                            child: Image.file(File(history[i].imgPath)),
                          ),
                          Container(
                              alignment: Alignment.topRight,
                              padding: const EdgeInsets.all(5.0),
                              child: CircleAvatar(
                                  backgroundColor: history[i].ratingColor,
                                  radius: 10.0))
                        ]))),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AnalysisPage(
                                imgPath: history[i].imgPath,
                                analysis: history[i].analysis,
                                historyIndex: i,
                              )));
                },
                onLongPressStart: (LongPressStartDetails details) {
                  showMenu(
                      context: context,
                      items: [
                        PopupMenuItem(
                            child: Center(
                                child: TextButton(
                                    child: const Text("Delete",
                                        style: TextStyle(color: Colors.red)),
                                    onPressed: () async {
                                      Navigator.pop(
                                          context); // Close showMenu popup
                                      await History.remove(i);
                                      setState(() {});
                                    })))
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
