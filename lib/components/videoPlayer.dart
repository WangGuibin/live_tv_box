import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../controller/videoPlayController.dart';
import '../utils/timeFormat.dart';

class MyVideoPlayer extends GetView<VideoPlayController> {
  const MyVideoPlayer({super.key});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final aspectRatio = controller.videoController.value.aspectRatio;
      return GestureDetector(
        onTap: controller.tapScreen,
        onDoubleTap: controller.togglePlay,
        child: Container(
            width: controller.enableFullScreen.isTrue
                ? MediaQuery.of(context).size.width
                : 480.0,
            height: controller.enableFullScreen.isTrue
                ? MediaQuery.of(context).size.height
                : 480.0 * aspectRatio,
            color: Colors.black,
            child: Stack(alignment: Alignment.center, children: [
              AspectRatio(
                  aspectRatio: aspectRatio,
                  child: IgnorePointer(
                    ignoring: true, //让事件进行冒泡 不然点击视频上不响应手势 全屏都召唤不出controls
                    child: VideoPlayer(controller.videoController),
                  )),
              controller.isDisplayPlayBtn.isTrue
                  ? IconButton(
                      onPressed: controller.togglePlay,
                      icon: Icon(controller.playBtnIconData.value),
                      iconSize: 60,
                      color: Colors.white,
                    )
                  : const Text(''),
              controller.showProgress.isTrue
                  ? Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: controller.showControls.isTrue
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Slider(
                                  activeColor: Colors.lightBlue,
                                  thumbColor: Colors.grey,
                                  value: controller.currentSeconds.toDouble(),
                                  min: 0.0,
                                  max: max(controller.currentSeconds.toDouble(),
                                      controller.allSeconds.toDouble()),
                                  onChanged: (double value) {
                                    controller.videoController.seekTo(
                                        Duration(seconds: value.toInt()));
                                  },
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, bottom: 20),
                                    child: Text(
                                      controller.currentSeconds.value >
                                              controller.allSeconds.value
                                          ? formatDuration(
                                              controller.currentSeconds.value)
                                          : '${formatDuration(controller.currentSeconds.value)}/${formatDuration(controller.allSeconds.value)}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal),
                                    )),
                              ],
                            )
                          : const SizedBox())
                  : const SizedBox(),
              controller.showControls.isTrue
                  ? const Positioned(
                      top: 20,
                      left: 20,
                      child: Text('· live',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold)))
                  : const SizedBox(),
              controller.showControls.isTrue
                  ? Positioned(
                      bottom: 10,
                      right: 10,
                      child: MouseRegion(
                          onEnter: (PointerEvent details) =>
                              {controller.isHover.value = true},
                          onExit: (PointerEvent details) => {
                                Future.delayed(const Duration(seconds: 5), () {
                                  if (controller.isPlaying()) {
                                    controller.isHover.value = false;
                                  }
                                })
                              },
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: IconButton(
                                tooltip: controller.enableFullScreen.isTrue
                                    ? '退出全屏'
                                    : '全屏',
                                hoverColor: Colors.white54,
                                onPressed: controller.toggleFullScreen,
                                icon: Icon(
                                  controller.enableFullScreen.isTrue
                                      ? Icons.fullscreen_exit
                                      : Icons.fullscreen,
                                  color: controller.isHover.isTrue
                                      ? Colors.white
                                      : Colors.white54,
                                )),
                          )),
                    )
                  : const SizedBox(),
              controller.showControls.isTrue
                  ? Positioned(
                      top: 10,
                      right: 10,
                      child: IconButton(
                          tooltip: controller.isMute ? '打开声音' : '静音',
                          onPressed: controller.toggleMute,
                          icon: Icon(
                              controller.isMute
                                  ? Icons.music_off_outlined
                                  : Icons.music_note_outlined,
                              color: Colors.white)),
                    )
                  : const SizedBox(),
            ])),
      );
    });
  }
}
