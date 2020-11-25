import 'package:dnovel_flutter/models/Shelf.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/Detail.dart';
import '../models/Chapter.dart';
import '../utils/request.dart';
import '../utils/DialogUtils.dart';
import '../components/LoadingView.dart';
import '../components/ChapterDrawer.dart';

Map bgColors = {
  'daytime': Colors.white24, // 白天
  'night': Colors.black45, // 黑夜
  'parchment': Color.fromRGBO(242, 235, 217, 1), // 羊皮纸
  'my_love': Color.fromRGBO(196, 179, 149, 0.5), // 护眼
};

class ReadPage extends StatefulWidget {
  final int shelfId;
  final String url; // 章节url
  final String detailUrl; // 书本url
  final String source;
  final String bookName;
  final String fromPage;

  ReadPage({
    this.shelfId,
    this.url,
    this.detailUrl,
    this.source,
    this.bookName,
    this.fromPage = '',
  });

  @override
  State createState() => _ReadPageState();
}

// 沉浸式页面
class _ReadPageState extends State<ReadPage> {
  List<Chapter> _chapterList = [];
  Detail _detail; // 小说内容：标题、内容、上一章url、下一章url

  // 阅读设置
  double _fontSize = 20.0; // 字体
  String _bgColor = 'mylove'; // 背景颜色
  bool _whetherNight = false; // 是否是黑夜
  ScrollController _controller; // 滚动条对象

  @override
  void initState() {
    _fetchDetail(widget.url);
    _fetchChapterList(widget.detailUrl, widget.source);
    _initData();
    super.initState();
  }

