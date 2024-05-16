import 'package:chatgpt_gui/states/chat_ui_state.dart';
import 'package:chatgpt_gui/states/message_state.dart';
import 'package:chatgpt_gui/widgets/chat_gpt_model_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../states/session_state.dart';
import 'chat_input.dart';
import 'chat_message_list.dart';

// 我们在创建界面时，为了快速实现页面效果，选择使用了简单的StatelessWidget组件。
// 而StatelessWidget 是不可变的，这意味着它们的属性在对象创建时就被固定了，并且在整个生命周期内保持不变。
// 当父组件的状态发生变化时，StatelessWidget可能会被销毁并重新创建。
// class ChatScreen extends StatelessWidget {
class ChatScreen extends HookConsumerWidget {
  ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final messages = ref.watch(messageProvider); // 获取数据
    final activeSession = ref.watch(activeSessionProvider);
    final messages = ref.watch(activeSessionMessagesProvider);
    final ChatUiState chatUiState = ref.watch(chatUiStateProvider);
    // return Container();
    return Scaffold(
        appBar: AppBar(
          title: Text(
              'Chat - Session ID: ${activeSession?.id ?? "None"}, Message Count: ${messages.length}'),
          actions: [
            IconButton(
              onPressed: () {
                GoRouter.of(context).push('/history');
              },
              icon: const Icon(Icons.history),
            ),
            IconButton(
              onPressed: () {
                ref
                    .read(sessionStateNotifierProvider.notifier)
                    .setActiveSession(null);
                ref.read(chatUiStateProvider.notifier).state = ChatUiState();
              },
              icon: const Icon(Icons.add),
            ),
            IconButton(
              onPressed: () {
                GoRouter.of(context).push('/settings');
              },
              icon: const Icon(Icons.settings),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              GptModelWidget(
                  active: chatUiState.model,
                  isModelConfirmed: chatUiState.isModelConfirmed,
                  onModelChanged: (model) {
                    ref.read(chatUiStateProvider.notifier).model = model;
                  }),
              const Expanded(
                // child: ListView.separated(
                //   itemBuilder: (context, index) {
                //     return MessageItem(message: messages[index]);
                //   },
                //   itemCount: messages.length, // 消息数量
                //   separatorBuilder: (context, index) => const Divider(
                //     // 分割线
                //     height: 16,
                //   ),
                // ),
                child: ChatMessageList(),
              ),
              // const UserInputWidget(),
              const ChatInputWidget(),
            ],
          ),
        ));
  }
}
