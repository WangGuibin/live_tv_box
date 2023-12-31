import 'package:get/get.dart';
import '../controller/videoPlayController.dart';

class GlobalBindings extends Bindings {
  @override
  void dependencies() {
    // 注入依赖 懒加载
    Get.lazyPut<VideoPlayController>(() => VideoPlayController());
  }
}
