class TaskFolder {
  final String id;
  final String projectId;
  String name;
  bool isCompleted;
  int order;
  DateTime createdAt;

  TaskFolder({
    required this.id,
    required this.projectId,
    required this.name,
    this.isCompleted = false,
    this.order = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'project_id': projectId,
        'name': name,
        'is_completed': isCompleted ? 1 : 0,
        'order': order,
        'created_at': createdAt.toIso8601String(),
      };

  factory TaskFolder.fromMap(Map<String, dynamic> map) => TaskFolder(
        id: map['id'],
        projectId: map['project_id'],
        name: map['name'],
        isCompleted: (map['is_completed'] ?? 0) == 1,
        order: map['order'] ?? 0,
        createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      );
}
