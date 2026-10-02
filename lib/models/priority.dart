class Priority {
  final String id;
  String name;
  final int level;
  final int order;

  Priority({required this.id, required this.name, required this.level, this.order = 0});

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'level': level,
        'order': order,
      };

  factory Priority.fromMap(Map<String, dynamic> map) => Priority(
        id: map['id'],
        name: map['name'],
        level: map['level'] ?? 0,
        order: map['order'] ?? 0,
      );
}
