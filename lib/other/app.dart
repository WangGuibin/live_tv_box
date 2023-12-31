import 'package:get/get.dart';
import '../pages/channelList.dart';
import '../pages/live.dart';
import '../pages/sourceList.dart';
import '../bindings/sourceBindings.dart';

class App {
  //路由表
  static String root = '/';
  static String channelPage = '/channels';
  static String sourceList = '/sourceList';

  //路由和页面的关系
  static final routes = [
    GetPage(name: root, page: () => LivePage()),
    GetPage(name: channelPage, page: () => const ChannelList()),
    GetPage(
        name: sourceList,
        page: () => SourceList(),
        binding: SourceListBindings()),
  ];
}
