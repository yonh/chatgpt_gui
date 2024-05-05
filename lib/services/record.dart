import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../injection.dart';

class RecordService {
  final r = Record();

  Future start({String? fileName}) async {
    if (await r.hasPermission()) {
      if (await isRecording) {
        logger.e("is recording......");
        return;
      }
      final path = await getTemporaryDirectory();

      final d = Directory("${path.absolute.path}/audios/");
      await d.create(recursive: true);

      final file = File(
          "${d.path}/${fileName ?? DateTime.now().microsecondsSinceEpoch}.m4a");
      logger.v('start path: ${file.path}');

      await r.start(
          path: isApplePlatform() ? Uri.file(file.path).toString() : file.path
          //iOS 和 macOS应用需要Uri格式
          //如果是Windows 和Android 直接使用文件路径
          );
    }
  }

  bool isApplePlatform() {
    return Platform.isIOS || Platform.isMacOS;
  }

  Future<String?> stop() async {
    final path = await r.stop();
    logger.t('stop path: $path');
    if (path == null) return null;
    // 根据平台类型，统一返回文件路径
    return isApplePlatform() ? Uri.parse(path).toFilePath() : path;
  }

  Future<bool> get isRecording async => r.isRecording();
}
