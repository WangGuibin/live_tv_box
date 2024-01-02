import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../utils/historyTools.dart';
import '../utils/sourceManager.dart';
import '../parser/parseM3u.dart';

const defaultConfigs = [
  "https://cdn.jsdelivr.net/gh/WangGuibin/live_tv_box@main/cctv.m3u",
  "https://cdn.jsdelivr.net/gh/hujingguang/ChinaIPTV@main/cnTV_AutoUpdate.m3u8",
  "https://cdn.jsdelivr.net/gh/TCatCloud/IPTV@Files/IPTV.m3u",
  "https://cdn.jsdelivr.net/gh/richelsky/IPTV@main/%E5%9B%BD%E5%86%85%E7%94%B5%E8%A7%86%E5%8F%B02023.12KodiCN.txt",
  "https://cdn.jsdelivr.net/gh/richelsky/IPTV@main/moyulive.txt",
  "https://cdn.jsdelivr.net/gh/shidahuilang/shuyuan@shuyuan/iptv.txt",
  "https://cdn.jsdelivr.net/gh/LITUATUI/M3UPT@main/M3U/M3UPT.m3u",
];

class VideoPlayController extends GetxController {
  late VideoPlayerController videoController;
  final RxBool _isMute = false.obs;
  RxBool isLoading = true.obs;
  RxBool isFullScreen = false.obs;
  RxBool isDisplayPlayBtn = false.obs;
  RxBool isHover = false.obs;
  RxBool enableFullScreen = false.obs;
  RxInt currentSeconds = 0.obs;
  RxInt allSeconds = 0.obs;
  RxBool showControls = true.obs;
  RxBool showProgress = false.obs;

  RxString currenPlayUrl =
      'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8'.obs;
  RxString currenPlayName = '大白熊(测试)'.obs;
  var playBtnIconData = Icons.play_arrow.obs;

  set isMute(bool val) {
    _isMute.value = val;
    videoController.setVolume(val ? 0.0 : 1.0);
  }

  bool get isMute => _isMute.value;

  void toggleMute() {
    isMute = !isMute;
  }

  @override
  void onInit() {
    isLoading.value = true;
    //提前初始化一下
    HistoryTools.getItems();
    List sources = SourceManager.getSourceList();
    if (sources.isEmpty) {
      //默认添加一下内置源
      SourceManager.addSubscriSource(defaultConfigs);
    }

    if (SourceManager.getCurrentSource() != '' &&
        SourceManager.getCurrentSource() != null) {
      SourceItem ipTextItem = SourceManager.getSourceList()
          .where(
              (element) => element.iptvUrl == SourceManager.getCurrentSource())
          .toList()
          .first;
      List<Channel> channels = parseM3U8File(ipTextItem);
      HistoryTools.getSubscribeChannels(channels);
    }

    update();
    try {
      videoController = VideoPlayerController.networkUrl(
        Uri.parse(currenPlayUrl.value),
      )..initialize().then((_) {
          isLoading.value = false;
          update();
        });
      videoController.play();
      _addListener();
      enableFullScreen.value = false;
      isDisplayPlayBtn.value = false;
    } catch (e) {
      print(e);
    }
    super.onInit();
  }

  ///添加监听
  _addListener() {
//监听播放进度
    videoController.addListener(() {
      final Duration position = videoController.value.position;
      List<DurationRange> buffered = videoController.value.buffered;
      showProgress.value = buffered.isNotEmpty;
      if (buffered.isNotEmpty) {
        DurationRange range = buffered.first;
        // print('$position /  ${range.end}');
        currentSeconds.value = position.inSeconds;
        allSeconds.value = range.end.inSeconds;
        showProgress.value = true;
      } else {
        currentSeconds.value = 0;
        allSeconds.value = 0;
      }
      update();
    });
  }

  bool isPlaying() {
    return videoController.value.isPlaying;
  }

  //单击屏幕
  void tapScreen() {
    showControls.value = !showControls.value;
    update();

    if (isPlaying()) return;
    isDisplayPlayBtn.value = true;
    update();
    hiddenPlayBtn();
  }

  //切换全屏
  void toggleFullScreen() {
    if (enableFullScreen.isTrue) {
      enableFullScreen.value = false;
    } else {
      enableFullScreen.value = true;
    }
    if (enableFullScreen.isTrue) {
      _goFullScreen();
    } else {
      _exitFullScreen();
    }
    showControls.value = true;
    tapScreen();
    update();
  }

  void _goFullScreen() {
    html.document.documentElement?.requestFullscreen();
  }

  void _exitFullScreen() {
    html.document.exitFullscreen();
  }

  // 切换播放
  void togglePlay() {
    isPlaying() ? videoController.pause() : videoController.play();
    isDisplayPlayBtn.value = true;
    playBtnIconData.value = isPlaying() ? Icons.pause : Icons.play_arrow;
    update();

    /// 如果2秒后是播放状态则隐藏播放按钮
    hiddenPlayBtn();
  }

  void hiddenPlayBtn() {
    Future.delayed(const Duration(seconds: 2), () {
      if (isPlaying()) {
        isDisplayPlayBtn.value = false;
        isHover.value = false;
        update();
      }
    });
  }

  //播放新的url
  void playNewUrl(String url, {String remark = ''}) {
    print('正在播放 $url');
    videoController.pause();
    videoController.dispose();
    isLoading.value = true;

    ///fix
    if (url.contains('m3u8')) {
      String result = url.substring(0, url.indexOf('.m3u8'));
      url = "$result.m3u8";
    }

    try {
      videoController = VideoPlayerController.networkUrl(Uri.parse(url))
        ..initialize().then((_) {
          isLoading.value = false;
          update();
        });
      enableFullScreen.value = false;
      isDisplayPlayBtn.value = false;
      currenPlayUrl.value = url;
      currenPlayName.value = remark;
      videoController.play();

      List<ChannelItem> items = HistoryTools.getItems();
      if (items.isEmpty) {
        items.insert(0, ChannelItem(remark: remark, url: url));
        HistoryTools.saveToDB(items);
        return;
      }

      var newItems = items.where((element) => element.url != url).toList();
      newItems.insert(0, ChannelItem(remark: remark, url: url));
      HistoryTools.saveToDB(newItems);
      _addListener();
      update();
    } catch (e) {
      print(e);
    }
  }

  @override
  void onClose() {
    videoController.dispose();
    super.onClose();
  }
}
