import 'package:dnovel_flutter/utils/color.dart';
import 'package:flutter/material.dart';

class NovelItem extends StatelessWidget {
  final String bookName;
  final String authorName;
  final String cover; // 封面

  NovelItem({this.bookName, this.authorName, this.cover});

  @override
  Widget build(BuildContext context) {
    var back;
    if (cover == null || cover == "") {
      back = DecoratedBox(
          // 用装饰容器来绘制背景色, 可以直接用更上层的Container(color: MyColor.bgColor)
          decoration: BoxDecoration(
        color: Color.fromRGBO(242, 235, 217, 0.4),
      )); // 背景色
    } else {
      back = Image.network(
        cover,
        fit: BoxFit.cover, // 全屏填充
      );
    }

    return Card(
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: AspectRatio(
          aspectRatio: 0.7,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              back,
              Align(
                alignment: Alignment(-0.6, -0.5),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.0),
                  child: Text(
                    bookName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500), // 中等加粗
                  ),
                ),
              ),
              Align(
                alignment: Alignment(-0.6, 0.7),
                child: Text(
                  "作者: " + authorName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14.0, color: Colors.grey),
                ),
              ),
            ],
          ),
        ));
  }
}
