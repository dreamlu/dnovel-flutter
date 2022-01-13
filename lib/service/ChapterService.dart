// 章节服务
import 'dart:convert';

import 'package:dnovel_flutter/models/Chapter.dart';
import 'package:dnovel_flutter/models/Detail.dart';
import 'package:dnovel_flutter/utils/request.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _chapterStore = "chapter_store";
List<Detail> list = []; // 缓存列表
List<Chapter> chapterList = []; // 章节列表
const int cacheNum = 6; // 缓存数量
const int cacheLeftNum = 4; // 缓存剩余数量时开启再次缓存

// 全局缓存服务
class ChapterService {
  String bookName;
  String source;
  String chapterUrl;
  String currentUrl; // 当前章节名称

  ChapterService(
    this.bookName,
    this.source,
    this.chapterUrl,
    this.currentUrl,
  );

  /// 存储当前章节以及后续几章
  /// service: 当前章节信息
  static Future cache(ChapterService service) async {
    if (chapterList.length == 0) {
      return;
    }

    // 判断是否需要缓存
    int oldIndex = list.indexWhere((e) => e.currentUrl == service.currentUrl);
    if (oldIndex <= list.length - cacheLeftNum) {
      return;
    }

    // 清除早期缓存
    if (oldIndex != -1) {
      for (int i = oldIndex - 4; i >= 0; i--) {
        list.removeAt(i);
      }
    }

    // 判断是否已经缓存
    // 不存在则缓存
    // 从下一章节开始缓存
    int index =
        chapterList.indexWhere((element) => element.url == service.chapterUrl);
    if (index == -1) {
      return;
    }
    for (int i = index + 1;
        i < chapterList.length && i < index + 1 + cacheNum;
        i++) {
      int index2 =
          list.indexWhere((element) => element.title == chapterList[i].name);
      if (index2 == -1) {
        list.add(await getChapter(chapterList[i].url, service.source));
      }
    }
    return;
  }

  /// 获得缓存内容
  static Future<Detail> getNextChapter(
      Detail detail, String url, String source, ChapterService service) async {
    if (detail.title == '') {
      cache(service);
      return await getChapter(url, source);
    } else {
      // 1.查找缓存
      int index = list.indexWhere((element) => element.currentUrl == url);
      if (index >= 0) {
        Detail res = list[index];
        cache(service);
        return res;
      } else {
        return getNextChapter(Detail(), url, source, service);
      }
    }
  }

  /// 在线请求章节内容
  static Future<Detail> getChapter(String url, String source) async {
    var result = await HttpUtils.getInstance()
        .get('/read?chapter_url=${Uri.encodeComponent(url)}&source=$source');
    DetailModel detailResult = DetailModel.fromJson(result.data);
    return detailResult.data;
  }

  /// 初始化
  static init(List<Chapter> ct) {
    list = [];
    chapterList = ct;
  }
}
