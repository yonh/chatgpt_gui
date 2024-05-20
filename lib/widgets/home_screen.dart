import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../states/chat_ui_state.dart';
import '../states/session_state.dart';
import 'chat_history.dart';
import 'chat_screen.dart';
import 'desktop.dart';
import 'settings_screen.dart';

class DesktopHomeScreen extends StatelessWidget {
  const DesktopHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: DesktopWindow(
      child: Row(
        children: [
          SizedBox(
              width: 240,
              child: Column(
                children: [
                  SizedBox(height: 15),
                  NewChatButton(),
                  const Divider(),
                  Expanded(
                    child: ChatHistoryWindow(),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: Text(AppLocalizations.of(context)!.settings),
                    // title: Text(AppLocalizations.of(context)!.settings),
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                                title: Text(
                                    AppLocalizations.of(context)!.settings),
                                content: SizedBox(
                                  height: 400,
                                  width: 500,
                                  child: SettingsWindow(),
                                ));
                          });
                    },
                  )
                ],
              )
              //child: ChatHistoryWindow(),
              ),
          const VerticalDivider(
            color: Colors.grey, // 设置分割线的颜色
            width: 1, // 设置分割线的宽度
          ),
          Expanded(child: ChatScreen()),
        ],
      ),
    ));
  }
}

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.chat),
        actions: [
          // IconButton(
          //   onPressed: () {
          //     GoRouter.of(context).push('/history');
          //   },
          //   icon: const Icon(Icons.history),
          // ),
          IconButton(
            onPressed: () {
              ref
                  .read(sessionStateNotifierProvider.notifier)
                  .setActiveSession(null);
              ref.read(chatUiStateProvider.notifier).state = ChatUiState();
            },
            icon: const Icon(Icons.add),
          ),
          // IconButton(
          //     onPressed: () {
          //       GoRouter.of(context).push('/settings');
          //     },
          //     icon: const Icon(Icons.settings)),
        ],
      ),
      body: ChatScreen(),
      drawer: Drawer(
          child: Column(children: [
        SizedBox(
          height: 90,
          child: DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Container(
              width: double.infinity,
              color: Theme.of(context).primaryColor,
              child: const Text(
                "Chat History",
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
            ),
          ),
        ),
        Expanded(
          child: const ChatHistoryWindow(),
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: Text(AppLocalizations.of(context)!.settings),
          onTap: () {
            Navigator.of(context).pop();
            GoRouter.of(context).push('/settings');
          },
        ),
      ])),
    );
  }
}
