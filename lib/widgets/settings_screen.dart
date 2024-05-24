import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';

import '../env/env.dart';
import '../injection.dart';
import '../services/local_store.dart';
import '../utils.dart';
import 'log_viewer_page.dart'; // Add this line

final localStoreServiceProvider =
    Provider<LocalStoreService>((ref) => LocalStoreService());

final settingsProvider = StateNotifierProvider<SettingsNotifier, Settings>(
    (ref) => SettingsNotifier(ref.read(localStoreServiceProvider)));

class SettingsNotifier extends StateNotifier<Settings> {
  final LocalStoreService _localStoreService;
  SettingsNotifier(this._localStoreService)
      : super(Settings(
            apiKey: Env.apiKey ?? '',
            baseUrl: Env.baseUrl ?? '',
            httpProxy: Env.httpProxy ?? '',
            themeMode: ThemeMode.system,
            language: 'system',
            logLevel: Level.info)) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final apiKey = await _localStoreService.getItem<String>('API Key');
    final baseUrl = await _localStoreService.getItem<String>('Base URL');
    final httpProxy = await _localStoreService.getItem<String>('HTTP Proxy');
    final themeMode = await _localStoreService.getItem<String>('Theme Mode');
    final language =
        await _localStoreService.getItem<String>('Language'); // 从本地存储中读取语言设置
    final logLevel = await _localStoreService.getItem<String>('Log Level');

    // 如果localStorage中读取不到值，就使用默认值
    state = Settings(
      apiKey: apiKey ?? state.apiKey,
      baseUrl: baseUrl ?? state.baseUrl,
      httpProxy: httpProxy ?? state.httpProxy,
      themeMode: themeMode == 'ThemeMode.system'
          ? ThemeMode.system
          : themeMode == 'ThemeMode.light'
              ? ThemeMode.light
              : ThemeMode.dark,
      language: language ?? (state.language ?? 'en'),
      logLevel: logLevel == 'Level.debug'
          ? Level.debug
          : logLevel == 'Level.info'
              ? Level.info
              : logLevel == 'Level.warning'
                  ? Level.warning
                  : Level.off,
    );

    chatgpt.updateClientConfig(state);
  }

  Future<void> updateLogLevel(Level logLevel) async {
    state = Settings(
      apiKey: state.apiKey,
      baseUrl: state.baseUrl,
      httpProxy: state.httpProxy,
      themeMode: state.themeMode,
      language: state.language,
      logLevel: logLevel,
    );

    await _localStoreService.setItem('Log Level', logLevel.toString());
    // logger = Logger(level: logLevel ?? Level.off);
    logger =
        Logger(output: memoryLogOutput, level: logLevel ?? Level.off); // 更新日志级别
  }

  Future<void> updateThemeMode(ThemeMode themeMode) async {
    state = Settings(
        apiKey: state.apiKey,
        baseUrl: state.baseUrl,
        httpProxy: state.httpProxy,
        themeMode: themeMode,
        language: state.language,
        logLevel: state.logLevel);

    await _localStoreService.setItem('Theme Mode', themeMode.toString());
  }

  Future<void> updateSetting(String key, String value) async {
    state = Settings(
        apiKey: key == 'API Key' ? value : state.apiKey,
        baseUrl: key == 'Base URL' ? value : state.baseUrl,
        httpProxy: key == 'HTTP Proxy' ? value : state.httpProxy,
        themeMode: state.themeMode,
        language: state.language,
        logLevel: state.logLevel);

    await _localStoreService.setItem(key, value);
    chatgpt.updateClientConfig(state);
  }

  Future<void> updateLanguage(String language) async {
    state = Settings(
      apiKey: state.apiKey,
      baseUrl: state.baseUrl,
      httpProxy: state.httpProxy,
      themeMode: state.themeMode,
      language: language,
      logLevel: state.logLevel,
    );

    await _localStoreService.setItem('Language', language);
  }
}

class Settings {
  final String apiKey;
  final String baseUrl;
  final String httpProxy;
  final ThemeMode themeMode;
  final String language;
  final Level? logLevel;

  Settings({
    required this.apiKey,
    required this.baseUrl,
    required this.httpProxy,
    required this.themeMode,
    required this.language,
    this.logLevel,
  });
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: const SettingsWindow(),
    );
  }
}

class SettingsWindow extends HookConsumerWidget {
  const SettingsWindow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    final items = [
      {'title': 'API Key', 'value': settings.apiKey},
      {'title': 'Base URL', 'value': settings.baseUrl},
      {'title': 'HTTP Proxy', 'value': settings.httpProxy},
    ];

