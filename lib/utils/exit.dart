import 'package:fluttertoast/fluttertoast.dart';

// 退出模块
class Exit {
  static DateTime _lastPressedAt =
      DateTime.now().subtract(Duration(seconds: 5));

  static Future<bool> isExit() async {
    DateTime now = DateTime.now();
    if (now.difference(_lastPressedAt) > Duration(seconds: 3)) {
      Fluttertoast.showToast(
        // fontSize: 12.0,
        msg: "再按一次退出程序",
        // toastLength: Toast.LENGTH_SHORT,
        // timeInSecForIosWeb: 1,
        // textColor: Colors.black87,
        gravity: ToastGravity.BOTTOM,
      );
      //两次点击间隔超过1秒则重新计时
      _lastPressedAt = now;
      return false;
    }
    return true;
  }
}
