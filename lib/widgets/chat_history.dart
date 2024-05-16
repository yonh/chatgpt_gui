import 'package:chatgpt_gui/states/chat_ui_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/session.dart';
import '../states/session_state.dart';

class ChatHistory extends HookConsumerWidget {
  const ChatHistory({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sessionStateNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text("History")),
      body: Center(
        child: state.when(
            data: (state) {
              return ListView(children: [
                TextButton(
                  onPressed: () {
                    GoRouter.of(context).pop();
                    ref
                        .read(sessionStateNotifierProvider.notifier)
                        .setActiveSession(null);
                    ref.read(chatUiStateProvider.notifier).state =
                        ChatUiState();
                  },
                  // icon: const Icon(Icons.add),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add),
                      const Text('New Chat'),
                    ],
                  ),
                ),
                for (var i in state.sessionList)
                  ListTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: Text("【" + i.model + "】 " + i.title,
                              style: TextStyle(
                                color: state.activeSession?.id == i.id
                                    ? Colors.blue
                                    : null,
                              )),
                        ),
                        IconButton(
                          onPressed: () {
                            // editMode.value = true;
                          },
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () {
                            _deleteConfirm(context, ref, i);
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    ),
                    onTap: () {
                      GoRouter.of(context).pop();
                      ref
                          .read(sessionStateNotifierProvider.notifier)
                          .setActiveSession(i);

                      ref.read(chatUiStateProvider.notifier).state =
                          ChatUiState(
                        requestLoading: false,
                        model: i.model,
                        isModelConfirmed: true,
                      );
                    },
                    selected: state.activeSession?.id == i.id,
                  ),
                TextButton(
                  onPressed: () {
                    GoRouter.of(context).pop();
                    ref
                        .read(sessionStateNotifierProvider.notifier)
                        .setActiveSession(null);
                    ref.read(chatUiStateProvider.notifier).state =
                        ChatUiState();
                  },
                  // icon: const Icon(Icons.add),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add),
                      const Text('New Chat'),
                    ],
                  ),
                ),
              ]);
            },
            error: (err, stack) => Text("$err"),
            loading: () => const CircularProgressIndicator()),
      ),
    );
  }
}

Future _deleteConfirm(
    BuildContext context, WidgetRef ref, Session session) async {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete"),
          content: const Text("Are you sure to delete?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                ref
                    .read(sessionStateNotifierProvider.notifier)
                    .deleteSession(session);

                Navigator.of(context).pop();
              },
              child: const Text("Delete"),
            ),
          ],
        );
      });
}
