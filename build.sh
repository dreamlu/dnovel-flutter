#!/bin/bash
# android 发布
# 打包好的发布APK位于<app dir>/build/app/outputs/apk/app-release.apk
flutter build apk --build-name=2.2.1 --build-number=2

# ios