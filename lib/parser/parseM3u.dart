import '../utils/sourceManager.dart';

class Channel {
  String? title;
  String? url;

  void logInfo() {
    print('$title --- $url');
  }
}

List<Channel> parseM3U8File(SourceItem source) {
  List<String> lines = source.iptvText.split('\n');
  //剔除空行
  lines = lines.where((element) => element.trim().isNotEmpty).toList();

  if (source.iptvUrl.endsWith('.m3u') || source.iptvUrl.endsWith('.m3u8')) {
    return parseM3uFormat(lines);
  } else {
    return parseTxtFormat(lines);
  }
}

//解析m3u
List<Channel> parseM3uFormat(List<String> lines) {
  List<Channel> channels = [];
  if (lines.first.contains('#EXTM3U')) {
    lines.removeAt(0);
  }
  lines = lines
      .where((element) =>
          element.contains('#EXTINF:') || element.startsWith('http'))
      .toList();
  Channel currentChannel = Channel();

  for (String line in lines) {
    if (line.contains('#EXTM3U')) {
      continue;
    }
    if (line.trim().isEmpty) {
      continue;
    }

    if (line.startsWith('#EXTINF:')) {
      currentChannel = Channel();
      currentChannel.title = line.split(',').last;
    } else if (line.isNotEmpty) {
      if (line.contains('m3u8')) {
        String result = line.substring(0, line.indexOf('.m3u8'));
        currentChannel.url = "$result.m3u8";
        channels.add(currentChannel);
        currentChannel.logInfo();
      }
    }
  }

  return channels;
}

//解析txt
List<Channel> parseTxtFormat(List<String> lines) {
  List<Channel> channels = [];
  lines = lines.where((element) => element.contains('http')).toList();
  for (String line in lines) {
    List<String> arr = line.split(',');
    String title = arr.first;
    String url = arr.last;
    if (url.startsWith('http')) {
      Channel channel = Channel();
      channel.title = title;
      channel.url = url;
      channels.add(channel);
      channel.logInfo();
    }
  }
  return channels;
}
