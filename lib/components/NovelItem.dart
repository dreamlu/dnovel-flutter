import 'package:dnovel_flutter/utils/extension/extension.dart';
import 'package:flutter/material.dart';

class NovelItem extends StatelessWidget {
  final String bookName;
  final String authorName;
  final String cover; // 封面
  final String source;

  NovelItem({this.bookName, this.authorName, this.cover, this.source = ''});

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
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),
                      Expanded(child: Text(
                        bookName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 32.sp,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500), // 中等加粗
                      )),
                      Text(
                        "作者: " + authorName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 26.sp, color: Colors.grey),
                      ),
                      Text(
                        "来源: " + source,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 22.sp, color: Colors.black26),
                      ),
                      SizedBox(height: 20.h),
                    ],
                  )),
            ],
          ),
        ));
  }
}
