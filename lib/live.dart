import 'package:flutter/material.dart';
//封装播放
import './videoPlayer.dart';

class LivePage extends StatefulWidget {
  const LivePage({super.key});

  @override
  State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> {
  late String playUrl;
  final TextEditingController inputController = TextEditingController();

  final GlobalKey<MyVideoPlayerState> childKey =
      GlobalKey<MyVideoPlayerState>();

  void _callChildChangeFullScreenMethod() {
    childKey.currentState?.changeFullScreen();
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      playUrl = "https://node1.olelive.com:6443/live/CCTV1HD/hls.m3u8";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("m3u8在线播放器"),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: _callChildChangeFullScreenMethod,
              icon: childKey.currentState?.isFullScreen() == true
                  ? const Icon(Icons.fullscreen_exit)
                  : const Icon(Icons.fullscreen)),
          IconButton(
              onPressed: () {
                _showInputDialog(context);
              },
              icon: const Icon(Icons.add_box_rounded)),
          const SizedBox(width: 30),
        ],
      ),
      body: Center(
        child: Column(children: [
          Expanded(child: MyVideoPlayer(key: childKey, url: playUrl))
        ]),
      ),
    );
  }

  //弹窗 输入url
  _showInputDialog(context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('请输入url'),
          content: TextField(
            controller: inputController,
            decoration: const InputDecoration(hintText: '在这里输入m3u8直播地址'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('播放'),
              onPressed: () {
                String inputText = inputController.text;
                setState(() {
                  playUrl = inputText.trim();
                  childKey.currentState?.playNewUrl(playUrl);
                });
                // 在这里处理确认按钮的逻辑
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
