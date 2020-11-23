import 'package:dnovel_flutter/utils/exit.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import './read.dart';
import '../models/Shelf.dart';
import '../utils/color.dart';
import '../components/BottomAppBar.dart';
import '../components/NovelItem.dart';
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
          body: Container(
            color: MyColor.bgColor,
            child: content,
          ),
          bottomNavigationBar: MyBottomAppBar(
            currentIndex: 0,
          ),
        ),
        onWillPop: Exit.isExit);
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
          FlatButton(
            child: Text(
              '书架空空，去书屋逛逛吧~~',
              style: TextStyle(color: MyColor.linkColor),
            ),
            padding: EdgeInsets.symmetric(vertical: 60.0),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/classify', (Route<dynamic> route) => false);
            },
          )
        ],
      ),
    );
  }

  Widget _buildShelfList() {
    return ListView(
      children: <Widget>[
        Card(
          margin: EdgeInsets.all(10.0),
          elevation: 0,
          child: Container(
              padding: EdgeInsets.all(20.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 20.0,
                crossAxisSpacing: 20.0,
                childAspectRatio: 0.75,
                // 宽 / 高 = 0.7
                padding: EdgeInsets.all(5.0),
                children: List.generate(_shelfList.length, (index) {
                  Shelf novel = _shelfList[index];
                  return _buildShelfItem(novel);
                }),
              )),
        ),
      ],
    );
  }

  Widget _buildShelfItem(Shelf novel) {
    List<Widget> content = [];
    content.add(
      NovelItem(bookName: novel.bookName, authorName: novel.authorName),
    );
    if (_whetherDelete) {
      content.add(Align(
        alignment: Alignment.topRight,
        child: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            _deleteShelf(novel.bookName);
          },
        ),
      ));
    }

    return GestureDetector(
      child: Stack(
        children: content,
      ),
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
        );
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
