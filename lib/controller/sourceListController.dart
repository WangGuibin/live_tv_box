import 'package:get/get.dart';
import '../utils/sourceManager.dart';

class SourceListController extends GetxController {
  final RxList _items = [].obs;
  final RxString _selectSource = ''.obs;
  late SourceManager manager;

  get selectSource {
    return _selectSource.value;
  }

  set selectSource(val) {
    _selectSource.value = val;
    SourceManager.setCurrentSource(val);
    update();
  }

  List get items => _items.value;

  set items(val) {
    _items.value = val;
    update();
  }

  @override
  void onInit() {
    selectSource = SourceManager.getCurrentSource() ?? '';
    items = SourceManager.getSourceList();
    update();
    super.onInit();
  }
}
