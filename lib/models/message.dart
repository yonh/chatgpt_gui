import 'package:floor/floor.dart';

@entity
class Message {
  @primaryKey
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  @ForeignKey(
      childColumns: ["session_id"], parentColumns: ["id"], entity: Message)
  @ColumnInfo(name: "session_id")
  final int sessionId;

  Message({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    required this.sessionId,
  });

  @override
  String toString() {
    return "Message(id: $id, content: $content, isUser: $isUser, timestamp: $timestamp, sessionId: $sessionId)";
  }

  @override
  bool operator ==(other) {
    if (identical(this, other)) return true;
    return other is Message && other.id == id;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      content.hashCode ^
      isUser.hashCode ^
      timestamp.hashCode ^
      sessionId.hashCode;
}

// 在 Dart 中，extension关键字可以用于创建扩展方法（extension methods），这是一种在不修改原始类或创建子类的情况下向现有类添加方法的方式。
// 扩展方法是一个静态方法，可以像实例方法一样使用，并且可以访问该类的私有变量和方法。使用扩展方法可以使代码更简洁和易于维护，同时也可以提高代码的可读性。
extension MessageExtension on Message {
  Message copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    int? sessionId,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      sessionId: sessionId ?? this.sessionId,
    );
  }
}
