import 'package:get/get.dart';
import '../pages/sourceList.dart';

class SourceListBindings extends Bindings {
  @override
  void dependencies() {
    // 注入依赖 懒加载
    Get.put<SourceListController>(SourceListController());
  }
}
