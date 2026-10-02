import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/project.dart';
import '../../models/task_folder.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/quick_add_field.dart';
import '../../widgets/confirm_delete_dialog.dart';
import '../../widgets/terminal_progress_bar.dart';
import 'task_folder_screen.dart';

class TaskScreen extends StatelessWidget {
  final Project project;
  const TaskScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TaskViewModel>();
    final folders = vm.getFolders(project.id);
    final scheme = Theme.of(context).colorScheme;

    return AppScaffold(
      title: 'Tasks',
      breadcrumb: 'Home > Project > Tasks',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: QuickAddField(
              hintText: 'New task folder...',
              onAdd: (name) => vm.addFolder(project.id, name),
            ),
          ),
          if (folders.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.checklist_rounded, size: 56, color: scheme.onSurface.withOpacity(0.2)),
                    const SizedBox(height: 12),
                    Text('No task folders', style: TextStyle(color: scheme.onSurface.withOpacity(0.4))),
                    const SizedBox(height: 4),
                    Text('Type a name above to create one', style: TextStyle(color: scheme.onSurface.withOpacity(0.3), fontSize: 12)),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: folders.length,
                onReorderItem: (oldIndex, newIndex) => vm.reorderFolders(project.id, oldIndex, newIndex),
                buildDefaultDragHandles: false,
                itemBuilder: (_, i) {
                  final folder = folders[i];
                  final subtasks = vm.getSubTasks(folder.id);
                  final done = subtasks.where((s) => s.isCompleted).length;
                  final total = subtasks.length;
                  final progress = total == 0 ? 0.0 : done / total;

                  return _FolderCard(
                    // key: Key(folder.id),
                    folder: folder,
                    index: i,
                    project: project,
                    progress: progress,
                    done: done,
                    total: total,
                    vm: vm,
                  ).animate(key: ValueKey(folder.id)).fadeIn(delay: (i * 50).ms, duration: 250.ms);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _FolderCard extends StatelessWidget {
  final TaskFolder folder;
  final int index;
  final Project project;
  final double progress;
  final int done;
  final int total;
  final TaskViewModel vm;

  const _FolderCard({
    super.key,
    required this.folder,
    required this.index,
    required this.project,
    required this.progress,
    required this.done,
    required this.total,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: Key('dismiss_${folder.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: scheme.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      confirmDismiss: (_) => ConfirmDeleteDialog.show(
        context,
        title: 'Delete Folder',
        content: 'Delete "${folder.name}" and all its subtasks?',
      ),
      onDismissed: (_) => vm.deleteFolder(project.id, folder.id),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TaskFolderScreen(project: project, folder: folder),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_handle_rounded, color: Colors.grey, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            folder.isCompleted
                                ? Icons.folder_off_rounded
                                : Icons.folder_outlined,
                            color: folder.isCompleted ? Colors.green : scheme.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              folder.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                decoration: folder.isCompleted ? TextDecoration.lineThrough : null,
                                color: folder.isCompleted
                                    ? scheme.onSurface.withOpacity(0.4)
                                    : scheme.onSurface,
                              ),
                            ),
                          ),
                          Text(
                            '$done/$total',
                            style: TextStyle(
                              fontFamily: 'Consolas',
                              fontSize: 12,
                              color: scheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      if (total > 0) ...[
                        const SizedBox(height: 8),
                        TerminalProgressBar(value: progress, ticks: 15),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
