import 'package:dnovel_flutter/utils/extension/extension.dart';
import 'package:flutter/material.dart';

class NovelItem extends StatelessWidget {
  final String bookName;
  final String authorName;
  final String source;
  final String bookCoverUrl;
  final String desc;

  final GestureTapCallback? onTap;

  NovelItem(
      {this.bookName = '',
      this.authorName = '',
      this.source = '',
      this.bookCoverUrl = '',
      this.onTap,
      this.desc = ''});

  @override
  Widget build(BuildContext context) {
    return _buildShelfItem(context);
  }

  Widget _buildShelfItem(BuildContext context) {
    List<Widget> content = [];
    var img;
    if (bookCoverUrl == "") {
      img = Image.asset("lib/images/empty.png");
    } else {
      try {
        img = ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(bookCoverUrl),
        ); // CachedNetworkImage(imageUrl: novel.bookCoverUrl); //Image.network(novel.bookCoverUrl);
      } catch (e) {
        img = Image.asset("lib/images/empty.png");
      }
    }

    content.add(
      // NovelItem(bookName: novel.bookName, authorName: novel.authorName),
      ListTile(
          leading: img,
          title: Text(bookName, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              Row(children: [
                Expanded(
                    child: Text(authorName.contains("作者")
                        ? authorName
                        : '作者：' + authorName)),
                Text("来源: " + source, style: TextStyle(color: Colors.black26)),
              ]),
              SizedBox(height: 5.h),
              desc == ''
                  ? SizedBox()
                  : Text(
                      desc.contains("简介") ? desc : '简介：' + desc,
                      maxLines: 2,
                    ),
            ],
          )),
    );

    // 点击涟漪效果
    return InkWell(
      child: Stack(children: content),
      onTap: onTap,
    );
  }
}
