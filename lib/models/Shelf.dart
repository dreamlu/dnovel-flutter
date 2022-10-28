import 'dart:convert';

import 'package:dnovel_flutter/utils/request.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Shelf {
  String authorName;
  String bookName;
  String bookDesc;
  String bookCoverUrl;
  String recentChapterUrl;
  String recentChapterTitle;
  String lastUpdateAt;
  String source;
  String detailUrl;

  Shelf(
      {this.authorName = '',
      this.bookName = '',
      this.bookDesc = '',
      this.bookCoverUrl = '',
      this.recentChapterUrl = '',
      this.recentChapterTitle = '',
      this.lastUpdateAt = '',
      this.source = '',
      this.detailUrl = ''});

  factory Shelf.fromJson(Map<String, dynamic> json) {
    return Shelf(
      authorName: json['author_name'],
      bookName: json['book_name'],
      bookDesc: json['book_desc'],
      bookCoverUrl: json['book_cover_url'],
      recentChapterUrl: json['recent_chapter_url'],
      recentChapterTitle: json['recent_chapter_title'],
      lastUpdateAt: json['last_update_at'],
      source: json['source'],
      detailUrl: json['detail_url'],
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'author_name': authorName,
        'book_name': bookName,
        'book_desc': bookDesc,
        'recent_chapter_url': recentChapterUrl,
        'recent_chapter_title': recentChapterTitle,
        'source': source,
        "detail_url": detailUrl,
        "book_cover_url": bookCoverUrl,
      };

  static List<Shelf> toList(dynamic stringJson) {
    if (stringJson == null) {
      return [];
    }
    var map = jsonDecode(stringJson);
    List<Shelf> shelfList = [];
    map.forEach((e) {
      // todo 待移除,书架beqegecc图片403处理
      String cover = e['book_cover_url'];
      if (!cover.contains("/file?url")) {
        cover = HttpUtils.API_PREFIX + "/file?url=" + cover;
      }

      shelfList.add(Shelf(
        authorName: e['author_name'],
        bookName: e['book_name'],
        bookDesc: e['book_desc'],
        recentChapterUrl: e['recent_chapter_url'],
        recentChapterTitle: e['recent_chapter_title'] ?? '',
        source: e['source'],
        detailUrl: e['detail_url'],
        bookCoverUrl: cover,
      ));
    });
    return shelfList;
  }

  // 存在则返回对应书籍信息
  static Future<Shelf> isExist(String bookName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Shelf> list = toList(prefs.get("shelfList"));
    for (Shelf s in list) {
      if (s.bookName == bookName) {
        return s;
      }
    }
    return Shelf();
  }

  // 更新书架阅读的小说阅读的最近章节
  static Future upRecentChapterUrl(bookName, recentUrl, recentTitle) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Shelf> list = toList(prefs.get("shelfList"));
    for (int i = 0; i < list.length; i++) {
      var s = list[i];
      if (s.bookName == bookName) {
        s.recentChapterUrl = recentUrl;
        s.recentChapterTitle = recentTitle;
        list.removeAt(i);
        list.insert(i, s);
        prefs.setString("shelfList", jsonEncode(list));
        break;
      }
    }
  }
}
