import 'dart:convert';
import 'package:localstorage/localstorage.dart';
import 'package:dio/dio.dart';

const kSourceListLocalKey = 'source.list.key';
const kCurrentSourceLocalKey = 'current.source.key';

class SourceItem {
  final String iptvUrl;
  final String iptvText;

  SourceItem({required this.iptvUrl, required this.iptvText});

  toJSONEncodable() {
    Map<String, dynamic> item = {};
    item['iptvUrl'] = iptvUrl;
    item['iptvText'] = iptvText;
    return item;
  }

  static fromJsonMap(Map<String, dynamic> json) {
    return SourceItem(iptvUrl: json['iptvUrl'], iptvText: json['iptvText']);
  }
}

class SourceManager {
  static LocalStorage getStorage() {
    LocalStorage storage = LocalStorage('live_source.json');
    return storage;
  }

  static setCurrentSource(String url) {
    getStorage().setItem(kCurrentSourceLocalKey, url);
  }

  static getCurrentSource() {
    return getStorage().getItem(kCurrentSourceLocalKey);
  }

  //添加源
  static addSource(SourceItem source) {
    List<SourceItem> urls = getSourceList();
    if (urls.isNotEmpty) {
      //覆盖旧的
      urls =
          urls.where((element) => element.iptvUrl != source.iptvUrl).toList();
      urls.add(source);
    } else {
      urls.add(source);
    }

    List? toJsonMapList =
        urls.map((item) => item.toJSONEncodable()).cast<dynamic>().toList();
    String jsonStr = json.encode(toJsonMapList);
    getStorage().setItem(kSourceListLocalKey, jsonStr);
  }

  static saveSourceList(List sources) {
    if (sources.isEmpty) {
      getStorage().setItem(kSourceListLocalKey, '[]');
      return;
    }

    List? toJsonMapList =
        sources.map((item) => item.toJSONEncodable()).cast<dynamic>().toList();
    String jsonStr = json.encode(toJsonMapList);
    getStorage().setItem(kSourceListLocalKey, jsonStr);
  }

  static List<SourceItem> getSourceList() {
    String jsonStr = getStorage().getItem(kSourceListLocalKey) ?? '[]';
    List<dynamic> jsonMapList = json.decode(jsonStr);
    List<SourceItem>? items = jsonMapList
        .map((item) => SourceItem.fromJsonMap(item))
        .cast<SourceItem>()
        .toList();
    return items;
  }

  //订阅源
  static addSubscriSource(String url) async {
    Dio dio = Dio();
    try {
      dynamic res = await dio.get(url.trim());
      SourceManager.setCurrentSource(url);
      addSource(SourceItem(iptvUrl: url, iptvText: res.data));
    } catch (e) {
      print(e);
    }
  }
}
