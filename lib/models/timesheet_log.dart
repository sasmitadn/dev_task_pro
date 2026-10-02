class TimesheetLog {
  final String id;
  final String projectId;
  String? taskFolderId;
  String? subtaskId;
  DateTime startTime;
  DateTime? endTime;
  String note;

  TimesheetLog({
    required this.id,
    required this.projectId,
    this.taskFolderId,
    this.subtaskId,
    required this.startTime,
    this.endTime,
    this.note = '',
  });

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  bool get isRunning => endTime == null;

  Map<String, dynamic> toMap() => {
        'id': id,
        'project_id': projectId,
        'task_folder_id': taskFolderId,
        'subtask_id': subtaskId,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime?.toIso8601String(),
        'note': note,
      };

  factory TimesheetLog.fromMap(Map<String, dynamic> map) => TimesheetLog(
        id: map['id'],
        projectId: map['project_id'],
        taskFolderId: map['task_folder_id'],
        subtaskId: map['subtask_id'],
        startTime: DateTime.parse(map['start_time']),
        endTime: map['end_time'] != null ? DateTime.tryParse(map['end_time']) : null,
        note: map['note'] ?? '',
      );
}
