# chatgpt_gui

A simple ChatGPT GUI Project.

## Getting Started
copy .env.example to .env and fill in the values

```bash
flutter run -d macos
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

## components
```
flutter pub add hooks_riverpod dev:custom_lint dev:riverpod_lint
flutter pub add openai_api
flutter pub add logger
```