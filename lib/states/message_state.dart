import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../injection.dart';
import '../models/message.dart';
import 'session_state.dart';

part 'message_state.g.dart';

class MessageList extends StateNotifier<List<Message>> {
  MessageList() : super([]) {
    init();
  }

  Future<void> init() async {
    state = await db.messageDao.findAllMessages(); // 获取所有的历史消息
  }

  void addMessage(Message message) {
    state = [...state, message];
  }

  void upsertMessage(Message message) {
    final index = state.indexWhere((element) => element.id == message.id);
    var m = message;

    if (index >= 0) {
      final msg = state[index];
      m = message.copyWith(content: msg.content + message.content);
    }
    logger.d("message id ${m.id}");

    // update db
    db.messageDao.upsertMessage(m); // 消息插入数据库中

    if (index == -1) {
      state = [...state, m];
    } else {
      state = [...state]..[index] = m;
    }
  }
}

final messageProvider = StateNotifierProvider<MessageList, List<Message>>(
  (ref) => MessageList(),
);

@riverpod
List<Message> activeSessionMessages(ActiveSessionMessagesRef ref) {
  final active =
      ref.watch(sessionStateNotifierProvider).valueOrNull?.activeSession;
  final messages = ref.watch(messageProvider.select((value) =>
      value.where((element) => element.sessionId == active?.id).toList()));
  return messages;
}
