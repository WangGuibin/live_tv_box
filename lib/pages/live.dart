import 'dart:html';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../components/videoPlayer.dart';
import '../controller/videoPlayController.dart';
import '../other/app.dart';

Future<String> loadM3uAssets() async {
  return await rootBundle.loadString('assets/cctv.m3u');
}

// ignore: must_be_immutable
class LivePage extends GetView<VideoPlayController> {
  VideoPlayController playerController = Get.find<VideoPlayController>();
  final textController = TextEditingController();
  final remarkController = TextEditingController();

  LivePage({super.key});

  void _callChildChangeFullScreenMethod() {
    playerController.toggleFullScreen();
  }

  bool isFullScreen() {
    return playerController.enableFullScreen.isTrue;
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 300), () {
      String url = Get.parameters['url'] ?? '';
      String remark = Get.parameters['remark'] ?? '';
      if (url != '') {
        playerController.playNewUrl(url, remark: remark);
      }
    });

    return Obx(() {
      return Scaffold(
          appBar: isFullScreen()
              ? null
              : AppBar(
                  title: Text(controller.currenPlayName.value),
                  centerTitle: true,
                  actions: [
                    IconButton(
                        tooltip: '全屏',
                        onPressed: _callChildChangeFullScreenMethod,
                        icon: isFullScreen()
                            ? const Icon(Icons.fullscreen_exit)
                            : const Icon(Icons.fullscreen)),
                    IconButton(
                        onPressed: () async {
                          dynamic result = await Get.toNamed(App.channelPage);
                          if (result?.url != null &&
                              result?.url !=
                                  playerController.currenPlayUrl.value) {
                            //点击不同的url才会重新播放
                            playerController.playNewUrl(result.url,
                                remark: result.remark);
                          }
                        },
                        tooltip: '频道列表',
                        icon: const Icon(Icons.playlist_play)),
                    IconButton(
                        tooltip: '添加播放链接',
                        onPressed: () {
                          Get.dialog(_buildAlertDialog(context));
                        },
                        icon: const Icon(Icons.add_box)),
                    IconButton(
                        tooltip: 'm3u/txt源管理',
                        onPressed: () {
                          Get.toNamed(App.sourceList);
                        },
                        icon: const Icon(Icons.settings)),
                    IconButton(
                        tooltip: 'github',
                        onPressed: () {
                          window.open(
                              'https://github.com/WangGuibin/live_tv_box',
                              'github');
                        },
                        icon: const Icon(Icons.code)),
                    const SizedBox(width: 30),
                  ],
                ),
          body: controller.isLoading.isTrue
              ? const Center(child: CircularProgressIndicator())
              : Container(
                  padding: const EdgeInsets.all(0),
                  alignment: Alignment.center,
                  child: const Column(
                      children: [Expanded(child: MyVideoPlayer())]),
                  // 替换YourWidget为您的实际小部件
                ));
    });
  }

  Widget _buildAlertDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('输入播放地址/备注'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(
          controller: textController,
          decoration: const InputDecoration(hintText: '在这里输入m3u8直播地址'),
        ),
        TextField(
          controller: remarkController,
          decoration: const InputDecoration(hintText: '在这里输入备注(可选)'),
        )
      ]),
      actions: <Widget>[
        TextButton(
          child: const Text('取消'),
          onPressed: () {
            Get.back();
          },
        ),
        TextButton(
          child: const Text('播放'),
          onPressed: () {
            String text = textController.text;
            // playerController.playNewUrl(text.trim(),
            //     remark: remarkController.text.trim());
            Get.back();
            Get.offAllNamed(App.root, parameters: {
              'url': text.trim(),
              'remark': remarkController.text.trim()
            });
          },
        ),
      ],
    );
  }
}
