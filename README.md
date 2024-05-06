# chatgpt_gui

A simple ChatGPT GUI Project.

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

```

## build_runner
*.freezed.dart 是工具自动生成的，如果不希望这类文件扰乱我们的代码修改记录，可以将其添加到 `.gitginore` 文件。

`flutter pub run build_runner build --delete-conflicting-outputs` 只会运行一次，如果我们不希望每次修改都重新运行该命令，build_runner 还提供了另外一个选择 watch。使用这个命令，build_runner 会自动监听文件的修改，自动生成代码。

`flutter pub run build_runner watch --delete-conflicting-outputs`


问题：
- [ ] 1. 如何手动更新数据库结构
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

