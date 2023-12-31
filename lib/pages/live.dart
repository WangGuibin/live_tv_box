import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../components/videoPlayer.dart';
import '../controller/videoPlayController.dart';
import '../other/app.dart';
import '../utils/fileManager.dart';
import '../utils/sourceManager.dart';
import '../parser/parseM3u.dart';
import '../utils/historyTools.dart';

Future<String> loadM3uAssets() async {
  return await rootBundle.loadString('assets/cctv.m3u');
}

// ignore: must_be_immutable
class LivePage extends GetView<VideoPlayController> {
  VideoPlayController playerController = Get.find<VideoPlayController>();
  final textController = TextEditingController();
  final remarkController = TextEditingController();
  final iptvSourceController = TextEditingController();

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
                  leadingWidth: 150,
                  leading: Row(
                    children: [
                      const SizedBox(width: 10),
                      IconButton(
                          tooltip: '源管理列表',
                          onPressed: () {
                            Get.toNamed(App.sourceList);
                          },
                          icon: const Icon(Icons.settings_applications)),
                      IconButton(
                          tooltip: '添加m3u订阅源',
                          onPressed: () {
                            Get.dialog(_addIptvSource(context));
                          },
                          icon: const Icon(Icons.subscriptions)),
                      IconButton(
                          tooltip: '导入频道配置',
                          onPressed: () {
                            pickAndReadFile();
                          },
                          icon: const Icon(Icons.insert_drive_file)),
                    ],
                  ),
                  actions: [
                    IconButton(
                        onPressed: () async {
                          dynamic result = await Get.toNamed(App.historyList);
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
                        tooltip: '全屏',
                        onPressed: _callChildChangeFullScreenMethod,
                        icon: isFullScreen()
                            ? const Icon(Icons.fullscreen_exit)
                            : const Icon(Icons.fullscreen)),
                    IconButton(
                        tooltip: '添加播放链接',
                        onPressed: () {
                          Get.dialog(_buildAlertDialog(context));
                        },
                        icon: const Icon(Icons.add_box_rounded)),
                    // IconButton(
                    //     tooltip: '测试按钮',
                    //     onPressed: () async {
                    //       dynamic m3uText = await loadM3uAssets();
                    //       List<Channel> channels = parseM3U8File(m3uText);
                    //       HistoryTools.getSubscribeChannels(channels);
                    //       for (Channel channel in channels) {
                    //         channel.logInfo();
                    //       }
                    //     },
                    //     icon: const Icon(Icons.home)),
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

  Widget _addIptvSource(BuildContext context) {
    return AlertDialog(
      title: const Text('添加IPTV源(仅支持指定格式)'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(
          controller: iptvSourceController,
          decoration:
              const InputDecoration(hintText: '在这里输入IPTV源链接地址(仅支持指定格式)'),
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
          child: const Text('添加订阅'),
          onPressed: () async {
            String url = iptvSourceController.text;
            SourceManager.addSubscriSource(url);
            Get.back();
          },
        ),
      ],
    );
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
