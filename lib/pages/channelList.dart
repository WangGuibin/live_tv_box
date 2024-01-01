import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../utils/historyTools.dart';
import '../utils/fileManager.dart';

class ChannelList extends StatefulWidget {
  const ChannelList({super.key});

  @override
  State<StatefulWidget> createState() => _ChannelListState();
}

class _ChannelListState extends State<ChannelList> {
  bool isEditMode = false;
  bool isAllSelect = false;
  List<ChannelItem> items = [];
  List<ChannelItem> selectItems = [];

  @override
  void initState() {
    setState(() {
      items = HistoryTools.getItems();
    });
    super.initState();
  }

  //copy text
  void copyTextToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      Get.showSnackbar(const GetSnackBar(
        duration: Duration(seconds: 2),
        title: '友情提示',
        message: '链接已复制到剪贴板',
        snackPosition: SnackPosition.TOP,
      ));
    });
  }

  void _toggleCheckBox(ChannelItem item) {
    setState(() {
      if (selectItems.contains(item)) {
        selectItems.remove(item);
      } else {
        selectItems.add(item);
      }
      isAllSelect = items.length == selectItems.length;
    });
  }

  void _showAlertDialog(String content, Function callBack) {
    Get.defaultDialog(
        title: '友情提示',
        content: Text(content),
        textCancel: '取消',
        textConfirm: '确定',
        onConfirm: () {
          callBack();
        });
  }

  //按钮组
  List<Widget> _createActions() {
    return [
      isEditMode
          ? IconButton(
              tooltip: '全选',
              onPressed: () {
                setState(() {
                  isAllSelect = !isAllSelect;
                  List<ChannelItem> localItems = List.of(
                      items); //不能直接引用不然会错乱 需要使用List.of或者List.from深拷贝一下啥的
                  selectItems = isAllSelect ? localItems : [];
                });
              },
              icon: Icon(
                  isAllSelect
                      ? Icons.check_box_rounded
                      : Icons.check_box_outline_blank_rounded,
                  color: Colors.lightBlue))
          : const Text(''),
      IconButton(
          tooltip: isEditMode ? '取消编辑' : '编辑',
          onPressed: () {
            setState(() {
              isEditMode = !isEditMode;
            });
          },
          icon: Icon(isEditMode ? Icons.cancel_rounded : Icons.edit_note)),
      IconButton(
          tooltip: '导入频道json配置',
          onPressed: () {
            pickAndReadFile();
          },
          icon: const Icon(Icons.insert_drive_file)),
      IconButton(
          tooltip: '导出频道json配置',
          onPressed: () {
            String jsonStr = HistoryTools.exportJsonData();
            saveTextFile(jsonStr);
            Get.showSnackbar(const GetSnackBar(
              duration: Duration(seconds: 2),
              title: '友情提示',
              message: '记录已导出成功!!',
              snackPosition: SnackPosition.TOP,
            ));
          },
          icon: const Icon(Icons.download)),
      const SizedBox(width: 30)
    ];
  }

  //cell滑动的背景
  Widget _createDismissibleBg() {
    return Container(
      color: Colors.red,
      child: const Row(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              '右滑拷贝播放链接',
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
    );
  }

  //创建cell
  Widget _createCell(ChannelItem item, int index) {
    return ListTile(
      leading: isEditMode
          ? Icon(
              selectItems.contains(item)
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              color: Colors.lightBlue)
          : Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black54, // 设置边框颜色
                  width: 0.5, // 设置边框宽度
                ),
              ),
              padding: const EdgeInsets.all(8.0), // 设置内边距
              child: Text(
                '${index + 1}', // 要展示的数字序号
                style: const TextStyle(
                    fontSize: 16.0, fontWeight: FontWeight.bold // 设置字体大小
                    ),
              ),
            ),
      title: Text(item.remark),
      subtitle: Text(item.url),
      onTap: () {
        // Get.offAllNamed(App.root,
        //     parameters: {'url': item.url, 'remark': item.remark});
        if (!isEditMode) {
          Get.back(result: item);
        } else {
          _toggleCheckBox(item);
        }
      },
    );
  }

  //删除时显示底部悬浮按钮
  Widget? _createDeleteActionButton() {
    return isEditMode
        ? FloatingActionButton(
            onPressed: () {
              _showAlertDialog('是否删除这${selectItems.length}个频道', () {
                setState(() {
                  items.removeWhere((element) => selectItems.contains(element));
                  HistoryTools.saveToDB(items);
                  selectItems = [];
                  isEditMode = !isEditMode;
                  Get.back();
                  Get.showSnackbar(const GetSnackBar(
                    duration: Duration(seconds: 1),
                    title: '友情提示',
                    message: '删除成功!!',
                    snackPosition: SnackPosition.TOP,
                  ));
                });
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red, // 设置颜色
                borderRadius: BorderRadius.circular(10), // 设置圆角
              ),
              width: 100,
              height: 100,
              // color: Colors.red,
              alignment: Alignment.center,
              child: Center(
                child: Text(
                  '删除(${selectItems.length})',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ))
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return items.isEmpty
        ? const Text('暂无数据')
        : Scaffold(
            appBar: AppBar(
              title: Text('频道列表(${items.length})'),
              centerTitle: true,
              actions: _createActions(),
            ),
            body: ListView.builder(
              itemBuilder: (context, index) {
                ChannelItem item = items[index];
                return Dismissible(
                  key: Key(item.url),
                  direction: DismissDirection.horizontal,
                  confirmDismiss: (direction) {
                    if (direction == DismissDirection.startToEnd) {
                      copyTextToClipboard(item.url);
                    } else {
                      _showAlertDialog(
                          '你确定要删除${item.remark != '' ? item.remark : item.url}频道吗',
                          () {
                        setState(() {
                          items.remove(item);
                          HistoryTools.saveToDB(items);
                        });
                        Get.back();
                        Get.showSnackbar(GetSnackBar(
                          duration: const Duration(seconds: 2),
                          title: '友情提示',
                          message:
                              '${item.remark != '' ? item.remark : item.url}已删除!',
                          snackPosition: SnackPosition.TOP,
                        ));
                      });
                    }
                    return Future.value(false);
                  },
                  // Show a red background as the item is swiped away.
                  background: _createDismissibleBg(),
                  child: _createCell(item, index),
                  // 系统自带的 CheckboxListTile 改不到左边去 不好用 !
                );
              },
              itemCount: items.length,
            ),
            floatingActionButton: _createDeleteActionButton(),
          );
  }
}
