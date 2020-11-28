import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './intro.dart';
import '../models/Hist.dart';
import '../models/Hot.dart';
import '../models/Search.dart';
import '../utils/request.dart';
import '../utils/color.dart';
import '../utils/DialogUtils.dart';
import '../components/NovelItem.dart';
import '../components/LoadingView.dart';

class SearchPage extends StatefulWidget {
  @override
  State createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Hot> _hotList = []; // 热门搜索数据
  List<Search> _novelList = []; // 搜索小说数据
  bool _whetherLoading = false;

  TextEditingController _keywordController = TextEditingController(); // 搜索关键词

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> content = [];

    if (_whetherLoading) {
      content.add(LoadingView());
    } else {
      if (_novelList.length > 0) {
        content.add(NavTitle(title: '找到了这些书📚'));
        content.add(_buildNovelList());
      }
      if (_hotList.length > 0) {
        content.add(NavTitle(title: '热门搜索'));
        content.add(_buildHotList());
      }
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        color: MyColor.bgColor,
        child: ListView(children: content),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: MyColor.bgColor,
      brightness: Brightness.light,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.chevron_left),
        color: MyColor.iconColor,
        iconSize: 32,
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      titleSpacing: 0,
      title: Padding(
        padding: EdgeInsets.only(top: 12.0, bottom: 12.0, right: 30.0),
        child: TextField(
          controller: _keywordController,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black12),
              borderRadius: BorderRadius.circular(30.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black45),
              borderRadius: BorderRadius.circular(30.0),
            ),
            hintText: '小说名/作者名',
            hintStyle: TextStyle(color: Colors.black26),
            filled: true,
            fillColor: Colors.white12,
            contentPadding: EdgeInsets.symmetric(vertical: 0),
            prefixIcon: Icon(Icons.search, color: Colors.black26),
          ),
          onChanged: (String text) {
            setState(() {
              if (text == '') {
                _novelList = [];
              }
            });
          },
          onSubmitted: (String value) {
            if (value == '') {
              DialogUtils.showToastDialog(context, text: '关键词不能为空');
              return;
            }
            _fetchNovelList(value);
          },
        ),
      ),
    );
  }

  Widget _buildNovelList() {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.symmetric(horizontal: 10.0),
      padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
      child: GridView.count(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        childAspectRatio: 0.75,
        // 宽 / 高
        padding: EdgeInsets.all(5.0),
        children: List.generate(_novelList.length, (index) {
          Search novel = _novelList[index];
          return GestureDetector(
            child: NovelItem(
              bookName: novel.bookName,
              authorName: novel.authorName,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => IntroPage(
                    url: novel.bookUrl,
                    source: novel.source,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildHotList() {
    return GridView.count(
      padding: const EdgeInsets.all(10.0),
      crossAxisCount: 3,
      crossAxisSpacing: 2.0,
      mainAxisSpacing: 2.0,
      childAspectRatio: 2 / 1,
      // 宽 : 高 = 2 : 1
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: List.generate(_hotList.length, (index) {
        Hot _hot = _hotList[index];
        return GestureDetector(
          child: Container(
            color: Colors.white,
            alignment: Alignment.center,
            child: Text(
              _hot.keyword,
              style: TextStyle(
                color: Colors.black54,
              ),
            ),
          ),
          onTap: () {
            _keywordController.text = _hot.keyword;
            _fetchNovelList(_hot.keyword);
          },
        );
      }),
    );
  }

  _fetchNovelList(String keyword) async {
    setState(() {
      _whetherLoading = true;
    });

    try {
      // SharedPreferences prefs = await SharedPreferences.getInstance();

      var result = await HttpUtils.getInstance().get('/search?k=$keyword');
      SearchModel searchResult = SearchModel.fromJson(result.data);

      if (searchResult.data.length == 0) {
        DialogUtils.showToastDialog(context, text: '很遗憾没找到小说~');
      }

      setState(() {
        _novelList = searchResult.data;
      });

    } catch (e) {
      print(e);
    }

    setState(() {
      _whetherLoading = false;
    });
  }
}

class NavTitle extends StatelessWidget {
  final String title;

  NavTitle({this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Text(title,
          style: TextStyle(
            color: Color.fromRGBO(80, 80, 80, 100),
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          )),
    );
  }
}
