import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

import '../injection.dart';
import '../models/session.dart';
import '../theme.dart';
import '../widgets/chat_message_list.dart';

class ExportService {
  Future<String?> exportMarkdown(
    Session session, {
    String? path,
  }) async {
    final messages = await db.messageDao.findMessagesBySessionId(session.id!);
    final buffer = StringBuffer();
    for (var element in messages) {
      var content = element.content;
      if (element.isUser) {
        content = "> $content"; // markdown 引用，为了区分消息内容是否是用户的
      }
      buffer.writeln();
      buffer.writeln(content);
    }
    logger.t(buffer.toString());
    final docDir = await getApplicationDocumentsDirectory();
    final dir = Directory("${docDir.path}/exports/markdown");
    logger.t("$dir"); // 如果想知道目录是啥，这里可以打印一下
    await dir.create(recursive: true);
    final file = File(path ?? "${dir.path}/${session.id}.md");

    await file.writeAsString(buffer.toString());
    return file.path;
  }

  Future<String?> exportImage(
    Session session, {
    BuildContext? context, //
    Size? targetSize, // 截图大小，为了能够截取合适的大小，请传入组件的实际大小
    String? path,
  }) async {
    final controller = ScreenshotController();
    // 获取消息
    final messages = await db.messageDao.findMessagesBySessionId(session.id!);
    // 使用一个 ScrollView 来展示消息列表
    final widget = SingleChildScrollView(
      child: Container(
        //color: const Color(0xFFF1F1F1), // 背景色，我们前面的截图中发现了，背景是透明的，显示会有问题
        color: isDarkMode(context!)
            ? const Color(0xFF1E1E1E)
            : const Color(0xFFF1F1F1), // 这里根据主题设置背景色
        padding: const EdgeInsets.all(16), // 图片边距
        child: Column(
          children: messages
              .map((msg) => [
                    // 这里就是前面绘制消息列表的代码 复制过来即可
                    msg.isUser
                        ? SentMessageItem(
                            message: msg,
                            backgroundColor: const Color(0xFF8FE869),
                          )
                        : ReceivedMessageItem(
                            message: msg,
                          ),
                    // 加上边距，
                    const Divider(
                      color: Colors.transparent,
                      height: 16,
                    )
                  ])
              .expand((element) => element)
              .toList(),
        ),
      ),
    );
    // 这里使用controller来截图
    final img = await controller.captureFromWidget(
      widget,
      context: context,
      targetSize: targetSize,
    );
    // 保存图片的问题，跟前面导出Markdown的类似
    final docDir = await getApplicationDocumentsDirectory();
    final dir = Directory("${docDir.path}/exports/img");
    final defaultSave = "${dir.path}/${session.id}.png";
    final file = File(path ?? defaultSave);

    // 如果file所在目录不存在，创建目录
    file.parent.createSync(recursive: true);

    //await file.create(recursive: true);
    file.writeAsBytes(img); // 写入图片

    return file.path;
  }
}
