class Channel {
  String? title;
  String? url;
  String? logo;

  void logInfo() {
    print('$title --- $url --- $logo');
  }
}

List<Channel> parseM3U8File(String m3u8Content) {
  List<Channel> channels = [];
  List<String> lines = m3u8Content.split('\n');
  if (lines.first == '#EXTM3U') {
    lines.removeAt(0);
  }
  Channel currentChannel = Channel();

  for (String line in lines) {
    if (line.contains('#EXTM3U')) {
      continue;
    }
    if (line.startsWith('#EXTINF:')) {
      currentChannel = Channel();
      currentChannel.title = line.split(',').last;
    } else if (line.isNotEmpty) {
      if (line.contains('m3u8')) {
        String result = line.substring(0, line.indexOf('.m3u8'));
        currentChannel.url = "$result.m3u8";
      }

      if (line.contains('tvg-logo')) {
        RegExp regex = RegExp(r'tvg-logo="([^"]+)"');
        RegExpMatch? match = regex.firstMatch(line);
        if (match != null) {
          currentChannel.logo = match.group(1)!;
        }
      }
      channels.add(currentChannel);
    }
  }

  return channels;
}
