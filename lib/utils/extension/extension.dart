
// int
import 'package:flutter_screenutil/flutter_screenutil.dart';

extension widthExtention on int {
  get w {
    return ScreenUtil().setWidth(this);
  }

  get h {
    return ScreenUtil().setWidth(this);
  }

  get sp {
    return ScreenUtil().setSp(this);
  }
}
