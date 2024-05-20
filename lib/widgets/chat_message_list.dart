import 'package:chatgpt_gui/states/chat_ui_state.dart';
import 'package:chatgpt_gui/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:markdown_widget/config/markdown_generator.dart';

import '../injection.dart';
import '../markdown/latex.dart';
import '../models/message.dart';
import '../states/message_state.dart';
import '../states/session_state.dart';

class ChatMessageList extends HookConsumerWidget {
  final ScrollController listController;

  const ChatMessageList({
    super.key,
    required this.listController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final messages = ref.watch(messageProvider);
    final messages = ref.watch(activeSessionMessagesProvider);
    //final listController = useScrollController();
    // ref.listen(messageProvider, (previous, next) {
    ref.listen(activeSessionMessagesProvider, (previous, next) {
      Future.delayed(const Duration(milliseconds: 200), () {
        listController.jumpTo(
          // 滚动到底部, 有时 maxScrollExtent 取值不准确，导致无法滚动到底部，因此加上一个偏移量保证能够顺利滚动到底部
          listController.position.maxScrollExtent,
        );
        // logger.t("jump to bottom......${listController.position.maxScrollExtent}");
      });
    });

    return ListView.separated(
      controller: listController,
      itemBuilder: (context, index) {
        final msg = messages[index];
        return msg.isUser
            ? SentMessageItem(message: msg)
            : ReceivedMessageItem(
                message: msg,
                // 只在最后一条消息且请求中时显示光标
                typing: index == messages.length - 1 &&
                    ref.watch(chatUiStateProvider).requestLoading);
      },
      itemCount: messages.length, // 消息数量
      separatorBuilder: (context, index) => const Divider(
          // 分割线
          height: 16,
          color: Colors.transparent),
    );
  }
}

class ReceivedMessageItem extends StatelessWidget {
  final Color backgroundColor;
  final double radius;
  final bool typing;
  const ReceivedMessageItem({
    super.key,
    required this.message,
    this.backgroundColor = Colors.lightBlue,
    this.radius = 6,
    this.typing = false,
  });

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
              child: Text(AppLocalizations.of(context)!.copy),
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
            content: Text(AppLocalizations.of(context)!.copied),
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
          CustomPaint(
            painter:
                Triangle(backgroundColor, translateX: 8.0, translateY: 5.0),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(radius),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              margin: const EdgeInsets.only(top: 5, right: 10),
              // child: Text(message.content),
              child: MessageContentWidget(
                message: message,
                typing: typing,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SentMessageItem extends StatelessWidget {
  final Color backgroundColor;
  final double radius;

  const SentMessageItem(
      {super.key,
      required this.message,
      this.backgroundColor = Colors.green,
      this.radius = 6});

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
              child: Text(AppLocalizations.of(context)!.copy),
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
            content: Text(AppLocalizations.of(context)!.copied),
            duration: const Duration(milliseconds: 1000),
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
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
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(radius),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              margin: const EdgeInsets.only(top: 5, right: 10),
              // child: Text(message.content),
              child: MessageContentWidget(message: message),
            ),
          ),
          //const SizedBox(width: 8),
          CustomPaint(
            painter:
                Triangle(backgroundColor, translateX: -10.0, translateY: 5.0),
          ),
          CircleAvatar(
            // backgroundImage: NetworkImage(
            //   'https://picsum.photos/40/40',
            // ),
            backgroundColor: message.isUser ? Colors.blue : Colors.grey,
            foregroundColor: Colors.white,
            child: Text(AppLocalizations.of(context)!.me,
                style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

class MessageContentWidget extends StatelessWidget {
  final bool typing;
  final Message message;

  const MessageContentWidget(
      {super.key, required this.message, this.typing = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...MarkdownGenerator(
          generators: [
            latexGenerator,
          ],
          inlineSyntaxList: [
            LatexSyntax(),
          ],
        ).buildWidgets(message.content),
        if (typing) const TypingCursor(),
      ],
    );
  }
}

// 聊天气泡小三角形
class Triangle extends CustomPainter {
  final Color bgColor;
  final translateX;
  final translateY;

  Triangle(this.bgColor, {this.translateX = 0.0, this.translateY = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = bgColor;

    var path = Path();
    // path.lineTo(0, 0);
    // path.lineTo(5, 10);
    // path.lineTo(10, 0);

    path.lineTo(-5, 0);
    path.lineTo(0, 10);
    path.lineTo(5, 0);

    canvas.translate(this.translateX, this.translateY); // 我们向左移动，只需要调整横坐标即可。

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

// 消息输入框光标闪烁
class TypingCursor extends HookWidget {
  const TypingCursor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 初始化动画控制器，设置动画时长为 500 毫秒
    final ac = useAnimationController(
      duration: const Duration(milliseconds: 500),
    );
    // 添加动画监听器，当动画完成时，反转动画，当动画反转完成时，再次正向播放动画
    ac.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        ac.reverse();
      } else if (status == AnimationStatus.dismissed) {
        ac.forward();
      }
    });

    // 使用 useAnimation 获取动画的值，然后使用 Opacity 将其应用到 Widget 上
    // 当动画播放完成时，动画的值为 1，当动画反转完成时，动画的值为 0
    final opacity = useAnimation(Tween<double>(begin: 0, end: 1)
        .chain(CurveTween(curve: Curves.easeIn))
        .animate(ac));
    // 当动画不再播放时，正向播放动画, 也就是说，当动画播放完成时，会自动反转动画
    // 这样就可以实现一个来回闪烁的光标
    // 这里要特别注意，需要判断是不是正在播放动画，如果已经正在进行中，就不要再次播放了
    if (!ac.isAnimating) {
      ac.forward();
    }
    return Opacity(
      opacity: opacity,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        width: 6,
        height: 12,
        color: Colors.black,
      ),
    );
  }
}

class ChatMessageListWidget extends HookConsumerWidget {
  const ChatMessageListWidget({
    super.key,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeSessionProvider);
    final scrollController = useScrollController();
    final chatListKey = GlobalKey();

    return Column(
      key: chatListKey,
      children: [
        Expanded(
          child: ChatMessageList(
            listController: scrollController,
          ),
        ),
        if (active != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () async {
                  if (active != null) {
                    if (isDesktop()) {
                      final path = await saveAs(fileName: "${active.title}.md");
                      if (path == null) return; //取消选择
                      await exportService.exportMarkdown(active, path: path);
                    } else {
                      final output = await exportService.exportMarkdown(active);
                      if (output == null) return;
                      shareFiles([output]);
                    }
                  }
                },
                icon: const Icon(Icons.text_snippet),
              ),
              IconButton(
                onPressed: () async {
                  if (active != null) {
                    final renderbox = chatListKey.currentContext!
                        .findRenderObject() as RenderBox; // 获取渲染组件宽度

                    // listview滚动到底部
                    scrollController.animateTo(
                      scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.linear,
                    );
                    // Future.delayed(const Duration(milliseconds: 500));
                    // 计算 listview 所有的高度
                    final height = scrollController.position.maxScrollExtent +
                        scrollController.position.viewportDimension;

                    if (isDesktop()) {
                      final path =
                          await saveAs(fileName: "${active.title}.png");
                      if (path == null) return; //取消选择
                      final output = await exportService.exportImage(
                        active,
                        context: ref.context,
                        targetSize:
                            Size(renderbox.size.width + 32, height + 48),
                        path: path,
                      );
                    } else {
                      final output = await exportService.exportImage(
                        active,
                        context: ref.context,
                        targetSize:
                            Size(renderbox.size.width + 32, height + 48),
                      );
                      if (output == null) return;
                      shareFiles([output]);
                    }
                  }
                },
                icon: const Icon(Icons.image),
              ),
            ],
          )
      ],
    );
  }
}
