import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/task_folder.dart';
import '../models/subtask.dart';
import '../core/db/app_database.dart';

class TaskViewModel extends ChangeNotifier {
  final _db = AppDatabase.instance;
  final _uuid = const Uuid();

  Map<String, List<TaskFolder>> _foldersCache = {};
  Map<String, List<SubTask>> _subtasksCache = {};

  List<TaskFolder> getFolders(String projectId) => _foldersCache[projectId] ?? [];
  List<SubTask> getSubTasks(String folderId) => _subtasksCache[folderId] ?? [];

  int getTotalTasks(String projectId) {
    final folders = getFolders(projectId);
    return folders.fold(0, (sum, f) => sum + (getSubTasks(f.id).length));
  }

  int getCompletedTasks(String projectId) {
    final folders = getFolders(projectId);
    return folders.fold(0, (sum, f) => sum + getSubTasks(f.id).where((s) => s.isCompleted).length);
  }

  double getProgress(String projectId) {
    final total = getTotalTasks(projectId);
    if (total == 0) return 0;
    return getCompletedTasks(projectId) / total;
  }

  Future<void> loadFolders(String projectId) async {
    _foldersCache[projectId] = await _db.getTaskFolders(projectId);
    for (final f in _foldersCache[projectId]!) {
      _subtasksCache[f.id] = await _db.getSubTasks(f.id);
    }
    notifyListeners();
  }

  Future<TaskFolder> addFolder(String projectId, String name) async {
    final folders = _foldersCache[projectId] ?? [];
    final tf = TaskFolder(
      id: _uuid.v4(),
      projectId: projectId,
      name: name,
      order: folders.length,
    );
    await _db.insertTaskFolder(tf);
    folders.add(tf);
    _foldersCache[projectId] = folders;
    _subtasksCache[tf.id] = [];
    notifyListeners();
    return tf;
  }

  Future<void> updateFolder(TaskFolder tf) async {
    await _db.updateTaskFolder(tf);
    final folders = _foldersCache[tf.projectId] ?? [];
    final idx = folders.indexWhere((f) => f.id == tf.id);
    if (idx >= 0) folders[idx] = tf;
    notifyListeners();
  }

  Future<void> deleteFolder(String projectId, String folderId) async {
    await _db.deleteTaskFolder(folderId);
    _foldersCache[projectId]?.removeWhere((f) => f.id == folderId);
    _subtasksCache.remove(folderId);
    notifyListeners();
  }

  Future<void> reorderFolders(String projectId, int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    final folders = _foldersCache[projectId] ?? [];
    final f = folders.removeAt(oldIndex);
    folders.insert(newIndex, f);
    for (int i = 0; i < folders.length; i++) {
      folders[i].order = i;
      await _db.updateTaskFolder(folders[i]);
    }
    _foldersCache[projectId] = folders;
    notifyListeners();
  }

  Future<SubTask> addSubTask(String folderId, String name) async {
    final subtasks = _subtasksCache[folderId] ?? [];
    final st = SubTask(
      id: _uuid.v4(),
      taskFolderId: folderId,
      name: name,
      order: subtasks.length,
    );
    await _db.insertSubTask(st);
    subtasks.add(st);
    _subtasksCache[folderId] = subtasks;
    notifyListeners();
    return st;
  }

  Future<void> updateSubTask(SubTask st) async {
    await _db.updateSubTask(st);
    final subtasks = _subtasksCache[st.taskFolderId] ?? [];
    final idx = subtasks.indexWhere((s) => s.id == st.id);
    if (idx >= 0) subtasks[idx] = st;
    notifyListeners();
  }

  Future<void> toggleSubTask(SubTask st) async {
    st.isCompleted = !st.isCompleted;
    await _db.updateSubTask(st);
    notifyListeners();
  }

  Future<void> deleteSubTask(String folderId, String subtaskId) async {
    await _db.deleteSubTask(subtaskId);
    _subtasksCache[folderId]?.removeWhere((s) => s.id == subtaskId);
    notifyListeners();
  }

  Future<void> reorderSubTasks(String folderId, int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    final subtasks = _subtasksCache[folderId] ?? [];
    final st = subtasks.removeAt(oldIndex);
    subtasks.insert(newIndex, st);
    for (int i = 0; i < subtasks.length; i++) {
      subtasks[i].order = i;
      await _db.updateSubTask(subtasks[i]);
    }
    _subtasksCache[folderId] = subtasks;
    notifyListeners();
  }
}
