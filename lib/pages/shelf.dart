// import 'package:cached_network_image/cached_network_image.dart';
import 'package:dnovel_flutter/utils/exit.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import './read.dart';
import '../models/Shelf.dart';
import '../utils/color.dart';
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

    return WillPopScope(
        child: Scaffold(
          appBar: _buildAppBar(),
          body: RefreshIndicator(
              onRefresh: _onRefresh,
              child: Container(
                color: MyColor.bgColor,
                child: content,
              )),
        ),
        onWillPop: Exit.isExit);
  }

  Future<Null> _onRefresh() async {
    _fetchShelfList();
  }

  Widget _buildAppBar() {
    List<Widget> actions = [];
    if (_shelfList.length > 0) {
      actions.add(FlatButton(
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
      brightness: Brightness.light,
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image(
            width: 150.0,
            height: 150.0,
            image: AssetImage("lib/images/empty.png"),
          ),
          Padding(
            child: Text(
              '书架空空，去书屋逛逛吧~~',
              style: TextStyle(color: MyColor.linkColor),
            ),
            padding: EdgeInsets.symmetric(vertical: 60.0),
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
    var img;
    if (novel.bookCoverUrl == null || novel.bookCoverUrl == "") {
      img = Image.asset("lib/images/cover.png");
    } else {
      try {
        img = ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(novel.bookCoverUrl),
        ); // CachedNetworkImage(imageUrl: novel.bookCoverUrl); //Image.network(novel.bookCoverUrl);
      } catch (e) {
        img = Image.asset("lib/images/cover.png");
      }
    }
    content.add(
      // NovelItem(bookName: novel.bookName, authorName: novel.authorName),
      ListTile(
        leading: img,
        title:
            Text(novel.bookName, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Row(children: [
          Expanded(child: Text("作者: " + novel.authorName)),
          Text("来源: " + novel.source, style: TextStyle(color: Colors.black26)),
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
