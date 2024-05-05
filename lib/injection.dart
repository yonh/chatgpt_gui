import 'package:chatgpt_gui/services/chatgpt_service.dart';
import 'package:floor/floor.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import 'data/database.dart';

final chatgpt = ChatGPTService();
final logger = Logger(level: kDebugMode ? Level.trace : Level.info);
const uuid = Uuid();
late AppDatabase db;

setupDatabse() async {
  db = await initDatabase();
}

Future<AppDatabase> initDatabase() async {
  return $FloorAppDatabase.databaseBuilder('app_database.db').addMigrations(
    [
      Migration(1, 2, (database) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Session` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `title` TEXT NOT NULL)');
        await database
            .execute('ALTER TABLE Message ADD COLUMN session_id INTEGER');
        await database
            .execute("insert into Session (id, title) values (1, 'Default')");
        await database.execute("update Message set session_id = 1");
      }),
      Migration(2, 3, (database) async {
        await database.execute(
            'ALTER TABLE Session ADD COLUMN model varchar(32) DEFAULT "gpt-3.5-turbo"');
        await database.execute("UPDATE Session SET model = 'gpt-3.5-turbo'");
      }),
    ],
  ).build();
}
