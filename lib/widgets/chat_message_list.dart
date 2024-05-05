import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:markdown_widget/config/markdown_generator.dart';

import '../markdown/latex.dart';
import '../models/message.dart';
import '../states/message_state.dart';

class ChatMessageList extends HookConsumerWidget {
  const ChatMessageList({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final messages = ref.watch(messageProvider);
    final messages = ref.watch(activeSessionMessagesProvider);
    final listController = useScrollController();
    // ref.listen(messageProvider, (previous, next) {
    ref.listen(activeSessionMessagesProvider, (previous, next) {
      Future.delayed(const Duration(milliseconds: 50), () {
        listController.jumpTo(
          listController.position.maxScrollExtent,
        );
      });
    });

    return ListView.separated(
      controller: listController,
      itemBuilder: (context, index) {
        final msg = messages[index];
        return msg.isUser
            ? SentMessageItem(message: msg)
            : ReceivedMessageItem(message: msg);
      },
      itemCount: messages.length, // 消息数量
      separatorBuilder: (context, index) => const Divider(
        // 分割线
        height: 16,
      ),
    );
  }
}

class ReceivedMessageItem extends StatelessWidget {
  const ReceivedMessageItem({super.key, required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 右键菜单
      onSecondaryTapDown: (details) {
        showMenu(
          context: context,
          position: RelativeRect.fromLTRB(
            details.globalPosition.dx,
            details.globalPosition.dy,
            details.globalPosition.dx,
            details.globalPosition.dy,
          ),
          items: [
            PopupMenuItem(
              padding: EdgeInsets.only(left: 10, right: 0),
              height: 30,
              child: Text('Copy'),
              value: 'Copy',
            ),
          ],
        ).then((value) {
          if (value == 'Copy') {
            Clipboard.setData(ClipboardData(text: message.content));
          }
        });
      },
      // 长按复制
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: message.content));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Copied to clipboard'),
            duration: const Duration(milliseconds: 1000),
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
              // backgroundImage: NetworkImage(
              //   'https://picsum.photos/40/40',
              // ),
              backgroundColor: Colors.white,
              // foregroundColor: Colors.white,
              child: Container(
                alignment: Alignment.center,
                width: 40,
                height: 40,
                child: SvgPicture.asset(
                  'assets/images/openai.svg',
                  width: 40,
                  height: 40,
                ),
              )),
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
              margin: const EdgeInsets.only(top: 5, right: 10),
              // child: Text(message.content),
              child: MessageContentWidget(message: message),
            ),
          ),
        ],
      ),
    );
  }
}

class SentMessageItem extends StatelessWidget {
  const SentMessageItem({super.key, required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 右键菜单
      onSecondaryTapDown: (details) {
        showMenu(
          context: context,
          position: RelativeRect.fromLTRB(
            details.globalPosition.dx,
            details.globalPosition.dy,
            details.globalPosition.dx,
            details.globalPosition.dy,
          ),
          items: [
            PopupMenuItem(
              padding: EdgeInsets.only(left: 10, right: 0),
              height: 30,
              child: Text('Copy'),
              value: 'Copy',
            ),
          ],
        ).then((value) {
          if (value == 'Copy') {
            Clipboard.setData(ClipboardData(text: message.content));
          }
        });
      },
      // 长按复制
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: message.content));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Copied to clipboard'),
            duration: const Duration(milliseconds: 1000),
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            // backgroundImage: NetworkImage(
            //   'https://picsum.photos/40/40',
            // ),
            backgroundColor: message.isUser ? Colors.blue : Colors.grey,
            foregroundColor: Colors.white,
            child: Text('Me', style: TextStyle(fontSize: 16)),
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
              margin: const EdgeInsets.only(top: 5, right: 10),
              // child: Text(message.content),
              child: MessageContentWidget(message: message),
            ),
          ),
        ],
      ),
    );
  }
}

class MessageContentWidget extends StatelessWidget {
  const MessageContentWidget({super.key, required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: MarkdownGenerator(
        generators: [
          latexGenerator,
        ],
        inlineSyntaxList: [
          LatexSyntax(),
        ],
      ).buildWidgets(message.content),
    );
  }
}
