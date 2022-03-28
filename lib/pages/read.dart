import 'package:dnovel_flutter/models/Shelf.dart';
import 'package:dnovel_flutter/service/ChapterService.dart';
import 'package:dnovel_flutter/utils/global/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/ChapterDrawer.dart';
import '../components/LoadingView.dart';
import '../models/Chapter.dart';
import '../models/Detail.dart';
import '../utils/DialogUtils.dart';
import '../utils/request.dart';

Map bgColors = {
  'daytime': null, // 白天,默认无颜色
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
  final bool isShelf;

  ReadPage({
    this.shelfId = 0,
    this.url = '',
    this.detailUrl = '',
    this.source = '',
    this.bookName = '',
    this.fromPage = '',
    this.isShelf = false,
  });

  @override
  State createState() => _ReadPageState();
}

// 沉浸式页面
class _ReadPageState extends State<ReadPage> {
  List<Chapter> _chapterList = [];
  Detail? _detail; // 小说内容：标题、内容、上一章url、下一章url

  // 阅读设置
  double _fontSize = 37.0.h; // 字体
  String _bgColor = 'my_love'; // 字体背景颜色
  String _backColor = 'daytime'; // 整体背景颜色
  bool _whetherNight = false; // 是否是黑夜
  ScrollController? _controller; // 滚动条对象
  String _pos = '';
  SharedPreferences? _prefs;
  double _currPos = 0.0;

  @override
  void initState() {
    _initData();
    _fetchDetail(widget.url);
    _fetchChapterList(widget.detailUrl, widget.source);
    _pos = curPos(widget.source, widget.bookName);
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    _saveData();
    super.deactivate();
  }

  _initData() async {
    _prefs = await SharedPreferences.getInstance();
    double fontSize = _prefs?.getDouble('fontSize') ?? _fontSize;
    String bgColor = _prefs?.getString('bgColor') ?? 'my_love';
    String backColor = _prefs?.getString('backColor') ?? 'daytime';
    _currPos = _prefs?.getDouble(_pos) ?? 0.0;
    _prefs?.setDouble(_pos, 0);
    setState(() {
      _fontSize = fontSize;
      _bgColor = bgColor;
      _backColor = backColor;
    });
  }

  _saveData() async {
    if (!widget.isShelf) {
      return;
    }
    double _currPos = _controller?.position.pixels ?? 0;
    _prefs?.setDouble(_pos, _currPos);
  }

