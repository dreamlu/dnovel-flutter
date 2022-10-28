import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
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
      this.defImagePath = "lib/images/lost.png",
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
  Widget? _image;
  bool isDefault = false;

  // Image.network headers bug
  // Use origin bytes to image ui
  late Uint8List _netBytes = Uint8List(0);

  @override
  void initState() {
    // _netWorkBytes();
    // var resolve = _image?.image.resolve(ImageConfiguration.empty);
    // resolve?.addListener(ImageStreamListener((_, __) {
    //   //加载成功
    // }, onError: (dynamic exception, StackTrace? stackTrace) {
    //   //加载失败
    //   setState(() {
    //     widget.src = '';
    //     _image = _defaultImage();
    //   });
    // }));
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
      errorBuilder: (context,error,stackTrace){
        return _defaultImage();
      },
    );
    // return Container(
    //     child: _netBytes.lengthInBytes == 0
    //         ? Text('加载中...')
    //         : Image.memory(_netBytes));
  }

  _netWorkBytes() async {
    var headers = {
      "user-agent":
          "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36",
      "accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",

      // "content-type":"image/jpeg",
      // "cache-control":"max-age=2592000",
      // "report-to":'{"endpoints":[{"url":"https:\/\/a.nel.cloudflare.com\/report\/v3?s=gqC%2B3u9OkttDN3shuKdDYYF8UCPTkOPaRcxJQZ1jbOoesb3EO9SmcvxCmeyuC4kQ3rfI9LiH1LhWGdn2FvkaXZGWI9NGO%2F4yyvOM1ap3JoKD%2B%2BzpL21RUrSZWttKWQ%3D%3D"}],"group":"cf-nel","max_age":604800}'
    };
    BaseOptions options = BaseOptions(headers: headers);
    // another
    Dio dio = Dio(options);
    dio.options.headers = headers;
    var response = await dio.get(widget.src,
        options: Options(responseType: ResponseType.stream, headers: headers));
    if (response.statusCode != HttpStatus.ok) {
      throw Exception('_netWorkBytes is an empty file: ${widget.src}');
    }
    final stream = await (response.data as ResponseBody).stream.toList();
    final result = BytesBuilder();
    for (Uint8List subList in stream) {
      result.add(subList);
    }
    _netBytes = result.takeBytes();
    if (_netBytes.lengthInBytes == 0) {
      throw Exception('_netWorkBytes is an empty file: ${widget.src}');
    }
    setState(() {});
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
