import 'package:floor/floor.dart';

@Entity()
class Session {
  @primaryKey
  final int id;
  final String title;

  Session({
    required this.id,
    required this.title,
  });

  @override
  String toString() {
    return "Session(id: $id, title: $title)";
  }

  @override
  bool operator ==(other) {
    if (identical(this, other)) return true;
    return other is Session && other.id == id;
  }

  @override
  int get hashCode => id.hashCode ^ title.hashCode;

  Session copyWith({int? id, String? title}) {
    return Session(
      id: id ?? this.id,
      title: title ?? this.title,
    );
  }
}
