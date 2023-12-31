import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../utils/sourceManager.dart';
import '../parser/parseM3u.dart';
import '../utils/historyTools.dart';
import '../controller/sourceListController.dart';
import '../other/app.dart';

class SourceList extends GetView<SourceListController> {
  SourceList({super.key});
  Future<void> initMyContext() async {
    await Future.delayed(const Duration(milliseconds: 200)); //模拟异步延时200ms
  }

  final _iptvSourceController = TextEditingController();

  Widget _addIptvSource(BuildContext context) {
    return AlertDialog(
      title: const Text('添加IPTV源(仅支持指定格式)'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(
          controller: _iptvSourceController,
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
            String url = _iptvSourceController.text;
            await SourceManager.addSubscriSource(url);
            Get.back();
            controller.items = SourceManager.getSourceList();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initMyContext(), //异步渲染UI
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const LoadingScreen(text: '加载中...');
          default:
            return controller.items.isEmpty
                ? const Text('暂无数据')
                : Scaffold(
                    appBar: AppBar(
                      title: const Text('订阅源管理'),
                      centerTitle: true,
                      actions: [
                        IconButton(
                            tooltip: '添加m3u/txt订阅源',
                            onPressed: () {
                              Get.dialog(_addIptvSource(context));
                            },
                            icon: const Icon(Icons.subscriptions_rounded)),
                        IconButton(
                            tooltip: '拉取同步最新配置',
                            onPressed: () {
                              SourceManager.addSubscriSource(
                                  controller.selectSource);
                              Get.showSnackbar(const GetSnackBar(
                                duration: Duration(seconds: 2),
                                title: '友情提示',
                                message: '已同步最新配置',
                                snackPosition: SnackPosition.TOP,
                              ));
                            },
                            icon: const Icon(Icons.sync_outlined)),
                        IconButton(
                            tooltip: '拷贝分享配置链接',
                            onPressed: () {
                              String shareText = controller.items
                                  .map((element) => element.iptvUrl)
                                  .toList()
                                  .join('\n');
                              Clipboard.setData(ClipboardData(text: shareText));
                              Get.showSnackbar(const GetSnackBar(
                                duration: Duration(seconds: 2),
                                title: '友情提示',
                                message: '配置已成功拷贝至剪贴板!',
                                snackPosition: SnackPosition.TOP,
                              ));
                            },
                            icon: const Icon(Icons.share)),
                        const SizedBox(width: 20)
                      ],
                    ),
                    body: Obx(() {
                      return ListView.builder(
                          itemCount: controller.items.length,
                          itemBuilder: (context, index) {
                            SourceItem item = controller.items[index];
                            return Dismissible(
                              key: Key(item.iptvUrl),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (direction) {
                                return Future.value(
                                    DismissDirection.endToStart == direction);
                              },
                              onDismissed: (direction) {
                                if (direction == DismissDirection.endToStart) {
                                  controller.items.remove(item);
                                  SourceManager.saveSourceList(
                                      controller.items);
                                  controller.update();
                                  // Then show a snackbar.
                                  Get.showSnackbar(GetSnackBar(
                                    duration: const Duration(seconds: 2),
                                    title: '友情提示',
                                    message: '${item.iptvUrl} 已被删除!',
                                    snackPosition: SnackPosition.TOP,
                                  ));
                                }
                              },
                              // Show a red background as the item is swiped away.
                              background: Container(
                                color: Colors.red,
                                child: const Row(
                                  children: [
                                    Expanded(child: SizedBox.shrink()),
                                    Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Text(
                                        '左滑删除',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              child: ListTile(
                                title: Text(item.iptvUrl),
                                trailing: Obx(() => Icon(
                                    controller.selectSource == item.iptvUrl
                                        ? Icons.check_box_rounded
                                        : Icons.check_box_outline_blank_rounded,
                                    color: Colors.lightBlue)),
                                onTap: () {
                                  controller.selectSource = item.iptvUrl;
                                  if (SourceManager.getCurrentSource() != '' &&
                                      SourceManager.getCurrentSource() !=
                                          null) {
                                    SourceItem currentItem =
                                        SourceManager.getSourceList()
                                            .where((element) =>
                                                element.iptvUrl == item.iptvUrl)
                                            .toList()
                                            .first;
                                    List<Channel> channels =
                                        parseM3U8File(currentItem);
                                    HistoryTools.getSubscribeChannels(channels);

                                    Get.showSnackbar(GetSnackBar(
                                      duration: const Duration(seconds: 2),
                                      title: '友情提示',
                                      message: '${item.iptvUrl}的所有频道已添加至频道列表!',
                                      snackPosition: SnackPosition.TOP,
                                    ));
                                    // Get.offAndToNamed(App.channelPage);
                                  }
                                },
                              ),
                            );
                          });
                    }),
                  );
        }
      },
    );
  }
}

class LoadingScreen extends StatelessWidget {
  final String text;

  const LoadingScreen({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loading...'),
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
