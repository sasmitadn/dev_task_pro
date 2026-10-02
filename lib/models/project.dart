class ProjectUrl {
  final String name;
  final String url;

  ProjectUrl({required this.name, required this.url});

  Map<String, dynamic> toMap() => {'name': name, 'url': url};
  factory ProjectUrl.fromMap(Map<String, dynamic> map) =>
      ProjectUrl(name: map['name'] ?? '', url: map['url'] ?? '');
}

class Project {
  final String id;
  String name;
  String status;
  String priorityId;
  String categoryId;
  String description;
  List<String> techStack;
  List<ProjectUrl> urls;
  DateTime? dueDate;
  String? system;
  String? brainstorming;
  int order;
  DateTime createdAt;
  DateTime updatedAt;

  Project({
    required this.id,
    required this.name,
    this.status = 'aktif',
    this.priorityId = '',
    this.categoryId = '',
    this.description = '',
    List<String>? techStack,
    List<ProjectUrl>? urls,
    this.dueDate,
    this.system,
    this.brainstorming,
    this.order = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : techStack = techStack ?? [],
        urls = urls ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'status': status,
        'priority_id': priorityId,
        'category_id': categoryId,
        'description': description,
        'tech_stack': techStack.join(','),
        'urls': urls.map((u) => '${u.name}|${u.url}').join('\n'),
        'due_date': dueDate?.toIso8601String(),
        'system': system,
        'brainstorming': brainstorming,
        'order': order,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory Project.fromMap(Map<String, dynamic> map) {
    List<ProjectUrl> parsedUrls = [];
    if (map['urls'] != null && (map['urls'] as String).isNotEmpty) {
      final lines = (map['urls'] as String).split('\n');
      for (var line in lines) {
        final parts = line.split('|');
        if (parts.length >= 2) {
          parsedUrls.add(ProjectUrl(name: parts[0], url: parts.sublist(1).join('|')));
        } else {
          parsedUrls.add(ProjectUrl(name: 'Link', url: line));
        }
      }
    }

    return Project(
      id: map['id'],
      name: map['name'],
      status: map['status'] ?? 'aktif',
      priorityId: map['priority_id'] ?? '',
      categoryId: map['category_id'] ?? '',
      description: map['description'] ?? '',
      techStack: map['tech_stack'] != null && (map['tech_stack'] as String).isNotEmpty
          ? (map['tech_stack'] as String).split(',')
          : [],
      urls: parsedUrls,
      dueDate: map['due_date'] != null ? DateTime.tryParse(map['due_date']) : null,
      system: map['system'],
      brainstorming: map['brainstorming'],
      order: map['order'] ?? 0,
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] ?? '') ?? DateTime.now(),
    );
  }
}

