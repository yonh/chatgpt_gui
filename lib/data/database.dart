import 'dart:async';

import 'package:chatgpt_gui/data/converter/datetime_converter.dart';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../models/message.dart';
import 'dao/message_dao.dart';

part 'database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [Message])
@TypeConverters([DateTimeConverter])
abstract class AppDatabase extends FloorDatabase {
  MessageDao get messageDao;
}
