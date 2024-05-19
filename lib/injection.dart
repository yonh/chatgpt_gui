import 'package:chatgpt_gui/services/chatgpt_service.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import 'data/database.dart';
import 'services/export_service.dart';
import 'services/record.dart';

final chatgpt = ChatGPTService();
final logger = Logger(level: kDebugMode ? Level.trace : Level.info);
const uuid = Uuid();
late AppDatabase db;
final recorder = RecordService();
final exportService = ExportService();

setupDatabse() async {
  db = await initDatabase();
}
