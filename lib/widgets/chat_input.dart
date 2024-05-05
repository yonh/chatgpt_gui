import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../injection.dart';
import '../models/message.dart';
import '../models/session.dart';
import '../states/chat_ui_state.dart';
import '../states/message_state.dart';
import '../states/session_state.dart';

class UserInputWidget extends HookConsumerWidget {
  const UserInputWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatUiState = ref.watch(chatUiStateProvider);
    final _textController = useTextEditingController();
    return TextField(
      enabled: !chatUiState.requestLoading,
      controller: _textController,
      decoration: InputDecoration(
          hintText: 'Type a message', // 显示在输入框内的提示文字
          suffixIcon: IconButton(
            onPressed: () {
              // 这里处理发送事件
              if (_textController.text.isNotEmpty) {
                _sendMessage(ref, _textController);
              }
            },
            icon: const Icon(
              Icons.send,
            ),
          )),
    );
  }

  Message _createMessage(
    String content, {
    String? id,
    bool isUser = true,
    int? sessionId,
  }) {
    final message = Message(
      id: id ?? uuid.v4(),
      content: content,
      isUser: isUser,
      timestamp: DateTime.now(),
      sessionId: sessionId ?? 0,
    );
    return message;
  }

  _sendMessage(WidgetRef ref, TextEditingController controller) async {
    final content = controller.text;
    final uiState = ref.watch(chatUiStateProvider);
    Message message = _createMessage(content);
    var active = ref.watch(activeSessionProvider);
    var sessionId = active?.id ?? 0;
    ref.read(chatUiStateProvider.notifier).confirmModel(); // 确认模型

    if (sessionId <= 0) {
      active = Session(title: content, model: uiState.model);
      // final id = await db.sessionDao.upsertSession(active);
      active = await ref
          .read(sessionStateNotifierProvider.notifier)
          .upsertSession(active);
      sessionId = active.id!;
      ref
          .read(sessionStateNotifierProvider.notifier)
          .setActiveSession(active.copyWith(id: sessionId));
    }

    ref.read(messageProvider.notifier).upsertMessage(
          message.copyWith(sessionId: sessionId),
        ); // 添加消息
    controller.clear();
    _requestChatGPT(ref, content, sessionId: sessionId);

    // final content = controller.text;
    // final id = uuid.v4();
    // final message = Message(
    //     id: id,
    //     content: content,
    //     isUser: true,
    //     timestamp: DateTime.now(),
    //     sessionId: 1);
    // // messages.add(message);
    // ref.read(messageProvider.notifier).upsertMessage(message);
    // controller.clear();
    // _requestChatGPT(ref, content);
  }

  _requestChatGPT(WidgetRef ref, String content, {int? sessionId}) async {
    final uiState = ref.watch(chatUiStateProvider);
    ref.read(chatUiStateProvider.notifier).setRequestLoading(true);
    final messages = ref.watch(activeSessionMessagesProvider);
    final activeSession = ref.watch(activeSessionProvider);
    try {
      final id = uuid.v4();
      //final res = await chatgpt.sendChat(content);
      await chatgpt.streamChat(messages,
          model: activeSession?.model ?? uiState.model, onSuccess: (text) {
        // final message = Message(
        //     id: id,
        //     content: text,
        //     isUser: false,
        //     timestamp: DateTime.now(),
        //     sessionId: 1);
        final message =
            _createMessage(text, id: id, isUser: false, sessionId: sessionId);

        ref.read(messageProvider.notifier).upsertMessage(message);
      });
      //final text = res.choices.first.message?.content ?? "";
      // final message = Message(
      //     id: id, content: text, isUser: false, timestamp: DateTime.now());
      // ref.read(messageProvider.notifier).addMessage(message);
    } catch (err) {
      logger.e("request ChatGPT error:", error: err);
    } finally {
      ref.read(chatUiStateProvider.notifier).setRequestLoading(false);
    }
  }
}