  @override
  void deactivate() {
    if (widget.shelfId != null) {
      _saveData();
    }
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (_detail == null) {
      content = Expanded(child: LoadingView());
    } else {
      content = _buildBody();
    }

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      // statusBarColor: Colors.transparent, // 透明
      statusBarIconBrightness: Brightness.light,
    ));

    return WillPopScope(
      child: SafeArea(
        child: Scaffold(
          body: _buildColorContent(content),
          drawer: ChapterDrawer(
            bookName: widget.bookName,
            title: _detail != null ? _detail.title : '',
            chapterList: _chapterList,
            onTap: (String url) {
              _fetchDetail(url);
            },
          ),
        ),
      ),
      onWillPop: () {
        if (widget.fromPage == 'ShelfPage') {
          Navigator.pushNamedAndRemoveUntil(
              context, '/shelf', (Route<dynamic> route) => false); // 相当于刷新书架
        } else {
          Navigator.pop(context); // 返回上一级
        }
        return;
      },
    );
  }

  // 构建带颜色的阅读页
  Widget _buildColorContent(content) {
    if (_bgColor == "my_love") {
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/images/read_background.jpg'),
            fit: BoxFit.cover, // 全屏
          ),
        ),
        // color: bgColors[_bgColor],
        child: Column(
          children: <Widget>[
            SizedBox(height: 15),
            _buildHeader(),
            content,
            _buildFooter(),
          ],
        ),
      );
    }

    return Container(
      color: bgColors[_bgColor],
      child: Column(
        children: <Widget>[
          SizedBox(height: 15),
          _buildHeader(),
          content,
          _buildFooter(),
        ],
      ),
    );
  }

  void _showJoinBottomSheet() async {
    // 从小说详情页面进入的阅读页面，当返回上一页面时
    // 弹出对话框询问是否加入书架
    var result = await showModalBottomSheet(
      context: context,
      builder: (ctx) => _buildJoinShelfBottomSheet(ctx),
      backgroundColor: Colors.transparent,
    );
    Navigator.pop(context, result);
  }

  Widget _buildHeader() {
    return Container(
      margin: EdgeInsets.only(bottom: 10.0),
      // decoration: BoxDecoration(
      //   border: Border(bottom: BorderSide(color: Colors.black26)),
      // ),
      alignment: Alignment.center,
      height: 20.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            child: Icon(Icons.chevron_left),
            onTap: () {
              // if (widget.fromPage == 'ShelfPage') {
              //   Navigator.pushNamedAndRemoveUntil(
              //       context, '/shelf', (Route<dynamic> route) => false);
              // } else {
              //   _showJoinBottomSheet();
              // }
              Navigator.pop(context);
            },
          ),
          Text(_detail != null ? _detail.title : ''),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Expanded(
      child: Builder(
        builder: (ctx) => GestureDetector(
          child: ListView(
            controller: _controller,
            children: <Widget>[
              Html(
                data: "<font>" + _detail.content + "</font>",
                style: {
                  "html": Style(
                    fontSize: FontSize(_fontSize),
                    letterSpacing: 0.2,
                  ),
                  "font": Style( // 添加一个标签防止content中没有<p>来进行行高设置
                    lineHeight: 1.3,
                  ),
                  "p": Style(
                    lineHeight: 1.3,
                  ),
                },
              ),
            ],
          ),
          onTap: () {
            showModalBottomSheet(
              context: ctx,
              builder: (ctx2) => _buildMenuBottomSheet(ctx),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      height: 40,
      margin: EdgeInsets.only(top: 10.0),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black26)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          FlatButton(
            child: Text('上一章', style: TextStyle(color: Colors.black54)),
            onPressed: () {
              if (_detail.prevUrl == null ||
                  _detail.prevUrl == '' ||
                  _detail.prevUrl.contains('.html') == false) {
                DialogUtils.showToastDialog(context, text: '当前是第一章了哦~');
                return;
              }
              _fetchDetail(_detail.prevUrl, post: () {
                _controller = new ScrollController(initialScrollOffset: 0.0);
              });
            },
          ),
          FlatButton(
            child: Text('下一章', style: TextStyle(color: Colors.black54)),
            onPressed: () {
              if (_detail.nextUrl == null ||
                  _detail.nextUrl == '' ||
                  _detail.nextUrl.contains('.html') == false) {
                DialogUtils.showToastDialog(context, text: '已经是最新章节了哦~');
                return;
              }
              _fetchDetail(_detail.nextUrl, post: () {
                _controller = new ScrollController(initialScrollOffset: 0.0);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuBottomSheet(BuildContext ctx) {
    return Container(
      height: 90,
      padding: EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          MenuItem(
            children: <Widget>[
              Icon(Icons.import_contacts),
              Text('目录'),
            ],
            onTap: () {
              Navigator.pop(context);
              Scaffold.of(ctx).openDrawer();
            },
          ),
          MenuItem(
            children: <Widget>[
              Icon(Icons.settings),
              Text('设置'),
            ],
            onTap: () async {
              Navigator.pop(context);
              await showModalBottomSheet(
                  context: context,
                  builder: (ctx2) => _buildSettingsBottomSheet());

              // 将字体大小、背景颜色保存到本地缓存中
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setDouble('fontSize', _fontSize);
              prefs.setString('bgColor', _bgColor);
            },
          ),
          MenuItem(
            children: <Widget>[
              Icon(_whetherNight == true
                  ? Icons.brightness_7
                  : Icons.brightness_2),
              Text(_whetherNight == true ? '白天' : '黑夜'),
            ],
            onTap: () {
              setState(() {
                _bgColor = _whetherNight ? 'daytime' : 'night';
                _whetherNight = !_whetherNight;
              });
            },
          )
        ],
      ),
    );
  }

  Widget _buildSettingsBottomSheet() {
    return Container(
      height: 150.0,
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                '字体',
                style: TextStyle(fontSize: 24.0),
              ),
              IconButton(
                icon: Icon(
                  Icons.add,
                  size: 30,
                ),
                onPressed: () {
                  setState(() {
                    _fontSize += 2;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.minimize,
                  size: 30,
                ),
                onPressed: () {
                  setState(() {
                    _fontSize -= 2;
                  });
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              BgColorItem(
                color: bgColors['daytime'],
                onTap: () {
                  setState(() {
                    _bgColor = 'daytime';
                  });
                },
              ),
              BgColorItem(
                color: bgColors['night'],
                onTap: () {
                  setState(() {
                    _bgColor = 'night';
                  });
                },
              ),
              BgColorItem(
                color: bgColors['parchment'],
                onTap: () {
                  setState(() {
                    _bgColor = 'parchment';
                  });
                },
              ),
              BgColorItem(
                color: bgColors['my_love'],
                onTap: () {
                  setState(() {
                    _bgColor = 'my_love';
                  });
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildJoinShelfBottomSheet(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              child: Text(
                '提示',
                style: TextStyle(fontSize: 20.0),
              ),
              padding: EdgeInsets.only(left: 20.0, top: 10),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                '加入书架，下次找书更方便',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            flex: 2,
          ),
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    child: Container(
                      alignment: Alignment.center,
                      color: Colors.blueAccent,
                      child: Text(
                        '加入书架',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    onTap: () {
                      // 加入书架
                      Navigator.pop(context, 'join');
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    child: Container(
                      alignment: Alignment.center,
                      color: Colors.transparent,
                      child: Text('取消'),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _fetchDetail(String url, {Function post}) async {
    setState(() {
      _detail = null;
    });

    try {
      var result = await HttpUtils.getInstance().get(
          '/read?chapter_url=${Uri.encodeComponent(url)}&source=${widget.source}');
      DetailModel detailResult = DetailModel.fromJson(result.data);

      setState(() {
        _detail = detailResult.data;
      });

      // 异步存储当前书架书籍阅读进度
      // 提前传递过来判断是否书架更好
      Shelf.upRecentChapterUrl(widget.bookName, url);

      if (post != null) {
        post();
      }
    } catch (e) {
      print(e);
    }
  }

  _fetchChapterList(String chapterUrl, String source) async {
    try {
      String url = chapterUrl.substring(0, chapterUrl.lastIndexOf('/'));

      var result = await HttpUtils.getInstance().get(
          '/chapters?detail_url=${Uri.encodeComponent(url)}&source=$source');
      ChapterModel chapterResult = ChapterModel.fromJson(result.data);

      setState(() {
        _chapterList = chapterResult.data;
      });
    } catch (e) {
      print(e);
    }
  }

  _initData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double fontSize = prefs.getDouble('fontSize') ?? 20.0;
    String bgColor = prefs.getString('bgColor') ?? 'daytime';
    double currPos =
        prefs.getDouble(widget.shelfId.toString() + 'currPos') ?? 0.0;
    _controller = new ScrollController(initialScrollOffset: currPos);
    setState(() {
      _fontSize = fontSize;
      _bgColor = bgColor;
    });
  }

  _saveData() async {
    double _currPos = _controller.position.pixels;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble(widget.shelfId.toString() + 'currPos', _currPos);
  }
}

class MenuItem extends StatelessWidget {
  final List<Widget> children;
  final Function onTap;

  MenuItem({this.children, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: children,
      ),
      onTap: onTap,
    );
  }
}

class BgColorItem extends StatelessWidget {
  final Color color;
  final Function onTap;

  BgColorItem({this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        height: 50,
        width: MediaQuery.of(context).size.width / 4 - 20,
        decoration: BoxDecoration(
          color: color,
          border: new Border.all(width: 2.0, color: Colors.grey),
          borderRadius: new BorderRadius.all(new Radius.circular(10.0)),
        ),
      ),
      onTap: onTap,
    );
  }
}
