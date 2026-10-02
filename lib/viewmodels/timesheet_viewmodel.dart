import 'dart:async';
import 'package:flutter/material.dart';

import 'package:uuid/uuid.dart';
import '../models/timesheet_log.dart';
import '../models/project.dart';
import '../core/db/app_database.dart';

class TimesheetViewModel extends ChangeNotifier {
  final _db = AppDatabase.instance;
  final _uuid = const Uuid();

  TimesheetLog? _running;
  Project? _runningProject;
  Timer? _ticker;
  Duration _elapsed = Duration.zero;

  TimesheetLog? get running => _running;
  Project? get runningProject => _runningProject;
  Duration get elapsed => _elapsed;
  bool get isRunning => _running != null;

  Future<void> init(List<Project> projects) async {
    final log = await _db.getRunningTimesheet();
    if (log != null) {
      _running = log;
      _runningProject = projects.firstWhere(
        (p) => p.id == log.projectId,
        orElse: () => Project(id: '', name: 'Unknown'),
      );
      _elapsed = DateTime.now().difference(log.startTime);
      _startTicker();
      notifyListeners();
    }
  }

  Future<void> start(Project project, {String? taskFolderId, String? subtaskId}) async {
    if (_running != null) return;
    final log = TimesheetLog(
      id: _uuid.v4(),
      projectId: project.id,
      taskFolderId: taskFolderId,
      subtaskId: subtaskId,
      startTime: DateTime.now(),
    );
    await _db.insertTimesheetLog(log);
    _running = log;
    _runningProject = project;
    _elapsed = Duration.zero;
    _startTicker();
    notifyListeners();
  }

  Future<TimesheetLog?> stop(String note) async {
    if (_running == null) return null;
    _running!.endTime = DateTime.now();
    _running!.note = note;
    await _db.updateTimesheetLog(_running!);
    final saved = _running;
    _ticker?.cancel();
    _ticker = null;
    _running = null;
    _runningProject = null;
    _elapsed = Duration.zero;
    notifyListeners();
    return saved;
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_running != null) {
        _elapsed = DateTime.now().difference(_running!.startTime);
        notifyListeners();
      }
    });
  }

  String get formattedElapsed {
    final h = _elapsed.inHours.toString().padLeft(2, '0');
    final m = (_elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  Future<List<TimesheetLog>> getLogs(String projectId) async {
    return _db.getTimesheetLogs(projectId);
  }

  Future<void> deleteLog(String id) async {
    await _db.deleteTimesheetLog(id);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
