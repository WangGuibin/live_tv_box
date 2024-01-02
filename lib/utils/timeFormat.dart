// 将秒数转换为时分秒的格式化字符串
String formatDuration(int sec) {
  // 创建一个 Duration 对象
  Duration duration = Duration(seconds: sec);
  // 获取小时、分钟和秒数
  int hours = duration.inHours;
  int minutes = duration.inMinutes.remainder(60);
  int seconds = duration.inSeconds.remainder(60);
  // 格式化字符串
  String formattedTime =
      '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  // 返回格式化后的字符串
  return formattedTime;
}
