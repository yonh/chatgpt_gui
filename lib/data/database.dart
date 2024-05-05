import 'dart:async';

import 'package:chatgpt_gui/data/converter/datetime_converter.dart';
import 'package:chatgpt_gui/data/dao/session_dao.dart';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../models/message.dart';
import '../models/session.dart';
import 'dao/message_dao.dart';

part 'database.g.dart'; // the generated code will be there

@Database(version: 3, entities: [Message, Session])
@TypeConverters([DateTimeConverter])
abstract class AppDatabase extends FloorDatabase {
  MessageDao get messageDao;
  SessionDao get sessionDao;
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
