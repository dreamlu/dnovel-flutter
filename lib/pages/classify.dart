import 'package:dnovel_flutter/utils/exit.dart';
import 'package:flutter/material.dart';
import './intro.dart';
import '../models/Classify.dart';
import '../models/Novel.dart';
import '../components/NovelItem.dart';
import '../components/LoadingView.dart';
import '../utils/color.dart';
import '../utils/request.dart';

class ClassifyPage extends StatefulWidget {
  @override
  State createState() => _ClassifyPageState();
}

class _ClassifyPageState extends State<ClassifyPage> {
  List<Classify> _classifyList = []; // 分类列表
  List<Novel> _novelList = []; // 小说列表
  String _selectedClassifyName = ''; // 选中分类
  bool _whetherNovelLoading = true;

  @override
  void initState() {
    _fetchClassifyList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: _buildAppBar(),
          body: Container(
            color: MyColor.bgColor,
            child: Column(children: [
              _buildClassifyList(),
              _buildNovelList(),
            ]),
          ),
        ),
        onWillPop: Exit.isExit);
  }

  Widget _buildAppBar() {
    return AppBar(
      title: Text(
        '书屋',
        style: TextStyle(color: MyColor.appBarTitle),
      ),
      backgroundColor: MyColor.bgColor,
      brightness: Brightness.light,
      elevation: 0,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.search),
          color: MyColor.iconColor,
          onPressed: () {
            Navigator.pushNamed(context, '/search');
          },
        ),
      ],
    );
  }

  Widget _buildClassifyList() {
    return Wrap(
      direction: Axis.horizontal,
      children: List.generate(_classifyList.length, (index) {
        return _buildClassifyItem(item: _classifyList[index], index: index);
      }),
    );
  }

  Widget _buildClassifyItem({item, index}) {
    bool _isCurrent = _selectedClassifyName == item.name;
    return Container(
      child: FlatButton(
        onPressed: () {
          setState(() {
            _selectedClassifyName = item.name;
          });
          _fetchNovelList(item.name);
        },
        child: Text(
          _classifyList[index].name,
          style: _isCurrent
              ? TextStyle(
                  color: Color.fromRGBO(44, 131, 245, 1.0),
                )
              : TextStyle(
                  color: Color.fromRGBO(128, 128, 128, 100),
                ),
        ),
      ),
    );
  }

  Widget _buildNovelList() {
    Widget content = Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 5.0,
        // 垂直间距
        crossAxisSpacing: 3.0,
        // 水平间距
        childAspectRatio: 1.15,
        // 宽 / 高 = 0.7
        children: List.generate(_novelList.length, (index) {
          Novel novel = _novelList[index];
          return GestureDetector(
            child: NovelItem(
              bookName: novel.bookName,
              authorName: novel.authorName,
              source: novel.source,
            ),
            onTap: () {
              String bookUrl = novel.bookUrl;
              Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                return IntroPage(
                  url: bookUrl,
                  source: novel.source,
                );
              }));
            },
          );
        }),
      ),
    );

    if (_whetherNovelLoading) {
      content = Center(child: LoadingView());
    }

    return Expanded(
      flex: 3,
      child: content,
    );
  }

  _fetchClassifyList() async {
    try {
      var result = await HttpUtils.getInstance().get('/classify');
      ClassifyModel classifyResult = ClassifyModel.fromJson(result.data);

      String name = classifyResult.data[0].name;
      _fetchNovelList(name);

      setState(() {
        _classifyList = classifyResult.data;
        _selectedClassifyName = name;
      });
    } catch (e) {
      print(e);
    }
  }

  _fetchNovelList(name) async {
    setState(() {
      _whetherNovelLoading = true;
    });

    try {
      var result =
          await HttpUtils.getInstance().get('/classify/info?name=$name');
      NovelModel novelResult = NovelModel.fromJson(result.data);

      setState(() {
        if (novelResult.data == null) {
          novelResult.data = [];
        }
        _novelList = novelResult.data;
      });
    } catch (e) {
      print(e);
    }

    setState(() {
      _whetherNovelLoading = false;
    });
  }
}
