import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:localstorage/localstorage.dart';
import 'dart:html';

class MyVideoPlayer extends StatefulWidget {
  const MyVideoPlayer(
      {required Key key, required this.url, required this.onChange})
      : super(key: key);

  final String url;
  final Function onChange;

  @override
  State<MyVideoPlayer> createState() => MyVideoPlayerState();
}

class MyVideoPlayerState extends State<MyVideoPlayer> {
  late VideoPlayerController _controller;

  late bool _enableFullScreen;
  late bool _displayPlayBtn;
  final LocalStorage storage = LocalStorage('UrlList.json');
  bool isHovering = true;

  @override
  void initState() {
    super.initState();
    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
        ..initialize().then((_) {
          setState(() {});
        });
      _enableFullScreen = false;
      _displayPlayBtn = true;
    } catch (e) {
      print(e);
    }
  }

  void playNewUrl(String url) {
    _controller.dispose();
    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(url))
        ..initialize().then((_) {
          setState(() {});
        });
      _enableFullScreen = false;
      _displayPlayBtn = false;
      _controller.play();
      List<dynamic> urls = storage.getItem('urls') ?? [];
      //去重
      urls = urls.where((element) => element != url).toList();
      urls.insert(0, url);
      storage.setItem('urls', urls);
      widget.onChange();
    } catch (e) {
      print(e);
    }
  }

  //仅播放中短暂显示一下
  void _tapDisplayBtn() {
    if (isPlaying() == false) return;
    setState(() {
      _displayPlayBtn = true;
    });
    hiddenPlayBtn();
  }

  /// 是否全屏
  bool isFullScreen() {
    return _enableFullScreen;
  }

  ///是否正在播放中
  bool isPlaying() {
    return _controller.value.isPlaying;
  }

  /// 双击切换播放状态
  void togglePlay() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
      _displayPlayBtn = true;
    });

    /// 如果2秒后是播放状态则隐藏播放按钮
    hiddenPlayBtn();
  }

  void hiddenPlayBtn() {
    Future.delayed(const Duration(seconds: 2), () {
      if (isPlaying()) {
        setState(() {
          _displayPlayBtn = false;
          isHovering = false;
        });
      }
    });
  }

  ///切换全屏
  void changeFullScreen() {
    setState(() {
      _enableFullScreen = !_enableFullScreen;
      widget.onChange();
      if (_enableFullScreen) {
        _goFullScreen();
      } else {
        _exitFullScreen();
      }
    });
  }

  void _goFullScreen() {
    document.documentElement?.requestFullscreen();
  }

  void _exitFullScreen() {
    document.exitFullscreen();
  }

  @override
  Widget build(BuildContext context) {
    final aspectRatio = _controller.value.aspectRatio;
    return GestureDetector(
      onTap: _tapDisplayBtn,
      onDoubleTap: togglePlay,
      child: Container(
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
            _displayPlayBtn
                ? IconButton(
                    onPressed: togglePlay,
                    icon: Icon(_controller.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow),
                    iconSize: 60,
                    color: Colors.white,
                  )
                : const Text(''),
            Positioned(
              bottom: 10,
              right: 10,
              child: MouseRegion(
                  onEnter: (PointerEvent details) =>
                      setState(() => isHovering = true),
                  onExit: (PointerEvent details) => {
                        setState(() {
                          Future.delayed(const Duration(seconds: 5), () {
                            if (isPlaying()) {
                              setState(() {
                                isHovering = false;
                              });
                            }
                          });
                        })
                      },
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: IconButton(
                        hoverColor: Colors.white54,
                        onPressed: changeFullScreen,
                        icon: Icon(
                          _enableFullScreen
                              ? Icons.fullscreen_exit
                              : Icons.fullscreen,
                          color: isHovering ? Colors.white : Colors.white54,
                        )),
                  )),
            )
          ])),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
