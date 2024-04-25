library appp;
import 'package:flutter/material.dart';
import 'package:photo_coach/src/home_page/home_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const String appTitle = "Photo Coach";

    return const MaterialApp(
        title: appTitle,
        home: HomePage(
          appTitle: appTitle,
        ));

  }
}
