import 'package:chatgpt_gui/injection.dart';
import 'package:chatgpt_gui/states/chat_ui_state.dart';
import 'package:chatgpt_gui/states/message_state.dart';
import 'package:flutter/material.dart';
import 'package:chatgpt_gui/models/message.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../states/message_state.dart';
import '../services/chatgpt_service.dart';

// 我们在创建界面时，为了快速实现页面效果，选择使用了简单的StatelessWidget组件。
// 而StatelessWidget 是不可变的，这意味着它们的属性在对象创建时就被固定了，并且在整个生命周期内保持不变。
// 当父组件的状态发生变化时，StatelessWidget可能会被销毁并重新创建。
// class ChatScreen extends StatelessWidget {
class ChatScreen extends HookConsumerWidget {
  ChatScreen({super.key});

  final _textController = TextEditingController();

  // final List<Message> messages = [
  //   Message(content: "Hello", isUser: true, timestamp: DateTime.now()),
  //   Message(content: "How are you?", isUser: false, timestamp: DateTime.now()),
  //   Message(
  //       content: "Fine,Thank you. And you?",
  //       isUser: true,
  //       timestamp: DateTime.now()),
  //   Message(content: "I am fine.", isUser: false, timestamp: DateTime.now()),
  // ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(messageProvider); // 获取数据
    final ChatUiState chatUiState = ref.watch(chatUiStateProvider);
    // return Container();
    return Scaffold(
        appBar: AppBar(
          title: const Text('Chat'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    return MessageItem(message: messages[index]);
                  },
                  itemCount: messages.length, // 消息数量
                  separatorBuilder: (context, index) => const Divider(
                    // 分割线
                    height: 16,
                  ),
                ),
              ),
              TextField(
                enabled: !chatUiState.requestLoading,
                controller: _textController,
                decoration: InputDecoration(
                    hintText: 'Type a message', // 显示在输入框内的提示文字
                    suffixIcon: IconButton(
                      onPressed: () {
                        // 这里处理发送事件
                        if (_textController.text.isNotEmpty) {
                          _sendMessage(ref, _textController.text);
                        }
                      },
                      icon: const Icon(
                        Icons.send,
                      ),
                    )),
              ),
            ],
          ),
        ));
  }

  _sendMessage(WidgetRef ref, String content) {
    final message =
        Message(content: content, isUser: true, timestamp: DateTime.now());
    // messages.add(message);
    ref.read(messageProvider.notifier).addMessage(message); // 添加数据
    _textController.clear();
    _requestChatGPT(ref, content);
  }

  _requestChatGPT(WidgetRef ref, String content) async {
    ref.read(chatUiStateProvider.notifier).setRequestLoading(true);
    final res = await chatgpt.sendChat(content);
    ref.read(chatUiStateProvider.notifier).setRequestLoading(false);
    final text = res.choices.first.message?.content ?? "";
    final message =
        Message(content: text, isUser: false, timestamp: DateTime.now());
    ref.read(messageProvider.notifier).addMessage(message);
  }
}

class MessageItem extends StatelessWidget {
  const MessageItem({super.key, required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CircleAvatar(
          // backgroundImage: NetworkImage(
          //   'https://picsum.photos/40/40',
          // ),
          backgroundColor: message.isUser ? Colors.blue : Colors.grey,
          foregroundColor: Colors.white,
          child: Text(message.isUser ? 'You' : 'GPT',
              style: TextStyle(fontSize: 16)),
        ),
        const SizedBox(width: 8),
        // Expanded(
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Text(
        //         message.isUser ? 'You' : 'GPT',
        //         style: Theme.of(context).textTheme.labelLarge,
        //       ),
        //       Text(
        //         // 'This is a message',
        //         message.content,
        //         style: Theme.of(context).textTheme.bodyMedium,
        //       ),
        //     ],
        //   ),
        // ),
        Flexible(
          child: Container(
            margin: const EdgeInsets.only(right: 5),
            child: Text(message.content),
          ),
        ),
      ],
    );
  }
}
