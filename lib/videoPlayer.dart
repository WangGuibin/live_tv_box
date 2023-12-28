import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MyVideoPlayer extends StatefulWidget {
  const MyVideoPlayer({required Key key, required this.url}) : super(key: key);

  final String url;

  @override
  State<MyVideoPlayer> createState() => MyVideoPlayerState();
}

class MyVideoPlayerState extends State<MyVideoPlayer> {
  late VideoPlayerController _controller;
  late bool _enableFullScreen;

  @override
  void initState() {
    super.initState();
    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
        ..initialize().then((_) {
          setState(() {});
        });
      _enableFullScreen = false;
    } catch (e) {
      print(e);
    }
  }

  void playNewUrl(String url) {
    print(url);
    _controller.dispose();
    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(url))
        ..initialize().then((_) {
          setState(() {});
        });
      _enableFullScreen = false;
      _controller.play();
    } catch (e) {
      print(e);
    }
  }

  bool isFullScreen() {
    return _enableFullScreen;
  }

  ///切换全屏
  void changeFullScreen() {
    setState(() {
      _enableFullScreen = !_enableFullScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final aspectRatio = _controller.value.aspectRatio;
    return Container(
        width: _enableFullScreen ? MediaQuery.of(context).size.width : 480.0,
        height: _enableFullScreen
            ? MediaQuery.of(context).size.height
            : 480.0 * aspectRatio,
        color: Colors.black,
        child: Stack(alignment: Alignment.center, children: [
          AspectRatio(
            aspectRatio: aspectRatio,
            child: VideoPlayer(_controller),
          ),
          IconButton(
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              },
              icon: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 50,
              )),
          Positioned(
            bottom: 10,
            right: 10,
            child: IconButton(
                onPressed: changeFullScreen,
                icon: Icon(
                  _enableFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  color: Colors.white,
                )),
          )
        ]));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
