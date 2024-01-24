import 'package:chatgpt_gui/injection.dart';
import 'package:uuid/uuid.dart';

class Message {
  final String id;
  final bool isUser;
  final String content;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.isUser,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'isUser': isUser,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
      };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: uuid.v4(),
        isUser: json['isUser'],
        content: json['content'],
        timestamp: DateTime.parse(json['timestamp']),
      );

  Message copyWith({
    String? id,
    bool? isUser,
    String? content,
    DateTime? timestamp,
  }) =>
      Message(
        id: id ?? this.id,
        isUser: isUser ?? this.isUser,
        content: content ?? this.content,
        timestamp: timestamp ?? this.timestamp,
      );
}
