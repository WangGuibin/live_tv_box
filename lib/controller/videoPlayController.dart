import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../utils/historyTools.dart';
import '../utils/sourceManager.dart';
import '../parser/parseM3u.dart';

class VideoPlayController extends GetxController {
  late VideoPlayerController videoController;
  RxBool isLoading = true.obs;
  RxBool isFullScreen = false.obs;
  RxBool isDisplayPlayBtn = false.obs;
  RxBool isHover = false.obs;
  RxBool enableFullScreen = false.obs;
  RxString currenPlayUrl =
      'https://node1.olelive.com:6443/live/CCTV1HD/hls.m3u8'.obs;
  RxString currenPlayName = 'CCTV1HD'.obs;
  var playBtnIconData = Icons.play_arrow.obs;

  @override
  void onInit() {
    isLoading.value = true;
    //提前初始化一下
    HistoryTools.getItems();
    List sources = SourceManager.getSourceList();
    if (sources.isEmpty) {
      //默认添加一下内置源
      SourceManager.addSubscriSource(
          'https://cdn.jsdelivr.net/gh/WangGuibin/live_tv_box@main/cctv.m3u');
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
      videoController =
          VideoPlayerController.networkUrl(Uri.parse(currenPlayUrl.value))
            ..initialize().then((_) {
              isLoading.value = false;
              update();
            });
      enableFullScreen.value = false;
      isDisplayPlayBtn.value = true;
    } catch (e) {
      print(e);
    }
    super.onInit();
  }

  bool isPlaying() {
    return videoController.value.isPlaying;
  }

  //单击屏幕
  void tapScreen() {
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
    update();

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
      currenPlayName.value = remark ?? '在线播放器';
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
