// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'other/app.dart';
import 'bindings/bindings.dart';

void main() {
  runApp(const VideoApp());
}

class VideoApp extends StatelessWidget {
  const VideoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '在线播放器',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      initialRoute: App.root,
      defaultTransition: Transition.rightToLeftWithFade,
      getPages: App.routes,
      initialBinding: GlobalBindings(),
    );
  }
}
