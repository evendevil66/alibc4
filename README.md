# alibc4

[![Pub Version](https://img.shields.io/pub/v/alibc4)](https://pub.dev/packages/alibc4.svg)
[![GitHub Repo](https://img.shields.io/badge/GitHub-Repo-brightgreen.svg)](https://github.com/evndevil66/alibc4)
![GitHub license](https://img.shields.io/badge/license-Apache%202.0-blue.svg)


alibc4 是一个用于在 Flutter 中集成阿里百川 4.x SDK 的插件。免费的star支持一下。

## 版本信息

- 安卓 SDK 版本: 4.1.0.5
- iOS SDK 版本: 4.1.0.3

## 安装

在你的 `pubspec.yaml` 文件中添加 alibc4 依赖：
```yaml
#git集成，推荐使用此方式，包含ios和安卓
dependencies:
  alibc4:
    git:
      url: git://github.com/evendevil66/alibc4.git
```

```yaml
#pub集成，因包体大小限制，未集成ios资源，可自行下载ios sdk后手动导入至插件的ios工程下（bundle、framework）
dependencies:
  alibc4: ^1.0.0
```

你可以通过命令行工具 `flutter pub get` 来安装。

## 使用

### 初始化及生成安全图片

请通过阿里百川控制台获取v6安全图片并改名为'yw_1222_baichuan.jpg'

#### 安卓

自行下载并解压SDK，Android工程的app/libs目录下
安卓安全图片放置在Android工程目录main下的res/drawable/目录
安卓还需要在res/raw下创建keep.xml文件防止安全图片被压缩

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources xmlns:tools="http://schemas.android.com/tools"
    tools:keep="@drawable/yw_1222_baichuan*" />
```

并在gradle.properties中设置

```properties
android.enableResourceOptimizations=false
```

在AndroidManifest.xml中添加以下内容

```xml
<queries>
    <package android:name="com.taobao.taobao" />
    <package android:name="com.tmall.wireless" />
</queries>


```

在Application中添加以下内容

```text
tools:replace="android:label,android:allowBackup,android:name"
android:allowBackup="true"

<activity
android:name="com.alibaba.alibclinkpartner.smartlink.ALPEntranceActivity"
android:exported="false">
</activity>

<receiver
android:name="com.alibaba.baichuan.trade.biz.login.LoginBroadcastReceiver"
android:exported="false">
</receiver>
```


#### IOS

iOS安全图片直接放置在iOS工程Runner目录下
下载阿里百川demo并将mtopsdk_configuration.plist一并放入Runner目录下

### 初始化

在你的 Dart 代码中，你可以通过 `Alibc4.init` 初始化 SDK。

```dart
import 'package:alibc4/alibc4.dart';

final alibc = Alibc4();

alibc.init().then((map) {
    setState(() {
        result = map.toString();
    });
});

//必须进行初始化才能使用其他功能

//其他使用方法可参见example的main.dart代码
```

## 测试图
![Image text](https://raw.githubusercontent.com/evendevil66/alibc4/master/images/example.jpg)

