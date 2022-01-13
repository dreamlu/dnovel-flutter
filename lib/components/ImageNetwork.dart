import 'package:flutter/material.dart';

// 封装图片加载控件，增加图片加载失败时加载默认图片
// 右上角增加组件覆盖
// ignore: must_be_immutable
class ImageNetwork extends StatefulWidget {
  String src;
  final double? width;
  final double? height;
  final String defImagePath;
  final GestureTapCallback? onTap;
  final Widget? rightTop;
  final GestureTapCallback? rightTopTap;
  final BoxFit? fit;

  ImageNetwork(this.src,
      {this.width,
      this.height,
      this.defImagePath = "lib/images/empty.png",
      this.onTap,
      this.rightTop,
      this.rightTopTap,
      this.fit});

  @override
  State<StatefulWidget> createState() {
    return _StateImageWidget();
  }
}

class _StateImageWidget extends State<ImageNetwork> {
  Image? _image;
  bool isDefault = false;

  @override
  void initState() {
    // widget.src = widget.src == null ? '' : widget.src;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.src != '') {
      _image = _netWorkImage();
      isDefault = false;
    } else {
      _image = _defaultImage();
      isDefault = true;
    }
    var resolve = _image?.image.resolve(ImageConfiguration.empty);
    resolve?.addListener(ImageStreamListener((_, __) {
      //加载成功
    }, onError: (dynamic exception, StackTrace? stackTrace) {
      //加载失败
      setState(() {
        widget.src = '';
        _image = _defaultImage();
      });
    }));

    Widget content =
        !isDefault && widget.rightTop != null ? _rightTop(_image) : _image;
    content = _onTap(content);
    return content;
  }

  _netWorkImage() {
    return Image.network(
      widget.src,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
    );
  }

  _defaultImage() {
    return Image.asset(
      widget.defImagePath,
      width: widget.width,
      height: widget.height,
    );
  }

  _onTap(img) {
    return GestureDetector(
      child: img,
      onTap: widget.onTap,
    );
  }

  _rightTop(w) {
    return Stack(clipBehavior: Clip.none, children: [
      w,
      Positioned(
          top: -8,
          right: -8,
          child: GestureDetector(
            child: Container(
                padding: EdgeInsets.only(left: 2, right: 2),
                decoration: BoxDecoration(
                  // shape: BoxShape.circle,
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                ),
                child: widget.rightTop),
            onTap: widget.rightTopTap,
          )),
    ]);
  }
}
