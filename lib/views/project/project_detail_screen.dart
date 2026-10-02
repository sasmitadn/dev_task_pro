import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/project.dart';
import '../../viewmodels/project_viewmodel.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../../viewmodels/timesheet_viewmodel.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/terminal_progress_bar.dart';
// import '../../widgets/glowing_dots.dart'; // Sesuaikan path

import '../timesheet/stop_timesheet_sheet.dart';
import '../task/task_screen.dart';
import 'add_project_screen.dart';
import 'timesheet_log_screen.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  late Project _project;

  @override
  void initState() {
    super.initState();
    _project = widget.project;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskViewModel>().loadFolders(_project.id);
    });
  }

  Future<void> _openUrl(String text) async {
    String input = text.trim();
    if (input.isEmpty) return;
    // Example true: "sasmitadn.com", "sub.domain.org/path", "https://google.com"
    final urlPattern = RegExp(
      r'^(https?:\/\/)?([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}(:\d+)?(\/.*)?$',
      caseSensitive: false,
    );

    String targetUrl;
    if (urlPattern.hasMatch(input)) {
      // if url but no http/s
      targetUrl = input.startsWith('http://') || input.startsWith('https://')
          ? input
          : 'https://$input';
    } else {
      // if not domain/url
      targetUrl = 'https://www.google.com/search?q=${Uri.encodeComponent(input)}';
    }

    final uri = Uri.parse(targetUrl);
    try {
      await launchUrl(
        uri,
        mode: LaunchMode.inAppBrowserView,
        browserConfiguration: const BrowserConfiguration(showTitle: true),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening browser: $e')),
        );
      }
    }
  }

  // Helper untuk membungkus section dengan Card modern
  Widget _buildSectionCard({required String title, required IconData icon, required Widget child}) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: scheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(color: scheme.primary, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final projectVm = context.watch<ProjectViewModel>();
    final taskVm = context.watch<TaskViewModel>();
    final timesheetVm = context.watch<TimesheetViewModel>();
    final scheme = Theme.of(context).colorScheme;

    final isRunningThis = timesheetVm.isRunning && timesheetVm.runningProject?.id == _project.id;

    // Auto-refresh data
    _project = projectVm.projects.firstWhere((p) => p.id == _project.id, orElse: () => _project);

    final priority = projectVm.priorities.where((p) => p.id == _project.priorityId).firstOrNull;
    final category = projectVm.categories.where((c) => c.id == _project.categoryId).firstOrNull;

    final progress = taskVm.getProgress(_project.id);
    final total = taskVm.getTotalTasks(_project.id);
    final done = taskVm.getCompletedTasks(_project.id);

    return AppScaffold(
      title: _project.name,
      breadcrumb: 'Project > ${_project.name}',
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_rounded),
          tooltip: 'Edit Project',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddProjectScreen(project: _project)),
          ),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        children: [

          // ==========================================
          // 1. COMMAND CENTER (Aksi Utama Project)
          // ==========================================
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: isRunningThis
                  ? Colors.red.withValues(alpha: 0.1)
                  : scheme.primaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isRunningThis
                    ? Colors.red.withValues(alpha: 0.3)
                    : scheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                // Toggle Timesheet
                InkWell(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  onTap: () {
                    if (isRunningThis) {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const StopTimesheetSheet(),
                      );
                    } else {
                      timesheetVm.start(_project);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(
                          isRunningThis ? Icons.stop_circle_rounded : Icons.play_circle_fill_rounded,
                          color: isRunningThis ? Colors.red : scheme.primary,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isRunningThis ? 'Stop Working' : 'Start Timesheet',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: isRunningThis ? Colors.red.shade700 : scheme.onPrimaryContainer,
                                ),
                              ),
                              if (isRunningThis)
                                Text(
                                  'Elapsed: ${timesheetVm.formattedElapsed}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red.shade900,
                                    fontFamily: 'Consolas', // Monospace font for timer
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1, thickness: 1),
                // Quick Actions: To-Do & Logs
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20)),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TaskScreen(project: _project))),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.checklist_rounded, size: 20, color: scheme.primary),
                                const SizedBox(width: 8),
                                Text('To-Do List', style: TextStyle(fontWeight: FontWeight.bold, color: scheme.primary)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const VerticalDivider(width: 1, thickness: 1),
                      Expanded(
                        child: InkWell(
                          borderRadius: const BorderRadius.only(bottomRight: Radius.circular(20)),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TimesheetLogScreen(project: _project))),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.history_rounded, size: 20, color: scheme.primary),
                                const SizedBox(width: 8),
                                Text('Work Logs', style: TextStyle(fontWeight: FontWeight.bold, color: scheme.primary)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ==========================================
          // 2. OVERVIEW & PROGRESS
          // ==========================================
          _buildSectionCard(
            title: 'Overview',
            icon: Icons.dashboard_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_project.description.isNotEmpty) ...[
                  Text(
                    _project.description,
                    style: TextStyle(fontSize: 15, color: scheme.onSurface, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Progress', style: TextStyle(fontWeight: FontWeight.bold, color: scheme.onSurfaceVariant)),
                    Text('$done/$total Tasks', style: TextStyle(fontWeight: FontWeight.bold, color: scheme.primary)),
                  ],
                ),
                const SizedBox(height: 12),
                TerminalProgressBar(value: progress),
              ],
            ),
          ),

          // ==========================================
          // 3. ATTRIBUTES (Status, Kategori, Prioritas)
          // ==========================================
          _buildSectionCard(
            title: 'Attributes',
            icon: Icons.style_rounded,
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _StatusChip(status: _project.status),
                if (_project.dueDate != null)
                  _Tag(label: DateFormat('MMM d, yyyy').format(_project.dueDate!), icon: Icons.event_rounded, color: Colors.orange),
                if (category != null)
                  _Tag(label: category.name, icon: Icons.folder_rounded, color: scheme.primary),
                if (priority != null)
                  _Tag(label: priority.name, icon: Icons.flag_rounded, color: Colors.redAccent),
              ],
            ),
          ),

          // ==========================================
          // 4. RESOURCES (Tech Stack & URLs)
          // ==========================================
          if (_project.techStack.isNotEmpty || _project.urls.isNotEmpty)
            _buildSectionCard(
              title: 'Resources',
              icon: Icons.source_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_project.techStack.isNotEmpty) ...[
                    Text('Tech Stack', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: scheme.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _project.techStack.map((t) => _Tag(label: t, icon: Icons.code_rounded, color: Colors.blueGrey)).toList(),
                    ),
                    if (_project.urls.isNotEmpty) const SizedBox(height: 20),
                  ],
                  if (_project.urls.isNotEmpty) ...[
                    Text('Links & URLs', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: scheme.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    ..._project.urls.map((u) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        onTap: () => _openUrl(u.url),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.3)),
                        ),
                        tileColor: scheme.surfaceContainerHighest.withValues(alpha: 0.2),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.link_rounded, color: Colors.blue, size: 20),
                        ),
                        title: Text(u.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: Text(u.url, style: const TextStyle(color: Colors.blue, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: const Icon(Icons.open_in_new_rounded, size: 18, color: Colors.grey),
                      ),
                    )),
                  ],
                ],
              ),
            ),

          // ==========================================
          // 5. DOCUMENTATION (System & Brainstorming)
          // ==========================================
          if ((_project.system?.isNotEmpty ?? false) || (_project.brainstorming?.isNotEmpty ?? false))
            _buildSectionCard(
              title: 'Documentation',
              icon: Icons.article_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_project.system?.isNotEmpty ?? false) ...[
                    Row(
                      children: [
                        Icon(Icons.memory_rounded, size: 16, color: scheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Text('System Architecture & Notes', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: scheme.onSurfaceVariant)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: scheme.surfaceContainerHighest.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(12)),
                      child: Text(_project.system!, style: TextStyle(fontSize: 14, color: scheme.onSurface, height: 1.5)),
                    ),
                    if (_project.brainstorming?.isNotEmpty ?? false) const SizedBox(height: 20),
                  ],
                  if (_project.brainstorming?.isNotEmpty ?? false) ...[
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline_rounded, size: 16, color: scheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Text('Brainstorming & Ideas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: scheme.onSurfaceVariant)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: scheme.surfaceContainerHighest.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(12)),
                      child: Text(_project.brainstorming!, style: TextStyle(fontSize: 14, color: scheme.onSurface, height: 1.5)),
                    ),
                  ],
                ],
              ),
            ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// WIDGET HELPERS
// ---------------------------------------------------------

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  Color _getColor(String s, ColorScheme scheme) {
    switch (s.toLowerCase()) {
      case 'selesai': return Colors.green;
      case 'ditangguhkan': return Colors.orange;
      case 'archive': return Colors.grey;
      case 'plan': return Colors.blue;
      case 'aktif': return Colors.orange; // Glowing active color
      default: return scheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = _getColor(status, scheme);
    final isAktif = status.toLowerCase() == 'aktif';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Gunakan GlowingDots jika punya widgetnya, atau boxshadow manual:
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: isAktif ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 4, spreadRadius: 2)] : null,
            ),
          ),
          const SizedBox(width: 8),
          Text(status.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _Tag({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(50), // Pill shape for modern look
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }
}