  @override
  Widget build(BuildContext context) {
    if (_controller != null) {
      _controller?.dispose();
    }
    _controller = ScrollController(
        initialScrollOffset: _currPos, keepScrollOffset: false);
    Widget content;
    if (_detail == null) {
      content = Expanded(child: LoadingView());
    } else {
      content = _buildBody();
    }

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      body: _buildColorContent(content),
      drawer: ChapterDrawer(
        bookName: widget.bookName,
        title: _detail != null ? _detail?.title : '',
        chapterList: _chapterList,
        onTap: (String url) {
          _fetchDetail(url, post: () {});
        },
      ),
    );
  }

  // 构建带颜色的阅读页
  Widget _buildColorContent(content) {
    var backColor = bgColors[_backColor];
    if (_bgColor == "my_love") {
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/images/read_background.jpg'),
            fit: BoxFit.cover, // 全屏
          ),
        ),
        // color: bgColors[_bgColor],
        child: Container(
          color: backColor,
          child: Column(
            children: <Widget>[
              SizedBox(height: 25.0.h),
              _buildHeader(),
              content,
              _buildFooter(),
            ],
          ),
        ),
      );
    }

    return Container(
      color: bgColors[_bgColor],
      child: Container(
        color: backColor,
        child: Column(
          children: <Widget>[
            SizedBox(height: 25.0.h),
            _buildHeader(),
            content,
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: EdgeInsets.only(bottom: 5.0.h, top: 35.0.h),
      // decoration: BoxDecoration(
      //   border: Border(bottom: BorderSide(color: Colors.black26)),
      // ),
      // alignment: Alignment.center,
      height: 40.0.h,
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
          Expanded(
              // 文字省略号失效解决
              child: Text(
            _detail != null ? _detail?.title ?? '' : '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Expanded(
      child: Builder(
        builder: (ctx) => Container(
          child: Stack(
            children: [
              Scrollbar(
                child: ListView(
                  controller: _controller,
                  children: <Widget>[
                    Html(
                      data: "<font>" + _detail!.content + "</font>",
                      style: {
                        "html": Style(
                          fontSize: FontSize(_fontSize),
                          letterSpacing: 0.2,
                        ),
                        "font": Style(
                          // 添加一个标签防止content中没有<p>来进行行高设置
                          lineHeight: LineHeight(1.3),
                        ),
                        "p": Style(
                          lineHeight: LineHeight(1.3),
                        ),
                      },
                    ),
                  ],
                ),
                thickness: 5,
              ),
              Flex(
                direction: Axis.vertical,
                children: [
                  Expanded(child: GestureDetector(
                    onTap: () {
                      double value =
                          _controller!.offset - ctx.size!.height;
                      if (value < 0) {
                        value = 0;
                      }
                      _controller?.animateTo(value,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease);
                    },
                  )),
                  Expanded(
                    child: GestureDetector(
                      // behavior: HitTestBehavior.translucent,
                      // child: Container(
                      //   color: Colors.blue,
                      //   // constraints: BoxConstraints.tight(Size(300.0, 200.0)),
                      // ),
                      onTap: () {
                        showModalBottomSheet(
                          context: ctx,
                          builder: (ctx2) => _buildMenuBottomSheet(ctx),
                        );
                      },
                    ),
                  ),
                  Expanded(child: GestureDetector(
                    onTap: () {
                      double value =
                          _controller!.offset + ctx.size!.height;
                      if (value < 0) {
                        value = 0;
                      }
                      _controller?.animateTo(value,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease);
                    },
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      height: 90.0.h,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black26)),
      ),
      child: Flex(
        // mainAxisAlignment: MainAxisAlignment.spaceAround,
        direction: Axis.horizontal,
        children: <Widget>[
          Expanded(
            child: TextButton(
              // padding: EdgeInsets.all(0),
              child: Text('上一章', style: TextStyle(color: Colors.black54)),
              onPressed: () {
                if (_detail?.prevUrl == '' ||
                    _detail?.prevUrl.contains('.html') == false) {
                  DialogUtils.showToastDialog(context, text: '当前是第一章了哦~');
                  return;
                }
                _fetchDetail(_detail?.prevUrl ?? '', post: () {});
              },
            ),
          ),
          Expanded(
            child: TextButton(
              child: Text('下一章', style: TextStyle(color: Colors.black54)),
              onPressed: () {
                if (_detail?.nextUrl == '' ||
                    _detail?.nextUrl.contains('.html') == false) {
                  DialogUtils.showToastDialog(context, text: '已经是最新章节了哦~');
                  return;
                }
                _fetchDetail(_detail?.nextUrl ?? '', post: () {});
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuBottomSheet(BuildContext ctx) {
    return Container(
      height: 160.0.h,
      padding: EdgeInsets.symmetric(vertical: 30.0.h),
      child: Flex(
        // mainAxisAlignment: MainAxisAlignment.spaceAround,
        direction: Axis.horizontal,
        children: <Widget>[
          Expanded(
            child: MenuItem(
              children: <Widget>[
                Icon(Icons.library_books),
                Text('目录'),
              ],
              onTap: () {
                Navigator.pop(context);
                Scaffold.of(ctx).openDrawer();
              },
            ),
          ),
          Expanded(
            child: MenuItem(
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
                _prefs?.setDouble('fontSize', _fontSize);
                _prefs?.setString('bgColor', _bgColor);
              },
            ),
          ),
          Expanded(
            child: MenuItem(
              children: <Widget>[
                Icon(_whetherNight == true
                    ? Icons.brightness_7
                    : Icons.brightness_2),
                Text(_whetherNight == true ? '白天' : '黑夜'),
              ],
              onTap: () {
                setState(() {
                  _backColor = _whetherNight ? 'daytime' : 'night';
                  _whetherNight = !_whetherNight;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsBottomSheet() {
    return Container(
      height: 280.0.h,
      padding: EdgeInsets.symmetric(horizontal: 20.0.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                '字体',
                style: TextStyle(fontSize: 38.0.sp),
              ),
              IconButton(
                icon: Icon(
                  Icons.add,
                  size: 50.0.h,
                ),
                onPressed: () {
                  setState(() {
                    _fontSize += 2;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.indeterminate_check_box_rounded,
                  size: 50.0.h,
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

  _fetchDetail(String url, {Function? post}) async {
    Detail oldDetail = _detail ?? Detail();
    if (_detail != null) {
      setState(() {
        _currPos = 0.0;
        _detail = null;
      });
    }

    _detail = await ChapterService.getNextChapter(oldDetail, url, widget.source,
        ChapterService(widget.bookName, widget.source, url, oldDetail.nextUrl));

    // 异步存储当前书架书籍阅读进度
    // 提前传递过来判断是否书架更好
    Shelf.upRecentChapterUrl(widget.bookName, url);
    if (post != null) {
      // post();
      // 优先跳转防止二次构建页面未加载,跳转失败,eg: ScrollController not attached to any scroll views.
      if (_controller?.hasClients ?? true) {
        _controller?.jumpTo(0);
      }
    }
    setState(() {});
  }

  // 异步加载请求章节列表数据
  _fetchChapterList(String detailUrl, String source) async {
    try {
      var result = await HttpUtils.getInstance().get(
          '/chapters?detail_url=${Uri.encodeComponent(detailUrl)}&source=$source');
      ChapterModel chapterResult = ChapterModel.fromJson(result.data);

      setState(() {
        _chapterList = chapterResult.data ?? [];
        ChapterService.init(_chapterList);
        // 异步缓存提前加载章节
        ChapterService.cache(
            ChapterService(widget.bookName, widget.source, widget.url, ''));
      });
    } catch (e) {
      print(e);
    }
  }
}

class MenuItem extends StatelessWidget {
  final List<Widget> children;
  final GestureTapCallback? onTap;

  MenuItem({this.children = const [], this.onTap});

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
  final Color? color;
  final GestureTapCallback? onTap;

  BgColorItem({this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        height: 90.0.h,
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
