import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../env/env.dart';
import '../injection.dart';
import '../services/local_store.dart';

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
            httpProxy: Env.httpProxy ?? '')) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final apiKey = await _localStoreService.getItem<String>('API Key');
    final baseUrl = await _localStoreService.getItem<String>('Base URL');
    final httpProxy = await _localStoreService.getItem<String>('HTTP Proxy');

    // 如果localStorage中读取不到值，就使用默认值
    state = Settings(
      apiKey: apiKey ?? state.apiKey,
      baseUrl: baseUrl ?? state.baseUrl,
      httpProxy: httpProxy ?? state.httpProxy,
    );

    chatgpt.updateClientConfig(state);
  }

  Future<void> updateSetting(String key, String value) async {
    state = Settings(
        apiKey: key == 'API Key' ? value : state.apiKey,
        baseUrl: key == 'Base URL' ? value : state.baseUrl,
        httpProxy: key == 'HTTP Proxy' ? value : state.httpProxy);

    await _localStoreService.setItem(key, value);
    chatgpt.updateClientConfig(state);
  }
}

class Settings {
  final String apiKey;
  final String baseUrl;
  final String httpProxy;

  Settings(
      {required this.apiKey, required this.baseUrl, required this.httpProxy});
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
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
    return ListView.separated(
      itemBuilder: (context, index) {
        final item = items[index];
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
      },
      separatorBuilder: (context, index) => const Divider(),
      itemCount: items.length,
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
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('OK'),
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
          decoration: InputDecoration(hintText: 'Enter new value'),
        ),
      ),
    );
  }
}
