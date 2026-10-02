class Category {
  final String id;
  String name;
  final int order;

  Category({required this.id, required this.name, this.order = 0});

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'order': order,
      };

  factory Category.fromMap(Map<String, dynamic> map) => Category(
        id: map['id'],
        name: map['name'],
        order: map['order'] ?? 0,
      );
}
