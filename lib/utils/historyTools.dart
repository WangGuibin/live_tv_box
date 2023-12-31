import 'dart:convert';
import 'package:localstorage/localstorage.dart';
import '../parser/parseM3u.dart';

const kUrlsLocalKey = 'urls.local.abc.key';

class ChannelItem {
  final String remark;
  final String url;
  ChannelItem({required this.remark, required this.url});

  toJSONEncodable() {
    Map<String, dynamic> item = {};
    item['url'] = url;
    item['remark'] = remark;
    return item;
  }

  static fromJsonMap(Map<String, dynamic> json) {
    return ChannelItem(remark: json['remark'], url: json['url']);
  }
}

class HistoryTools {
  static LocalStorage getStorage() {
    LocalStorage storage = LocalStorage('live_urls.json');
    return storage;
  }

  static List<ChannelItem> getItems() {
    String jsonStr = getStorage().getItem(kUrlsLocalKey) ?? '[]';
    List<dynamic> jsonMapList = json.decode(jsonStr);
    List<ChannelItem>? items = jsonMapList
        .map((item) => ChannelItem.fromJsonMap(item))
        .cast<ChannelItem>()
        .toList();
    //去重
    final urls = <String>{};
    items.retainWhere((item) => urls.add(item.url));
    return items;
  }

  static saveToDB(List<ChannelItem> items) {
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
    List<ChannelItem> oldItems = getItems();
    List<dynamic> jsonMapList = json.decode(jsonStr);
    List<ChannelItem>? items = jsonMapList
        .map((item) => ChannelItem.fromJsonMap(item))
        .cast<ChannelItem>()
        .toList();
    oldItems.insertAll(0, items);
    saveToDB(oldItems);
  }

  //切换源之后 刷新频道列表 追加吧 没设计好
  static getSubscribeChannels(List<Channel> channels) {
    List<ChannelItem> oldItems = getItems();
    List<ChannelItem> items = channels.map((channel) {
      channel.logInfo();
      return ChannelItem(remark: channel.title!, url: channel.url!);
    }).toList();
    //url一样的剔除掉
    oldItems.removeWhere(
        (element) => items.map((e) => e.url).toList().contains(element.url));
    oldItems.insertAll(0, items);
    saveToDB(oldItems);
  }
}
