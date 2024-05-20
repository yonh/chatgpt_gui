import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../injection.dart';
import '../models/message.dart';
import '../models/session.dart';
import '../states/chat_ui_state.dart';
import '../states/message_state.dart';
import '../states/session_state.dart';
import '../utils.dart';

class UserInputWidget extends HookConsumerWidget {
  UserInputWidget({
    super.key,
  });

  final ValueNotifier<bool> _isHovered = ValueNotifier<bool>(false);

  Widget requestingHover(BuildContext context, WidgetRef ref) {
    return MouseRegion(
      onEnter: (event) => _isHovered.value = true,
      onExit: (event) => _isHovered.value = false,
      cursor: SystemMouseCursors.click,
      child: ValueListenableBuilder<bool>(
          valueListenable: _isHovered,
          builder: (context, isHovered, child) {
            if (isHovered) {
              return IconButton(
                  onPressed: () {
                    // 这里处理取消请求的逻辑
                    _stopRequest(ref);
                    print("cancel request");
                  },
                  icon: const Icon(Icons.stop));
            } else {
              return const CircularProgressIndicator(strokeWidth: 2);
            }
          }),
    );

    // child: GestureDetector(
    //   onTap: () {
    //     // 这里处理取消请求的逻辑
    //     //_cancelRequest(ref);
    //     print("cancel");
    //   },
    //   child: const Center(
    //     child: SizedBox(
    //       width: 24,
    //       height: 24,
    //       child: CircularProgressIndicator(
    //         strokeWidth: 2,
    //       ),
    //     ),
    //   ),
    // ),
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatUiState = ref.watch(chatUiStateProvider);
    final _textController = useTextEditingController();

    return KeyboardListener(
        onKeyEvent: (event) {
          if (event.logicalKey == LogicalKeyboardKey.enter) {
            _sendMessage(ref, _textController);
          }
        },
        focusNode: FocusNode(),
        child: TextField(
          controller: _textController,
          decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.type_a_message,
              suffixIcon: SizedBox(
                  width: 40,
                  child: chatUiState.requestLoading
                      ? requestingHover(context, ref)
                      : IconButton(
                          onPressed: () {
                            // 这里处理发送事件
                            if (_textController.text.isNotEmpty) {
                              _sendMessage(ref, _textController);
                            }
                          },
                          icon: const Icon(Icons.send)))),
        ));
  }

  Widget build2(BuildContext context, WidgetRef ref) {
    final chatUiState = ref.watch(chatUiStateProvider);
    final _textController = useTextEditingController();

    return KeyboardListener(
        onKeyEvent: (event) {
          if (event.logicalKey == LogicalKeyboardKey.enter) {
            _sendMessage(ref, _textController);
          }
        },
        focusNode: FocusNode(),
        child: TextField(
          enabled: !_textController.text.isEmpty,
          controller: _textController,
          decoration: InputDecoration(
              // contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              // border: OutlineInputBorder(
              //   borderRadius: BorderRadius.circular(8.0),
              // ),
              hintText: AppLocalizations.of(context)!.type_a_message,
              suffixIcon: SizedBox(
                  width: 40,
                  child: chatUiState.requestLoading
                      ? const Center(
                          child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ))
                      : IconButton(
                          onPressed: () {
                            // 这里处理发送事件
                            _sendMessage(ref, _textController);
                          },
                          icon: const Icon(Icons.send)))),
        ));
  }
}

class ChatInputWidget extends HookConsumerWidget {
  const ChatInputWidget({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceMode = useState(false);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              voiceMode.value = !voiceMode.value;
            },
            icon: Icon(voiceMode.value ? Icons.keyboard : Icons.keyboard_voice),
          ),
          Expanded(
            child:
                voiceMode.value ? const AudioInputWidget() : UserInputWidget(),
          ),
        ],
      ),
    );
  }
}

class AudioInputWidget extends HookConsumerWidget {
  const AudioInputWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recording = useState(false);

    return GestureDetector(
      onLongPressStart: (details) {
        recording.value = true;
        recorder.start();
      },
      onLongPressEnd: (details) async {
        recording.value = false;

        final path = await recorder.stop();
        if (path != null) {
          try {
            final text = await chatgpt.speechToText(path);
            if (text.trim().isNotEmpty) {
              __sendMessage(ref, text);
            }
          } catch (err) {
            logger.e("err: $err", error: err);
          }
        }
      },
      onLongPressCancel: () {
        recording.value = false;
        recorder.stop();
      },
      child: ElevatedButton(
        onPressed: () {},
        child: Text(recording.value ? "Recording..." : "Hold to speak"),
      ),
    );
  }
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
  if (content.isEmpty) {
    return;
  }
  controller.clear();
  return __sendMessage(ref, content);
}

__sendMessage(WidgetRef ref, String content) async {
  Message message = _createMessage(content);
  final uiState = ref.watch(chatUiStateProvider);
  var active = ref.watch(activeSessionProvider);
  ref.read(chatUiStateProvider.notifier).confirmModel(); // 确认模型

  var sessionId = active?.id ?? 0;
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

  _requestChatGPT(ref, content, sessionId: sessionId);
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
      final message =
          _createMessage(text, id: id, isUser: false, sessionId: sessionId);

      ref.read(messageProvider.notifier).upsertMessage(message);
    });
  } catch (err) {
    logger.e("request ChatGPT error:", error: err);
  } finally {
    ref.read(chatUiStateProvider.notifier).setRequestLoading(false);
  }
}

_stopRequest(WidgetRef ref) {
  ref.read(chatUiStateProvider.notifier).setRequestLoading(false);
  chatgpt.cancelStreamChat();
}
