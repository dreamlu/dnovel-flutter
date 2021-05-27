import 'package:dnovel_flutter/components/LazyIndexedStack.dart';
import 'package:dnovel_flutter/pages/classify.dart';
import 'package:dnovel_flutter/pages/shelf.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/color.dart';

class IndexPage extends StatefulWidget {
  int currentIndex;

  IndexPage({this.currentIndex = 0});

  @override
  _IndexPageState createState() => _IndexPageState();
}

// 底部模块
class _IndexPageState extends State<IndexPage> {
  static const double _width = 20;
  static const double _height = 20;

  final List<Widget> tabBodies = [
    ShelfPage(),
    ClassifyPage(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(244, 245, 245, 1.0),
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: MyColor.bgColor,
        // elevation: 0,
        // selectedItemColor: Colors.red,
        // unselectedItemColor: Colors.black,
        // type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Image(
              image: AssetImage('lib/images/book-shelf.png'),
              // width: _width,
              // height: _height,
            ),
            activeIcon: Image(
              image: AssetImage('lib/images/book-shelf-selected.png'),
              // width: _width,
              // height: _height,
            ),
            label: '书架',
          ),
          BottomNavigationBarItem(
            icon: Image(
              image: AssetImage('lib/images/book-shop.png'),
              width: _width,
              height: _height,
            ),
            activeIcon: Image(
              image: AssetImage('lib/images/book-shop-selected.png'),
              width: _width,
              height: _height,
              color: Colors.red,
            ),
            label: '书屋',
          ),
        ],
        currentIndex: widget.currentIndex,
        onTap: (int index) {
          widget.currentIndex = index;
          setState(() {});
        },
      ),
      body: LazyIndexedStack(
        index: widget.currentIndex,
        children: tabBodies,
      ),
    );
  }
}
