import 'package:get/get.dart';
import '../pages/historyList.dart';
import '../pages/live.dart';
import '../pages/sourceList.dart';
import '../bindings/sourceBindings.dart';

class App {
  //路由表
  static String root = '/';
  static String historyList = '/history';
  static String sourceList = '/sourceList';

  //路由和页面的关系
  static final routes = [
    GetPage(name: root, page: () => LivePage()),
    GetPage(name: historyList, page: () => const HistoryList()),
    GetPage(
        name: sourceList,
        page: () => const SourceList(),
        binding: SourceListBindings()),
  ];
}
