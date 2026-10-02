
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/category.dart';
import '../../models/priority.dart';
import '../../models/project.dart';
import '../../models/task_folder.dart';
import '../../models/subtask.dart';
import '../../models/timesheet_log.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._();
  static Database? _db;

  AppDatabase._();

  Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'project_manager.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        "order" INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE priorities (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        level INTEGER DEFAULT 0,
        "order" INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE projects (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        status TEXT DEFAULT 'active',
        priority_id TEXT,
        category_id TEXT,
        description TEXT DEFAULT '',
        tech_stack TEXT DEFAULT '',
        urls TEXT DEFAULT '',
        due_date TEXT,
        system TEXT,
        brainstorming TEXT,
        "order" INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE task_folders (
        id TEXT PRIMARY KEY,
        project_id TEXT NOT NULL,
        name TEXT NOT NULL,
        is_completed INTEGER DEFAULT 0,
        "order" INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE subtasks (
        id TEXT PRIMARY KEY,
        task_folder_id TEXT NOT NULL,
        name TEXT NOT NULL,
        is_completed INTEGER DEFAULT 0,
        "order" INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (task_folder_id) REFERENCES task_folders(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE timesheet_logs (
        id TEXT PRIMARY KEY,
        project_id TEXT NOT NULL,
        task_folder_id TEXT,
        subtask_id TEXT,
        start_time TEXT NOT NULL,
        end_time TEXT,
        note TEXT DEFAULT '',
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
      )
    ''');

    // Seed default categories
    await db.insert('categories', {'id': 'cat_1', 'name': 'Mobile', 'order': 0});
    await db.insert('categories', {'id': 'cat_2', 'name': 'Web', 'order': 1});
    await db.insert('categories', {'id': 'cat_3', 'name': 'Backend', 'order': 2});
    await db.insert('categories', {'id': 'cat_4', 'name': 'Desktop', 'order': 3});

    // Seed default priorities
    await db.insert('priorities', {'id': 'pri_1', 'name': 'Critical', 'level': 4, 'order': 0});
    await db.insert('priorities', {'id': 'pri_2', 'name': 'High', 'level': 3, 'order': 1});
    await db.insert('priorities', {'id': 'pri_3', 'name': 'Medium', 'level': 2, 'order': 2});
    await db.insert('priorities', {'id': 'pri_4', 'name': 'Low', 'level': 1, 'order': 3});
  }

  // ─── Categories ────────────────────────────────────────────────────────────

  Future<List<Category>> getCategories() async {
    final d = await db;
    final rows = await d.query('categories', orderBy: '"order" ASC, name ASC');
    return rows.map(Category.fromMap).toList();
  }

  Future<void> insertCategory(Category c) async {
    final d = await db;
    await d.insert('categories', c.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateCategory(Category c) async {
    final d = await db;
    await d.update('categories', c.toMap(), where: 'id = ?', whereArgs: [c.id]);
  }

  Future<void> deleteCategory(String id) async {
    final d = await db;
    await d.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Priorities ────────────────────────────────────────────────────────────

  Future<List<Priority>> getPriorities() async {
    final d = await db;
    final rows = await d.query('priorities', orderBy: '"order" ASC, level DESC');
    return rows.map(Priority.fromMap).toList();
  }

  Future<void> insertPriority(Priority p) async {
    final d = await db;
    await d.insert('priorities', p.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updatePriority(Priority p) async {
    final d = await db;
    await d.update('priorities', p.toMap(), where: 'id = ?', whereArgs: [p.id]);
  }

  Future<void> deletePriority(String id) async {
    final d = await db;
    await d.delete('priorities', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Projects ──────────────────────────────────────────────────────────────

  Future<List<Project>> getProjects({String? categoryId}) async {
    final d = await db;
    final rows = await d.query(
      'projects',
      where: categoryId != null ? 'category_id = ?' : null,
      whereArgs: categoryId != null ? [categoryId] : null,
      orderBy: '"order" ASC, updated_at DESC',
    );
    return rows.map(Project.fromMap).toList();
  }

  Future<Project?> getProject(String id) async {
    final d = await db;
    final rows = await d.query('projects', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : Project.fromMap(rows.first);
  }

  Future<void> insertProject(Project p) async {
    final d = await db;
    await d.insert('projects', p.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateProject(Project p) async {
    final d = await db;
    p.updatedAt = DateTime.now();
    await d.update('projects', p.toMap(), where: 'id = ?', whereArgs: [p.id]);
  }

  Future<void> deleteProject(String id) async {
    final d = await db;
    await d.delete('projects', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Task Folders ──────────────────────────────────────────────────────────

  Future<List<TaskFolder>> getTaskFolders(String projectId) async {
    final d = await db;
    final rows = await d.query(
      'task_folders',
      where: 'project_id = ?',
      whereArgs: [projectId],
      orderBy: '"order" ASC, created_at ASC',
    );
    return rows.map(TaskFolder.fromMap).toList();
  }

  Future<void> insertTaskFolder(TaskFolder tf) async {
    final d = await db;
    await d.insert('task_folders', tf.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateTaskFolder(TaskFolder tf) async {
    final d = await db;
    await d.update('task_folders', tf.toMap(), where: 'id = ?', whereArgs: [tf.id]);
  }

  Future<void> deleteTaskFolder(String id) async {
    final d = await db;
    await d.delete('task_folders', where: 'id = ?', whereArgs: [id]);
  }

  // ─── SubTasks ──────────────────────────────────────────────────────────────

  Future<List<SubTask>> getSubTasks(String taskFolderId) async {
    final d = await db;
    final rows = await d.query(
      'subtasks',
      where: 'task_folder_id = ?',
      whereArgs: [taskFolderId],
      orderBy: '"order" ASC, created_at ASC',
    );
    return rows.map(SubTask.fromMap).toList();
  }

  Future<void> insertSubTask(SubTask st) async {
    final d = await db;
    await d.insert('subtasks', st.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateSubTask(SubTask st) async {
    final d = await db;
    await d.update('subtasks', st.toMap(), where: 'id = ?', whereArgs: [st.id]);
  }

  Future<void> deleteSubTask(String id) async {
    final d = await db;
    await d.delete('subtasks', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Timesheet ─────────────────────────────────────────────────────────────

  Future<List<TimesheetLog>> getTimesheetLogs(String projectId) async {
    final d = await db;
    final rows = await d.query(
      'timesheet_logs',
      where: 'project_id = ?',
      whereArgs: [projectId],
      orderBy: 'start_time DESC',
    );
    return rows.map(TimesheetLog.fromMap).toList();
  }

  Future<TimesheetLog?> getRunningTimesheet() async {
    final d = await db;
    final rows = await d.query(
      'timesheet_logs',
      where: 'end_time IS NULL',
      limit: 1,
    );
    return rows.isEmpty ? null : TimesheetLog.fromMap(rows.first);
  }

  Future<void> insertTimesheetLog(TimesheetLog t) async {
    final d = await db;
    await d.insert('timesheet_logs', t.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateTimesheetLog(TimesheetLog t) async {
    final d = await db;
    await d.update('timesheet_logs', t.toMap(), where: 'id = ?', whereArgs: [t.id]);
  }

  Future<void> deleteTimesheetLog(String id) async {
    final d = await db;
    await d.delete('timesheet_logs', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Export / Import ───────────────────────────────────────────────────────

  Future<Map<String, dynamic>> exportAll() async {
    final d = await db;
    return {
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'categories': await d.query('categories'),
      'priorities': await d.query('priorities'),
      'projects': await d.query('projects'),
      'task_folders': await d.query('task_folders'),
      'subtasks': await d.query('subtasks'),
      'timesheet_logs': await d.query('timesheet_logs'),
    };
  }

  Future<void> importAll(Map<String, dynamic> data) async {
    final d = await db;
    final batch = d.batch();

    for (final c in (data['categories'] as List? ?? [])) {
      batch.insert('categories', Map<String, dynamic>.from(c),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    for (final p in (data['priorities'] as List? ?? [])) {
      batch.insert('priorities', Map<String, dynamic>.from(p),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    for (final p in (data['projects'] as List? ?? [])) {
      batch.insert('projects', Map<String, dynamic>.from(p),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    for (final tf in (data['task_folders'] as List? ?? [])) {
      batch.insert('task_folders', Map<String, dynamic>.from(tf),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    for (final st in (data['subtasks'] as List? ?? [])) {
      batch.insert('subtasks', Map<String, dynamic>.from(st),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    for (final t in (data['timesheet_logs'] as List? ?? [])) {
      batch.insert('timesheet_logs', Map<String, dynamic>.from(t),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit();
  }
}
