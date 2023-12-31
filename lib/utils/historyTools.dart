import 'dart:convert';
import 'package:localstorage/localstorage.dart';
import '../parser/parseM3u.dart';

const kUrlsLocalKey = 'urls.local.abc.key';

class HistoryItem {
  final String remark;
  final String url;
  HistoryItem({required this.remark, required this.url});

  toJSONEncodable() {
    Map<String, dynamic> item = {};
    item['url'] = url;
    item['remark'] = remark;
    return item;
  }

  static fromJsonMap(Map<String, dynamic> json) {
    return HistoryItem(remark: json['remark'], url: json['url']);
  }
}

class HistoryTools {
  static LocalStorage getStorage() {
    LocalStorage storage = LocalStorage('live_urls.json');
    return storage;
  }

  static List<HistoryItem> getItems() {
    String jsonStr = getStorage().getItem(kUrlsLocalKey) ?? '[]';
    List<dynamic> jsonMapList = json.decode(jsonStr);
    List<HistoryItem>? items = jsonMapList
        .map((item) => HistoryItem.fromJsonMap(item))
        .cast<HistoryItem>()
        .toList();
    return items;
  }

  static saveToDB(List<HistoryItem> items) {
    LocalStorage storage = getStorage();
    List? toJsonMapList =
        items.map((item) => item.toJSONEncodable()).cast<dynamic>().toList();
    String jsonStr = json.encode(toJsonMapList);
    storage.setItem(kUrlsLocalKey, jsonStr);
  }

  //获取记录json字符串
  static String exportJsonData() {
    List? toJsonMapList = getItems()
        .map((item) => item.toJSONEncodable())
        .cast<dynamic>()
        .toList();
    String jsonStr = json.encode(toJsonMapList);
    return jsonStr;
  }

  ///导入源 json格式: name, remark
  static importTextSource(String jsonStr) {
    print(jsonStr);
    List<HistoryItem> oldItems = getItems();
    List<dynamic> jsonMapList = json.decode(jsonStr);
    List<HistoryItem>? items = jsonMapList
        .map((item) => HistoryItem.fromJsonMap(item))
        .cast<HistoryItem>()
        .toList();
    oldItems.insertAll(0, items);
    saveToDB(oldItems);
  }

  //切换源之后 刷新频道列表 追加吧 没设计好
  static getSubscribeChannels(List<Channel> channels) {
    List<HistoryItem> oldItems = getItems();
    List<HistoryItem> items = channels.map((channel) {
      channel.logInfo();
      return HistoryItem(remark: channel.title!, url: channel.url!);
    }).toList();
    oldItems.insertAll(0, items);
    saveToDB(oldItems);
  }
}
