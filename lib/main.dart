import 'package:dnovel_flutter/pages/indexPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import './pages/shelf.dart';
import './pages/classify.dart';
import './pages/search.dart';

void main() {
  runApp(ScreenUtilInit(
      designSize: Size(750, 1334),
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: '梦阅',
          initialRoute: '/',
          routes: {
            '/': (BuildContext context) => IndexPage(),
            '/shelf': (BuildContext context) => ShelfPage(),
            '/classify': (BuildContext context) => ClassifyPage(),
            '/search': (BuildContext context) => SearchPage(),
          },
        );
      }));

  // 设置状态栏背景颜色透明
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
}
