import 'package:chatgpt_gui/services/chatgpt_service.dart';
import 'package:chatgpt_gui/widgets/log_viewer_page.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import 'data/database.dart';
import 'services/export_service.dart';
import 'services/record.dart';

final chatgpt = ChatGPTService();
final memoryLogOutput = MemoryLogOutput();
var logger = Logger(
    output: memoryLogOutput, level: kDebugMode ? Level.trace : Level.info);
const uuid = Uuid();
late AppDatabase db;
final recorder = RecordService();
final exportService = ExportService();

setupDatabse() async {
  db = await initDatabase();
}
