class Message {
  final bool isUser;
  final String content;
  final DateTime timestamp;

  Message({
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
        isUser: json['isUser'],
        content: json['content'],
        timestamp: DateTime.parse(json['timestamp']),
  );

}