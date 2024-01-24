import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/message.dart';

class MessageList extends StateNotifier<List<Message>> {
  MessageList() : super([]);

  void addMessage(Message message) {
    state = [...state, message];
  }

  void upsertMessage(Message message) {
    final index = state.indexWhere((element) => element.id == message.id);
    if (index == -1) {
      state = [...state, message];
    } else {
      final msg = state[index];
      state = [...state]..[index] =
          message.copyWith(content: msg.content + message.content);
    }
  }
}

final messageProvider = StateNotifierProvider<MessageList, List<Message>>(
  (ref) => MessageList(),
);
