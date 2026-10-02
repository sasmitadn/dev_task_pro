import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/project.dart';
import '../../models/task_folder.dart';
import '../../models/subtask.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../../viewmodels/timesheet_viewmodel.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/quick_add_field.dart';
import '../../widgets/confirm_delete_dialog.dart';

class TaskFolderScreen extends StatefulWidget {
  final Project project;
  final TaskFolder folder;

  const TaskFolderScreen({super.key, required this.project, required this.folder});

  @override
  State<TaskFolderScreen> createState() => _TaskFolderScreenState();
}

class _TaskFolderScreenState extends State<TaskFolderScreen> {
  String? _editingId;
  final Map<String, TextEditingController> _editControllers = {};

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TaskViewModel>();
    final timesheetVm = context.watch<TimesheetViewModel>();
    final subtasks = vm.getSubTasks(widget.folder.id);
    final scheme = Theme.of(context).colorScheme;

    return AppScaffold(
      title: widget.folder.name,
      breadcrumb: 'Home > Project > Tasks > ${widget.folder.name}',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: QuickAddField(
              hintText: 'Add subtask...',
              onAdd: (name) => vm.addSubTask(widget.folder.id, name),
            ),
          ),
          if (subtasks.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_box_outline_blank_rounded, size: 56, color: scheme.onSurface.withOpacity(0.2)),
                    const SizedBox(height: 12),
                    Text('No subtasks', style: TextStyle(color: scheme.onSurface.withOpacity(0.4))),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: subtasks.length,
                onReorderItem: (oldIndex, newIndex) =>
                    vm.reorderSubTasks(widget.folder.id, oldIndex, newIndex),
                buildDefaultDragHandles: false,
                itemBuilder: (_, i) {
                  final st = subtasks[i];
                  return _SubTaskItem(
                    // key: Key(st.id),
                    subtask: st,
                    index: i,
                    folderId: widget.folder.id,
                    project: widget.project,
                    isEditing: _editingId == st.id,
                    editController: _editControllers.putIfAbsent(st.id, () => TextEditingController(text: st.name)),
                    onToggle: () => vm.toggleSubTask(st),
                    onEdit: () => setState(() => _editingId = st.id),
                    onSave: () {
                      final ctrl = _editControllers[st.id];
                      if (ctrl != null && ctrl.text.trim().isNotEmpty) {
                        st.name = ctrl.text.trim();
                        vm.updateSubTask(st);
                      }
                      setState(() => _editingId = null);
                    },
                    onDelete: () async {
                      final confirm = await ConfirmDeleteDialog.show(
                        context,
                        title: 'Delete Subtask',
                        content: 'Delete "${st.name}"?',
                      );
                      if (confirm) vm.deleteSubTask(widget.folder.id, st.id);
                    },
                    onStartTimer: () async {
                      if (timesheetVm.isRunning) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('A timer is already running')),
                        );
                        return;
                      }
                      await timesheetVm.start(
                        widget.project,
                        taskFolderId: widget.folder.id,
                        subtaskId: st.id,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Timer started for: ${st.name}')),
                        );
                      }
                    },
                  ).animate(key: ValueKey(st.id)).fadeIn(delay: (i * 30).ms, duration: 200.ms);
                },
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (final ctrl in _editControllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }
}

class _SubTaskItem extends StatelessWidget {
  final SubTask subtask;
  final int index;
  final String folderId;
  final Project project;
  final bool isEditing;
  final TextEditingController editController;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onSave;
  final VoidCallback onDelete;
  final VoidCallback onStartTimer;

  const _SubTaskItem({
    super.key,
    required this.subtask,
    required this.index,
    required this.folderId,
    required this.project,
    required this.isEditing,
    required this.editController,
    required this.onToggle,
    required this.onEdit,
    required this.onSave,
    required this.onDelete,
    required this.onStartTimer,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: Key('dismiss_${subtask.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 3),
        decoration: BoxDecoration(
          color: scheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 3),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              ReorderableDragStartListener(
                index: index,
                child: const Icon(Icons.drag_handle_rounded, color: Colors.grey, size: 18),
              ),
              Checkbox(
                value: subtask.isCompleted,
                onChanged: (_) => onToggle(),
                shape: const CircleBorder(),
              ),
              Expanded(
                child: isEditing
                    ? TextField(
                        controller: editController,
                        autofocus: true,
                        onSubmitted: (_) => onSave(),
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      )
                    : GestureDetector(
                        onDoubleTap: onEdit,
                        child: Text(
                          subtask.name,
                          style: TextStyle(
                            decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
                            color: subtask.isCompleted
                                ? scheme.onSurface.withOpacity(0.4)
                                : scheme.onSurface,
                          ),
                        ),
                      ),
              ),
              if (isEditing)
                IconButton(
                  icon: const Icon(Icons.check_rounded, size: 18),
                  onPressed: onSave,
                  color: Colors.green,
                )
              else ...[
                IconButton(
                  icon: const Icon(Icons.timer_outlined, size: 18),
                  onPressed: onStartTimer,
                  color: Colors.teal,
                  tooltip: 'Start Timer',
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: onEdit,
                  color: scheme.onSurface.withOpacity(0.4),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
