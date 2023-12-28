import 'package:flutter/material.dart';
import './live.dart';
import 'dart:ui_web';

void main() {
  runApp(const VideoApp());
}

class VideoApp extends StatefulWidget {
  const VideoApp({super.key});

  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: const LivePage(),
    );
  }
}
