import 'package:flutter/material.dart';
import '../utils/sourceManager.dart';
import 'package:get/get.dart';
import '../parser/parseM3u.dart';
import '../utils/historyTools.dart';

class SourceListController extends GetxController {
  final RxString _selectSource = ''.obs;
  late SourceManager manager;

  get selectSource {
    return _selectSource.value;
  }

  set selectSource(val) {
    _selectSource.value = val;
    SourceManager.setCurrentSource(val);
    update();
  }

  @override
  void onInit() {
    _selectSource.value = SourceManager.getCurrentSource() ?? '';
    super.onInit();
  }
}

class SourceList extends GetView<SourceListController> {
  const SourceList({super.key});
  Future<void> initMyContext() async {
    await Future.delayed(const Duration(milliseconds: 200)); //模拟异步延时200ms
  }

  @override
  Widget build(BuildContext context) {
    List items = SourceManager.getSourceList();

    return FutureBuilder(
      future: initMyContext(), //异步渲染UI
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const LoadingScreen(text: '加载中...');
          default:
            return items.isEmpty
                ? const Text('暂无数据')
                : Scaffold(
                    appBar: AppBar(
                      title: const Text('订阅源列表管理'),
                    ),
                    body: ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          SourceItem item = items[index];
                          return Dismissible(
                            key: Key(item.iptvUrl),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (direction) {
                              return Future.value(
                                  DismissDirection.endToStart == direction);
                            },
                            onDismissed: (direction) {
                              if (direction == DismissDirection.endToStart) {
                                items.remove(item);
                                SourceManager.saveSourceList(items);
                                controller.update();
                                // Then show a snackbar.
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('${item.iptvUrl} 已被删除!')));
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
                              trailing: Obx(() => Checkbox(
                                    onChanged: (value) {},
                                    value:
                                        controller.selectSource == item.iptvUrl,
                                  )),
                              onTap: () {
                                controller.selectSource = item.iptvUrl;
                                if (SourceManager.getCurrentSource() != '' &&
                                    SourceManager.getCurrentSource() != null) {
                                  SourceItem currentItem =
                                      SourceManager.getSourceList()
                                          .where((element) =>
                                              element.iptvUrl == item.iptvUrl)
                                          .toList()
                                          .first;
                                  List<Channel> channels =
                                      parseM3U8File(currentItem.iptvText);
                                  HistoryTools.getSubscribeChannels(channels);
                                }
                              },
                            ),
                          );
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
