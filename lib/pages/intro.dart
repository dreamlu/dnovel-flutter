import 'package:dnovel_flutter/models/Shelf.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import './read.dart';
import '../models/Intro.dart';
import '../utils/color.dart';
import '../utils/request.dart';
import '../components/NovelItem.dart';
import '../components/LoadingView.dart';

class IntroPage extends StatefulWidget {
  final String url;
  final String source;

  IntroPage({this.url, this.source});

  @override
  State createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  Intro _intro;
  int isShelf = 0; // 是否在书架

  @override
  void initState() {
    _fetchIntroInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_intro == null) {
      content = Center(child: LoadingView());
    } else {
      content = ListView(
        children: <Widget>[
          _buildBookAndAuthor(),
          _buildTimeAndClassify(),
          _buildBookDesc(),
        ],
      );
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        color: MyColor.bgColor,
        child: content,
      ),
      bottomSheet: _intro != null ? _buildBottomSheet() : null,
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: MyColor.bgColor,
      brightness: Brightness.light,
      elevation: 0,
      title: Text('详情页', style: TextStyle(color: MyColor.appBarTitle)),
      leading: IconButton(
        icon: Icon(Icons.chevron_left),
        color: MyColor.iconColor,
        iconSize: 32,
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildBottomSheet() {
    if (isShelf != 0) {
      return Row(
        children: <Widget>[
          GestureDetector(
            child: Container(
              child: Text(
                '去阅读',
                style: TextStyle(color: Colors.white),
              ),
              height: 48.0,
              width: MediaQuery.of(context).size.width / 2,
              decoration: BoxDecoration(
                color: Colors.blue,
                border: Border(top: BorderSide(color: Colors.black26)),
              ),
              alignment: Alignment.center,
            ),
            onTap: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReadPage(
                    url: _intro.recentChapterUrl,
                    detailUrl: widget.url,
                    bookName: _intro.bookName,
                    source: widget.source,
                  ),
                ),
              );
            },
          ),
          Container(
            child: Text('在书架'),
            height: 48.0,
            width: MediaQuery.of(context).size.width / 2,
            alignment: Alignment.center,
          ),
        ],
      );
    }

    return Row(
      children: <Widget>[
        GestureDetector(
          child: Container(
            child: Text('试读'),
            height: 48.0,
            width: MediaQuery.of(context).size.width / 2,
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.black26)),
            ),
            alignment: Alignment.center,
          ),
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReadPage(
                  url: _intro.recentChapterUrl,
                  detailUrl: widget.url,
                  bookName: _intro.bookName,
                  fromPage: 'IntroPage',
                  source: widget.source,
                ),
              ),
            );
            if (result == 'join') {
              // _postShelf();
            }
          },
        ),
        GestureDetector(
          child: Container(
            child: Text('加入书架', style: TextStyle(color: Colors.white)),
            height: 48.0,
            width: MediaQuery.of(context).size.width / 2,
            alignment: Alignment.center,
            color: Colors.blue,
          ),
          onTap: () async {
            final result = await _postShelf();
            // 跳转到首页
            if (result == true) {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/shelf', (Route<dynamic> route) => false);
            }
          },
        ),
      ],
    );
  }

  /* 第一行：小说名称和作者名称 */
  Widget _buildBookAndAuthor() {
    return Container(
      height: 180.0,
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: NovelItem(
        authorName: _intro.authorName,
        bookName: _intro.bookName,
        cover: _intro.cover,
      ),
    );
  }

  /* 第二行：更新时间和分类 */
  Widget _buildTimeAndClassify() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(20.0),
      child: ListView(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        shrinkWrap: true,
        children: <Widget>[
          Text(
            '最新章节：' + _intro.lastUpdateAt,
            overflow: TextOverflow.ellipsis, // 省略号
            // softWrap: true, // 换行,最大几行
            // maxLines: 2,
          ),
          Text(
            '分类：' + _intro.classifyName,
          )
        ],
      ),
    );
  }

  /* 第三行：小说简介 */
  Widget _buildBookDesc() {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 10.0),
      padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Text('简介', style: TextStyle(fontSize: 18.0)),
          ),
          Html(data: _intro.bookDesc),
        ],
      ),
    );
  }

  _fetchIntroInfo() async {
    try {
      var result = await HttpUtils.getInstance().get(
          '/info?detail_url=${Uri.encodeComponent(widget.url)}&source=${widget.source}');
      IntroModel introResult = IntroModel.fromJson(result.data);
      _intro = introResult.data;

      // 初始化时判断是否在书架
      // 将书架阅读的最近url覆盖
      Shelf shelf = await Shelf.isExist(introResult.data.bookName);
      if (shelf != null) {
        isShelf = 1;
        _intro.recentChapterUrl = shelf.recentChapterUrl;
      }
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  /* 加入书架 */
  Future<bool> _postShelf() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Shelf> list = Shelf.toList(prefs.get("shelfList"));

    try {
      if (!isExist(list)) {
        // 书籍不存在，加入书架
        list.insert(0, newShelf());
        prefs.setString('shelfList', jsonEncode(list));
        return true;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  bool isExist(List<Shelf> list) {
    for (Shelf shelf in list) {
      if (shelf.bookName == _intro.bookName) {
        return true;
      }
    }
    return false;
  }

  Shelf newShelf() {
    return new Shelf(
      authorName: _intro.authorName,
      bookName: _intro.bookName,
      bookDesc: _intro.bookDesc,
      recentChapterUrl: _intro.recentChapterUrl,
      source: _intro.source,
      detailUrl: widget.url,
      bookCoverUrl: _intro.cover,
    );
  }
}
