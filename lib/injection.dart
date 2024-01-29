import 'package:chatgpt_gui/services/chatgpt_service.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import 'data/database.dart';

final chatgpt = ChatGPTService();
final logger = Logger(level: kDebugMode ? Level.trace : Level.info);
const uuid = Uuid();
late AppDatabase db;
