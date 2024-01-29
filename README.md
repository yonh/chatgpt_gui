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
```

## build_runner
*.freezed.dart 是工具自动生成的，如果不希望这类文件扰乱我们的代码修改记录，可以将其添加到 `.gitginore` 文件。

`flutter pub run build_runner build --delete-conflicting-outputs` 只会运行一次，如果我们不希望每次修改都重新运行该命令，build_runner 还提供了另外一个选择 watch。使用这个命令，build_runner 会自动监听文件的修改，自动生成代码。

`flutter pub run build_runner watch --delete-conflicting-outputs`


问题：
- [ ] 1. 如何手动更新数据库结构
- [x] 2. 如何通过migration更新数据库结构
        通过 databaseBuilder 的 addMigrations 方法添加 Migration