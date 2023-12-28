import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

///数据解析处理相关的头文件
import 'package:flutter/services.dart';
import 'dart:async'; //异步
import 'dart:convert'; //json转换
import "package:collection/collection.dart"; //集合操作 groupBy
import './live.dart';

class LiveModel {
  LiveModel();

  late String tvId;
  late String name;
  late String logo;
  late String groupTitle;
  late String url;

  logInfo() {
    print(
        "groupTitle: $groupTitle => id: $tvId => name:$name => logo: $logo => url: $url");
  }

  Map<String, dynamic> toJson() {
    return {
      'tvId': tvId,
      'name': name,
      'logo': logo,
      'groupTitle': groupTitle,
      'url': url
    };
  }
}

class ParseLiveSource {
  LiveModel parseRow(String row, String url) {
    LiveModel model = LiveModel();
    if (row.startsWith('#EXTINF:-1,') && url.isNotEmpty) {
      List<String> list = row.split(',')[1].split(' ');
      for (var element in list) {
        if (element.contains('=')) {
          List<String> items = element.split('=');
          String value = items[1].split('"')[1];
          if (element.contains('tvg-id')) {
            model.tvId = value;
          }

          if (element.contains('tvg-name')) {
            model.name = value;
          }

          if (element.contains('tvg-logo')) {
            model.logo = value;
          }

          if (element.contains('group-title')) {
            model.groupTitle = value;
          }
        }
      }
      model.url = url;
      return model;
    }

    model.tvId = '';
    model.groupTitle = '';
    model.logo = '';
    model.name = '';
    model.url = '';
    return model;
  }

  Future<String> loadLiveSource() async {
    return await rootBundle.loadString('assets/live.txt');
  }

  ///数据解析练习
  Future<Map<dynamic, List<Map<String, dynamic>>>> parse() async {
    List<Map<String, dynamic>> objList = [];
    List<String> jsonList = [];
    List<LiveModel> modelList = [];
    String allText = await loadLiveSource();
    List<String> all = allText.split('\r\n');
    List<String> list =
        all.where((element) => element.trim().isNotEmpty).toList();
    String row = '';
    String url = '';
    list.asMap().forEach((index, value) {
      if (index % 2 == 0) {
        row = value;
      } else {
        url = value;
        LiveModel model = parseRow(row, url);
        modelList.add(model);
        // model.logInfo();
        jsonList.add(jsonEncode(model.toJson()));
        objList.add(model.toJson());
      }
    });

    // print(jsonList);
    //分组
    var groupedMovies = groupBy(objList, (Map obj) => obj['groupTitle']);
    groupedMovies.remove('');
    print(jsonEncode(groupedMovies));
    return groupedMovies;
  }
}

mixin AppLocale {
  static const String title = 'title';
  static const String thisIs = 'thisIs';

  static const Map<String, dynamic> EN = {
    title: 'Localization',
    thisIs: 'This is %a package, version %a.',
  };
  static const Map<String, dynamic> KM = {
    title: 'ការធ្វើមូលដ្ឋានីយកម្ម',
    thisIs: 'នេះគឺជាកញ្ចប់%a កំណែ%a.',
  };
  static const Map<String, dynamic> JA = {
    title: 'ローカリゼーション',
    thisIs: 'これは%aパッケージ、バージョン%aです。',
  };
}

void main() {
  runApp(VideoApp());
}

class VideoApp extends StatefulWidget {
  const VideoApp({super.key});

  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  final FlutterLocalization _localization = FlutterLocalization.instance;

  @override
  void initState() {
    super.initState();

    // try {
    //   ParseLiveSource().parse().then((value) => {
    //         setState(() {
    //           dataSource = value;
    //         })
    //       });
    // } catch (e) {
    //   print(e);
    // }

    _localization.init(
      mapLocales: [
        const MapLocale(
          'en',
          AppLocale.EN,
          countryCode: 'US',
          fontFamily: 'Font EN',
        ),
        const MapLocale(
          'km',
          AppLocale.KM,
          countryCode: 'KH',
          fontFamily: 'Font KM',
        ),
        const MapLocale(
          'ja',
          AppLocale.JA,
          countryCode: 'JP',
          fontFamily: 'Font JA',
        ),
      ],
      initLanguageCode: 'en',
    );
    _localization.onTranslatedLanguage = _onTranslatedLanguage;
  }

  void _onTranslatedLanguage(Locale? locale) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      supportedLocales: _localization.supportedLocales,
      localizationsDelegates: _localization.localizationsDelegates,
      home: const LivePage(),
    );
  }
}
