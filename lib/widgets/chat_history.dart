import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/session.dart';
import '../states/session_state.dart';
import '../utils.dart';

class ChatHistoryScreen extends StatelessWidget {
  const ChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("History")),
      body: const ChatHistoryWindow(),
    );
  }
}

class ChatHistoryWindow extends HookConsumerWidget {
  const ChatHistoryWindow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sessionStateNotifierProvider);
    return Center(
      child: state.when(
          data: (state) {
            return ListView(children: [
              for (var i in state.sessionList) ChatHistoryItemWidget(i: i),
            ]);
          },
          error: (err, stack) => Text("$err"),
          loading: () => const CircularProgressIndicator()),
    );
  }
}

class ChatHistoryItemWidget extends HookConsumerWidget {
  const ChatHistoryItemWidget({
    super.key,
    required this.i,
  });

  final Session i;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sessionStateNotifierProvider).valueOrNull;
    final editMode = useState(false);
    final controller = useTextEditingController();
    controller.text = i.title;
    return ListTile(
      title: editMode.value
          ? Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    final text = controller.text;
                    if (text.trim().isNotEmpty) {
                      ref
                          .read(sessionStateNotifierProvider.notifier)
                          .upsertSession(
                            i.copyWith(title: text.trim()),
                          );
                      editMode.value = false;
                    }
                  },
                  icon: const Icon(Icons.save),
                ),
                IconButton(
                  onPressed: () {
                    editMode.value = false;
                  },
                  icon: const Icon(Icons.cancel),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Text(
                    i.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    editMode.value = true;
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
        ref.read(sessionStateNotifierProvider.notifier).setActiveSession(i);
        if (!isDesktop()) Navigator.of(context).pop();
      },
      selected: state?.activeSession?.id == i.id,
    );
  }
}

class NewChatButton extends HookConsumerWidget {
  const NewChatButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: SizedBox(
        height: 40,
        child: OutlinedButton.icon(
          style: ButtonStyle(
            textStyle: WidgetStateProperty.all(
              Theme.of(context).textTheme.titleMedium,
            ),
            iconSize: WidgetStateProperty.all(Theme.of(context).iconTheme.size),
            alignment: Alignment.centerLeft,
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            iconColor: WidgetStateProperty.all(
                Theme.of(context).textTheme.titleMedium?.color),
            foregroundColor: WidgetStateProperty.all(
                Theme.of(context).textTheme.titleMedium?.color),
          ),
          onPressed: () {
            ref
                .read(sessionStateNotifierProvider.notifier)
                .setActiveSession(null);
          },
          icon: const Icon(
            Icons.add,
            size: 16,
          ),
          label: const Text("New chat"),
        ),
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
