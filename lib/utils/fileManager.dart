import 'dart:html' as html;
import './historyTools.dart';

//当前时间戳(毫秒级)
int timeMilliseconds() {
  return DateTime.now().millisecondsSinceEpoch;
}

//浏览器模拟点击下载保存文本
void saveTextFile(String text, {String filename = ''}) {
  if (filename == '') {
    filename = '${timeMilliseconds()}.json';
  }
  html.AnchorElement(
      href: 'data:text/plain;charset=utf-8,${Uri.encodeComponent(text)}')
    ..setAttribute('download', filename)
    ..click();
}

void pickAndReadFile() {
  html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
  uploadInput.click();

  uploadInput.onChange.listen((e) {
    final files = uploadInput.files;
    if (files?.length == 1) {
      final file = files?[0];
      final reader = html.FileReader();

      reader.onLoadEnd.listen((e) {
        Object? data = reader.result;
        try {
          HistoryTools.importTextSource(data as String);
        } catch (e) {
          print(e);
        }
      });

      reader.onError.listen((fileEvent) {
        print("读取文件时发生错误");
      });

      reader.readAsText(file as html.Blob);
    }
  });
}
