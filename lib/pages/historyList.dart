import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../utils/historyTools.dart';
import '../utils/fileManager.dart';
import '../other/app.dart';

class HistoryList extends StatefulWidget {
  const HistoryList({super.key});

  @override
  State<StatefulWidget> createState() => _HistoryListState();
}

class _HistoryListState extends State<HistoryList> {
  //copy text
  void copyTextToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      showCopiedToClipboardSnackbar(context);
    });
  }

  void showCopiedToClipboardSnackbar(BuildContext context) {
    const snackBar = SnackBar(
      content: Text('链接已复制到剪贴板'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    var items = HistoryTools.getItems();
    return items.isEmpty
        ? const Text('暂无数据')
        : Scaffold(
            appBar: AppBar(
              title: const Text('频道列表'),
              actions: [
                IconButton(
                    tooltip: '导出频道配置',
                    onPressed: () {
                      String jsonStr = HistoryTools.exportJsonData();
                      saveTextFile(jsonStr);
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('记录已导出成功!')));
                    },
                    icon: const Icon(Icons.download)),
                const SizedBox(width: 10)
              ],
            ),
            body: ListView.builder(
              itemBuilder: (context, index) {
                HistoryItem item = items[index];
                return Dismissible(
                  key: Key(item.url),
                  direction: DismissDirection.horizontal,
                  confirmDismiss: (direction) {
                    if (direction == DismissDirection.startToEnd) {
                      copyTextToClipboard(context, item.url);
                    }

                    return Future.value(
                        DismissDirection.endToStart == direction);
                  },
                  onDismissed: (direction) {
                    if (direction == DismissDirection.endToStart) {
                      items.remove(item);
                      HistoryTools.saveToDB(items);
                      setState(() {});

                      // Then show a snackbar.
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('$item 已删除!')));
                    }
                  },
                  // Show a red background as the item is swiped away.
                  background: Container(
                    color: Colors.red,
                    child: const Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            '右滑拷贝',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
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
                    title: Text(item.remark),
                    subtitle: Text(item.url),
                    onTap: () {
                      // Get.offAllNamed(App.root,
                      //     parameters: {'url': item.url, 'remark': item.remark});
                      Get.back(result: item);
                    },
                  ),
                );
              },
              itemCount: items.length,
            ),
          );
  }
}
