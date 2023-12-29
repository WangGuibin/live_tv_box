import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

class HistoryList extends StatefulWidget {
  const HistoryList({super.key});

  @override
  State<StatefulWidget> createState() => _HistoryListState();
}

class _HistoryListState extends State<HistoryList> {
  @override
  Widget build(BuildContext context) {
    final LocalStorage storage = LocalStorage('UrlList.json');
    List<dynamic> urls = storage.getItem('urls') ?? [];

    return urls.isEmpty
        ? const Text('暂无数据')
        : Scaffold(
            appBar: AppBar(
              title: const Text('播放记录'),
            ),
            body: ListView.builder(
              prototypeItem: ListTile(
                title: Text(urls.first),
              ),
              itemBuilder: (context, index) {
                final item = urls[index];
                return Dismissible(
                  key: Key(item),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) {
                    //这里可以限制 滑哪边可以响应删除
                    return Future.value(
                        direction != DismissDirection.startToEnd);
                  },
                  onDismissed: (direction) {
                    // Remove the item from the data source.
                    //这里是item已经删除了 需要处理数据源 避免下标错乱
                    setState(() {
                      urls.removeAt(index);
                      storage.setItem('urls', urls);
                    });

                    // Then show a snackbar.
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('$item 已删除!')));
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
                    title: Text(item),
                    onTap: () {
                      Navigator.pop(context, item);
                    },
                  ),
                );
              },
              itemCount: urls.length,
            ),
          );
  }
}
