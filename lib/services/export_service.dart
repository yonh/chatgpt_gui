import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../injection.dart';
import '../models/session.dart';

class ExportService {
  void exportMarkdown(
    Session session, {
    String? fileName,
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
    final file = File("${dir.path}/${fileName ?? session.id}.md");
    await file.writeAsString(buffer.toString());
  }
}
