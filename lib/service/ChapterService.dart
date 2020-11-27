// 章节服务
import 'dart:convert';

import 'package:dnovel_flutter/models/Chapter.dart';
import 'package:dnovel_flutter/models/Detail.dart';
import 'package:dnovel_flutter/utils/request.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _chapterStore = "chapter_store";
List<Detail> list = [];

// 全局缓存服务
class ChapterService {
  String bookName;
  String source;
  String chapterUrl;
  String title; // 当前章节名称

  ChapterService(
    this.bookName,
    this.source,
    this.chapterUrl,
    this.title,
  );

  /// 存储当前章节以及后续几章
  /// service: 当前章节信息
  /// _chapter: 所有章节列表
  static Future cache(
      ChapterService service, List<Chapter> _chapterList) async {
    // 1.清除早期缓存
    int oldIndex = list.indexWhere((element) => element.title == service.title);
    if (oldIndex != -1) {
      for (int i = oldIndex; i >= 0; i--) {
        try {
          list.removeAt(i);
        } catch (e) {}
      }
    }

    // 2.判断是否已经缓存
    // 不存在则缓存
    // 从下一章节开始缓存
    int index =
        _chapterList.indexWhere((element) => element.url == service.chapterUrl);
    if (index == -1) {
      return;
    }
    for (int i = index + 1; i < _chapterList.length && i < index + 1 + 4; i++) {
      int index2 = list
          .indexWhere((element) => element.title == _chapterList[index].name);
      if (index2 == -1) {
        try {
          var result = await HttpUtils.getInstance().get(
              '/read?chapter_url=${Uri.encodeComponent(_chapterList[i].url)}&source=${service.source}');
          DetailModel detailResult = DetailModel.fromJson(result.data);
          list.add(detailResult.data);
        } catch (e) {
          print("章节缓存请求问题: " + e);
        }
      }
    }
    return;
  }

  /// 获得缓存内容
  static Future<Detail> getNextChapter (
      Detail detail, String url, String source) async {
    if (detail == null) {
      var result = await HttpUtils.getInstance()
          .get('/read?chapter_url=${Uri.encodeComponent(url)}&source=$source');
      DetailModel detailResult = DetailModel.fromJson(result.data);
      return detailResult.data;
    } else {
      // 1.查找缓存
      int index = list.indexWhere((element) => element.currentUrl == url);
      if (index >= 0) {
        return list[index];
      } else {
        return getNextChapter(null, url, source);
      }
    }
  }

  /// 释放
  static init() {
    list = [];
  }
}
