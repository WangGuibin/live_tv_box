import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../controller/videoPlayController.dart';

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
                child: VideoPlayer(controller.videoController),
              ),
              controller.isDisplayPlayBtn.isTrue
                  ? IconButton(
                      onPressed: controller.togglePlay,
                      icon: Icon(controller.playBtnIconData.value),
                      iconSize: 60,
                      color: Colors.white,
                    )
                  : const Text(''),
              Positioned(
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
            ])),
      );
    });
  }
}
