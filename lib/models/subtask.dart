class SubTask {
  final String id;
  final String taskFolderId;
  String name;
  bool isCompleted;
  int order;
  DateTime createdAt;

  SubTask({
    required this.id,
    required this.taskFolderId,
    required this.name,
    this.isCompleted = false,
    this.order = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'task_folder_id': taskFolderId,
        'name': name,
        'is_completed': isCompleted ? 1 : 0,
        'order': order,
        'created_at': createdAt.toIso8601String(),
      };

  factory SubTask.fromMap(Map<String, dynamic> map) => SubTask(
        id: map['id'],
        taskFolderId: map['task_folder_id'],
        name: map['name'],
        isCompleted: (map['is_completed'] ?? 0) == 1,
        order: map['order'] ?? 0,
        createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      );
}
