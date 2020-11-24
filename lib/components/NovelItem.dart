import 'package:flutter/material.dart';

class NovelItem extends StatelessWidget {
  final String bookName;
  final String authorName;
  final String cover; // 封面

  NovelItem({this.bookName, this.authorName, this.cover});

  @override
  Widget build(BuildContext context) {
    Image img;
    if (cover == null || cover == "") {
      img = Image(
        image: AssetImage("lib/images/cover.png"),
        fit: BoxFit.cover,
      );
    } else {
      img = Image.network(
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
              img,
              Align(
                alignment: Alignment(-0.6, -0.5),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.0),
                  child: Text(
                    bookName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 18.0, color: Colors.grey),
                  ),
                ),
              ),
              Align(
                alignment: Alignment(0.2, 0.5),
                child: Text(
                  authorName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14.0, color: Colors.grey),
                ),
              ),
            ],
          ),
        ));
  }
}
