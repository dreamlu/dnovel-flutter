
// int
import 'package:flutter_screenutil/flutter_screenutil.dart';

extension intExtention on int {
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

extension doubleExtention on double {
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

