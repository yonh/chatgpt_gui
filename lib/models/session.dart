import 'package:floor/floor.dart';

@Entity()
class Session {
  @primaryKey
  final int? id;
  final String title;
  final String model;

  Session({
    this.id,
    required this.title,
    required this.model,
  });

  @override
  String toString() {
    return "Session(id: $id, title: $title, model: $model)";
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
      model: model ?? this.model,
    );
  }
}
