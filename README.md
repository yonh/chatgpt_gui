# chatgpt_gui

A simple ChatGPT GUI Project.

# 功能
- [ ] update 优化请求停止UI，兼容桌面端和移动端，添加一个停止按钮在聊天框中底部，请求过程中显示，请求结束后隐藏
- [ ] feature 添加调试模式，添加日志列表页面
- [x] bug 引入 bitsdojo_window 后窗口无法拖动
- [ ] bug 切换到非首页页面，仍然无法通过标题栏拖动窗口
- [ ] bug 新建按钮在新建会话的页面下不会清空输入框内容
- [ ] bug 切换会话，聊天框内容不会清空
- [ ] bug? 可能存在有时因为删除会话，切换会话等原因，新建会话时使用的是之前的会话数据
- [ ] bug 第一次打开程序的时候配置读取的是env的，没有加载到localstorage的配置，但是打开配置页面后，就会读取到localstorage的配置
触发：从历史选择第一个会话，删除第一个会话，在新建会话，发送请求，会话当前激活状态是第一个会话的内容
删除会话后会导致激活会话的index不正确，导致会话内容错误
- [ ] 输入框支持多行输入
- [ ] 支持图片发送
- [ ] bug 请求中切换语音输入会导致请求结果不显示
- [ ] 添加错误请求处理，返回错误，添加retry按钮
- [ ] 添加loading提示，让用户知道当前的传输状态
- [ ] 可考虑使用 flutter_markdown_latex 支持数学公式

## Getting Started
copy .env.example to .env and fill in the values

```bash
flutter run -d macos
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter pub run build_runner watch --delete-conflicting-outputs
```

## components
```
flutter pub add hooks_riverpod dev:custom_lint dev:riverpod_lint
flutter pub add openai_api
flutter pub add logger
flutter pub add envied dev:envied_generator dev:build_runner
flutter pub add freezed_annotation
flutter pub add --dev freezed
flutter pub add json_annotation
flutter pub add --dev json_serializable
flutter pub add markdown_widget
flutter pub add flutter_math_fork markdown
flutter pub add floor dev:floor_generator
flutter pub add dev:custom_lint dev:riverpod_lint riverpod_annotation  dev:riverpod_generator
flutter pub add go_router
flutter pub add record path_provider
flutter pub add flutter_launcher_icons
flutter pub add screenshot
flutter pub add file_picker
flutter pub add share_plus
```

## build_runner
*.freezed.dart 是工具自动生成的，如果不希望这类文件扰乱我们的代码修改记录，可以将其添加到 `.gitginore` 文件。

`flutter pub run build_runner build --delete-conflicting-outputs` 只会运行一次，如果我们不希望每次修改都重新运行该命令，build_runner 还提供了另外一个选择 watch。使用这个命令，build_runner 会自动监听文件的修改，自动生成代码。

`flutter pub run build_runner watch --delete-conflicting-outputs`

# change icon
生成配置文件后，修改 flutter_launcher_icons.yaml 文件更改icon路径
```
flutter pub run flutter_launcher_icons:generate
flutter pub run flutter_launcher_icons
```

# 一些项目相关的问题
导出数据位置：
    C:\Users\[用户名]\Documents\exports

问题：
- [ ] 1. 如何手动更新数据库结构 
    sql文件在 ~/Library/Containers/com.example.chatgptGui/Data/.dart_tool/sqflite_common_ffi/databases/app_database.db
- [x] 2. 如何通过migration更新数据库结构
        通过 databaseBuilder 的 addMigrations 方法添加 Migration
- [x] 3. 报错 Envied can only handle types
```
         Envied can only handle types such as `int`, `double`, `num`, `bool` and `String`. Type `InvalidType` is not one of them.
         package:chatgpt_gui/env/env.dart:8:16
         ╷
         8 │   static const apiKey = _Env.apiKey;
         │                ^^^^^^
         ╵
  > 解决: 添加类型 const String apiKey
  > flutter clean
  > flutter pub run build_runner build --delete-conflicting-outputs
```
- [x] 4. path_provider 需要 10.15 以上系统版本，所以需要更新下配置文件 macos/Runner/Configs/AppInfo.xcconfig
    `MACOSX_DEPLOYMENT_TARGET = 10.15`
可能提示：Error: The plugin "record_macos" requires a higher minimum macOS deployment version than your application is targeting.
         To build, increase your application's deployment target to at least 10.15 as described at https://docs.flutter.dev/deployment/macos
         Error: Error running pod install
需要调整 `macos/Podfile` 将 `platform :osx, '10.14'` 修改为 `platform :osx, '10.15'`

- [x] 5. 录音权限
```
# 编辑文件
# macos/Runner/DebugProfile.entitlements
<key>com.apple.security.device.audio-input</key>
<true />

# macos/Runner/Release.entitlements
<key>com.apple.security.device.audio-input</key>
<true />

# 安卓：需要修改android/app/build.gradle的 minSdkVersion >= 19

# ios：
# ios/Runner/Info.plist
<key>NSMicrophoneUsageDescription</key>
<string>We need to access to the microphone to record audio file</string>
```
- [x] 6. windows 上录音提示找不到文件 [代码目录]\build\windows\x64\runner\Debug\fmedia\fmedia.exe
    可以将`C:\Users\用户名\AppData\Local\Pub\Cache\hosted\pub.dev\record_windows-0.7.1\windows\fmedia` 复制到 `[代码目录]\build\windows\x64\runner\Debug\fmedia`
    或者执行 flutter build windows 到 `build\windows\x64\runner\Release\` 目录下复制

- [x] 7. localstorage 存储目录
    ### mac: ~/Library/Containers/<PRODUCT_BUNDLE_IDENTIFIER>/Data/Documents
    在 Flutter 中，`PRODUCT_BUNDLE_IDENTIFIER` 是在 `iOS` 和 `macOS` 项目的配置文件中设置的。
    这个值是应用的唯一标识符，通常在创建项目时自动生成，但你可以在项目创建后手动修改它。
    对于 `iOS`，你可以在以下文件中找到并修改它：  `ios/Runner.xcodeproj/project.pbxproj` 
    对于 `macOS`，你可以在以下文件中找到并修改它：  `macos/Runner/Configs/AppInfo.xcconfig`


- 使用 bitsdojo_window 后无窗口显示
因为官方文档提到需要添加函数, 移除参数 `BDW_HIDE_ON_STARTUP` 即可
```
override func bitsdojo_window_configure() -> UInt {
    return BDW_CUSTOM_FRAME | BDW_HIDE_ON_STARTUP
}
```