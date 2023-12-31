# live_tv_box

一个基于 flutter 开发的在线播放器的练手项目,旨在解决电脑上看电视的痛点

## 依赖库

主要是依赖`video_player`相关插件做的视频播放

```
  video_player: ^2.8.1
  video_player_web_hls: ^1.1.0
  video_player_web: ^2.1.2
```

1. 状态管理一开始就是直接用的 setState , 觉得太麻烦了就用上 Getx

2. web 端主要还是得依靠浏览器特性 `dart:html` 系统库就提供了许多功能 选择文件读取 以及 下载保存文件

3. json 和 model 互转 用的`dart:convert` 没有用到三方库

4. 本地存储用的`localstorage`

## 如何使用

找一些公开的 iptv 直播链接即可测试播放
比如:

```json
[
  {
    "url": "https://node1.olelive.com:6443/live/CCTV17HD/hls.m3u8",
    "remark": "CCTV17"
  },
  {
    "url": "https://node1.olelive.com:6443/live/CCTV7HD/hls.m3u8",
    "remark": "CCTV7"
  },
  {
    "url": "https://node1.olelive.com:6443/live/CCTV9HD/hls.m3u8",
    "remark": "CCTV9"
  },
  {
    "url": "https://node1.olelive.com:6443/live/CCTV5HD/hls.m3u8",
    "remark": "CCTV5"
  },
  {
    "url": "https://node1.olelive.com:6443/live/CCTV8HD/hls.m3u8",
    "remark": "CCTV8"
  },
  {
    "url": "https://node1.olelive.com:6443/live/CCTV1HD/hls.m3u8",
    "remark": "CCTV1"
  },
  {
    "url": "https://node1.olelive.com:6443/live/CCTV2HD/hls.m3u8",
    "remark": "CCTV2"
  },
  {
    "url": "https://node1.olelive.com:6443/live/CCTV10HD/hls.m3u8",
    "remark": "CCTV10"
  }
]
```

## 功能点

- 播放/暂停/全屏切换
- 添加/删除管理频道列表
- 添加/移除订阅源
- 导入/导出频道列表 json 配置

采用 github-pages 部署
存储基于浏览器本地 localstorage,需要共享可以导出配置在其他电脑上导入配置即可添加频道列表

添加 iptv 源 不能直接添加 github 的源 加个 cdn 转换

```
[X] https://github.com/WangGuibin/live_tv_box/blob/main/cctv.m3u

[√] https://cdn.jsdelivr.net/gh/WangGuibin/live_tv_box@main/cctv.m3u

```