    return ListView(
      children: [
        // 日志级别设置 => debug,info,warning, off
        logLevelSetting(settings, ref, context),
        // 查看日志 => 查看日志文件
        ListTile(
          title: Text(AppLocalizations.of(context)!.view_log),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            // Navigator.of(context).pushNamed('/log');
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => LogViewerPage(),
              ),
            );
          },
        ),

        ...items.map((item) => apiSetting(item, context, ref)),
        themeSetting(settings, ref, context),
        languageSetting(settings, ref, context),
      ],
    );
  }

  // debug,info,warning, off, 使用下拉列表形式选择日志类型
  ListTile logLevelSetting(
      Settings settings, WidgetRef ref, BuildContext context) {
    return ListTile(
      title: Text('Log Level'),
      subtitle: Row(
        children: [
          Expanded(
            child: DropdownButton<Level>(
              value: settings.logLevel,
              onChanged: (Level? value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateLogLevel(value);
                }
              },
              items: Level.values.map((Level level) {
                return DropdownMenuItem<Level>(
                  value: level,
                  child: Text(level.toString().split('.').last),
                );
              }).toList(),
            ),
          ),
        ],
        // children: Level.values.map((level) {
        //   return Expanded(
        //     child: RadioListTile<Level>(
        //       title: Text(level.toString().split('.').last,
        //           style: TextStyle(fontSize: 12)),
        //       value: level,
        //       groupValue: settings.logLevel,
        //       selected: settings.logLevel == level,
        //       onChanged: (value) {
        //         // if (value != null) {
        //         //   ref.read(settingsProvider.notifier).updateLogLevel(value);
        //         // }
        //       },
        //     ),
        //   );
        // }).toList(),
      ),
    );
  }

  ListTile apiSetting(
      Map<String, String> item, BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(item['title'] ?? 'Unknown'),
      subtitle: Text(item['value'] ?? 'Unknown'),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () async {
        final newValue = await showEditor(
            context, item['title'] ?? 'Unknown', item['value'] ?? '');
        if (newValue != null) {
          ref
              .read(settingsProvider.notifier)
              .updateSetting(item['title']!, newValue);
        }
      },
    );
  }

  ListTile themeSetting(
      Settings settings, WidgetRef ref, BuildContext context) {
    return ListTile(
      title: Text(AppLocalizations.of(context)!.theme_mode),
      subtitle: Row(
        children: [
          Expanded(
            child: RadioListTile<ThemeMode>(
              title: Text(AppLocalizations.of(context)!.theme_mode_system,
                  style: TextStyle(fontSize: 12)),
              value: ThemeMode.system,
              groupValue: settings.themeMode,
              selected: settings.themeMode == ThemeMode.system,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateThemeMode(value);
                }
              },
            ),
          ),
          Expanded(
            child: RadioListTile<ThemeMode>(
              title: Text(AppLocalizations.of(context)!.theme_mode_light,
                  style: TextStyle(fontSize: 12)),
              value: ThemeMode.light,
              groupValue: settings.themeMode,
              selected: settings.themeMode == ThemeMode.light,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateThemeMode(value);
                }
              },
            ),
          ),
          Expanded(
            child: RadioListTile<ThemeMode>(
              title: Text(AppLocalizations.of(context)!.theme_mode_dark,
                  style: TextStyle(fontSize: 12)),
              value: ThemeMode.dark,
              groupValue: settings.themeMode,
              selected: settings.themeMode == ThemeMode.dark,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateThemeMode(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  ListTile languageSetting(
      Settings settings, WidgetRef ref, BuildContext context) {
    return ListTile(
      title: Text(AppLocalizations.of(context)!.language),
      subtitle: Row(
        children: [
          Expanded(
            child: RadioListTile<String?>(
              title: const Text('System', style: TextStyle(fontSize: 12)),
              value: 'system',
              groupValue: settings.language,
              selected: settings.language == 'system',
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateLanguage(value);
                }
              },
            ),
          ),
          Expanded(
            child: RadioListTile<String>(
              title: const Text('English', style: TextStyle(fontSize: 12)),
              value: 'en',
              groupValue: settings.language,
              selected: settings.language == 'en',
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateLanguage(value);
                }
              },
            ),
          ),
          Expanded(
            child: RadioListTile<String>(
              title: const Text('中文', style: TextStyle(fontSize: 12)),
              value: 'zh',
              groupValue: settings.language,
              selected: settings.language == 'zh',
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateLanguage(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> showEditor(
      BuildContext context, String title, String initialValue) async {
    final controller = TextEditingController(text: initialValue);
    return await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        actions: [
          TextButton(
            child: Text(AppLocalizations.of(context)!.cancel),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text(AppLocalizations.of(context)!.ok),
            onPressed: () {
              final text = controller.text;
              controller.clear();
              Navigator.of(context).pop(text);
            },
          ),
        ],
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.enter_new_value),
        ),
      ),
    );
  }
}
