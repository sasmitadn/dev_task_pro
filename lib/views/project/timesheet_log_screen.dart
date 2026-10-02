import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/project.dart';
import '../../models/timesheet_log.dart';
import '../../viewmodels/timesheet_viewmodel.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/confirm_delete_dialog.dart';

class TimesheetLogScreen extends StatefulWidget {
  final Project project;
  const TimesheetLogScreen({super.key, required this.project});

  @override
  State<TimesheetLogScreen> createState() => _TimesheetLogScreenState();
}

class _TimesheetLogScreenState extends State<TimesheetLogScreen> {
  List<TimesheetLog> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final vm = context.read<TimesheetViewModel>();
    _logs = await vm.getLogs(widget.project.id);
    setState(() => _loading = false);
  }

  Duration get _totalTime => _logs.fold(Duration.zero, (sum, l) => sum + l.duration);

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppScaffold(
      title: 'Timesheet Logs',
      breadcrumb: 'Home > Project > Timesheet Logs',
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer_off_rounded, size: 56, color: scheme.onSurface.withOpacity(0.2)),
                      const SizedBox(height: 12),
                      Text('No logs yet', style: TextStyle(color: scheme.onSurface.withOpacity(0.4))),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: scheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: scheme.primary.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Time', style: TextStyle(color: scheme.onSurface.withOpacity(0.7))),
                          Text(
                            _formatDuration(_totalTime),
                            style: TextStyle(
                              fontFamily: 'Consolas',
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: scheme.primary,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _logs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final log = _logs[i];
                          return Dismissible(
                            key: Key(log.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: scheme.error,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.delete_rounded, color: Colors.white),
                            ),
                            confirmDismiss: (_) => ConfirmDeleteDialog.show(
                              context,
                              title: 'Delete Log',
                              content: 'Delete this timesheet entry?',
                            ),
                            onDismissed: (_) async {
                              await context.read<TimesheetViewModel>().deleteLog(log.id);
                              setState(() => _logs.removeAt(i));
                            },
                            child: Card(
                              margin: EdgeInsets.zero,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Icon(Icons.timer_outlined, color: scheme.primary, size: 18),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            DateFormat('MMM d, y • HH:mm').format(log.startTime),
                                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                          ),
                                          if (log.note.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 2),
                                              child: Text(
                                                log.note,
                                                style: TextStyle(color: scheme.onSurface.withOpacity(0.6), fontSize: 12),
                                                maxLines: 2,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      _formatDuration(log.duration),
                                      style: const TextStyle(
                                        fontFamily: 'Consolas',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
