import 'package:dnovel_flutter/components/ImageNetwork.dart';
import 'package:dnovel_flutter/utils/global/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import './read.dart';
import '../models/Shelf.dart';
import '../utils/color.dart';
import '../utils/extension/extension.dart';
import '../components/LoadingView.dart';

class ShelfPage extends StatefulWidget {
  @override
  State createState() => _ShelfPageState();
}

class _ShelfPageState extends State<ShelfPage> {
  //with WidgetsBindingObserver {
  List<Shelf> _shelfList = []; // 书架列表
  bool _whetherDelete = false; // 是否删除
  bool _whetherLoading = true; //

  @override
  void initState() {
    _fetchShelfList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_whetherLoading) {
      content = Center(child: LoadingView());
    } else {
      if (_shelfList.length > 0) {
        content = _buildShelfList();
      } else {
        content = _buildEmpty();
      }
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
          onRefresh: _onRefresh,
          child: Container(
            color: MyColor.bgColor,
            child: content,
          )),
    );
  }

  Future<Null> _onRefresh() async {
    _fetchShelfList();
  }

  PreferredSizeWidget _buildAppBar() {
    List<Widget> actions = [];
    if (_shelfList.length > 0) {
      actions.add(TextButton(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
        ),
        child: Text(
          _whetherDelete ? '完成' : '编辑',
          style: TextStyle(color: Colors.black45),
        ),
        onPressed: () {
          setState(() {
            _whetherDelete = !_whetherDelete;
          });
        },
      ));
    }

    return AppBar(
      title: Text(
        '书架',
        style: TextStyle(color: MyColor.appBarTitle),
      ),
      backgroundColor: MyColor.bgColor,
      elevation: 0,
      actions: actions,
      systemOverlayStyle:
          SystemUiOverlayStyle(statusBarBrightness: Brightness.light),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: ListView(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 150.h),
          Image(
            width: 249.w,
            height: 249.h,
            image: AssetImage("lib/images/empty.png"),
          ),
          SizedBox(height: 10.h),
          Center(
            child: Text(
              '书架空空，去书屋逛逛吧~~',
              style: TextStyle(color: MyColor.linkColor),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildShelfList() {
    return ListView.separated(
      itemCount: _shelfList.length,
      itemBuilder: (context, index) {
        return _buildShelfItem(_shelfList[index]);
      },
      separatorBuilder: (context, index) => Divider(height: .0),
    );
  }

  // 书架列表item构建
  Widget _buildShelfItem(Shelf novel) {
    List<Widget> content = [];
    content.add(
      // NovelItem(bookName: novel.bookName, authorName: novel.authorName),
      ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: ImageNetwork(novel.bookCoverUrl),
        ),
        title:
            Text(novel.bookName, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text("作者: " + novel.authorName)),
            Text("来源: " + novel.source,
                style: TextStyle(color: Colors.black26)),
          ]),
          Text("阅读进度: " + (novel.recentChapterTitle == ''?'还未阅读':novel.recentChapterTitle),
              style: TextStyle(color: Colors.black12,fontSize: 20.sp),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ]),
        // trailing: Icon(Icons.chevron_right),
        // tileColor: Coll,
      ),
    );
    if (_whetherDelete) {
      content.add(Align(
        alignment: Alignment.topRight,
        child: IconButton(
          icon: Icon(Icons.delete_outline),
          onPressed: () {
            _deleteShelf(novel.bookName);
          },
        ),
      ));
    }

    // 点击涟漪效果
    return InkWell(
      child: Stack(children: content),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReadPage(
              url: novel.recentChapterUrl,
              bookName: novel.bookName,
              source: novel.source,
              detailUrl: novel.detailUrl,
              fromPage: 'ShelfPage',
              isShelf: true,
            ),
          ),
        ).then((value) => {
              // 直接刷新
              setState(() {
                _fetchShelfList(); // 返回的页面Navigator.pop(context,'value');
              })
            });
      },
    );
  }

  _fetchShelfList() async {
    setState(() {
      _whetherLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    // int userId = prefs.getInt('userId') ?? -1;

    try {
      _shelfList = Shelf.toList(prefs.get("shelfList"));
    } catch (e) {
      print(e);
    }

    setState(() {
      _whetherLoading = false;
    });
  }

  _deleteShelf(String name) async {
    setState(() {
      _whetherLoading = true;
    });

    try {
      for (Shelf shelf in _shelfList) {
        if (shelf.bookName == name) {
          _shelfList.remove(shelf);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('shelfList', jsonEncode(_shelfList));
          prefs.remove(curPos(shelf.source, shelf.bookName));
          break;
        }
      }
      setState(() {
        _whetherDelete = false;
      });
      _fetchShelfList();
    } catch (e) {
      print(e);
    }
  }
}
