import 'package:flutter/material.dart';
import 'package:project_manager/widgets/glowing_dots.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../viewmodels/project_viewmodel.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../../viewmodels/timesheet_viewmodel.dart';
import '../timesheet/stop_timesheet_sheet.dart';

import '../../widgets/app_scaffold.dart';
import '../../widgets/terminal_progress_bar.dart';
import '../../widgets/confirm_delete_dialog.dart';
import '../../models/project.dart';
import '../../models/category.dart';
import '../../models/priority.dart';
import '../project/project_detail_screen.dart';
import '../project/add_project_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../settings/settings_screen.dart';
import 'package:intl/intl.dart';

import '../task/task_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectViewModel>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProjectViewModel>();
    final taskVm = context.watch<TaskViewModel>();
    final scheme = Theme.of(context).colorScheme;

    return AppScaffold(
      title: 'Projects',
      breadcrumb: 'Home',
      showBack: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
        ),
      ],
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: TextField(
                      controller: _searchController,
                      onChanged: vm.setSearch,
                      decoration: InputDecoration(
                        hintText: 'Search projects...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: vm.searchQuery.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            vm.setSearch('');
                          },
                        )
                            : null,
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        // Outline rounded penuh & tipis saat idle
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.22),
                            width: 1.0,
                          ),
                        ),
                        // Outline saat aktif/fokus
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1.2,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 44,
                    child: Builder(
                      builder: (context) {
                        return ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            _CategoryChip(
                              label: 'All',
                              count: vm.projects.length,
                              selected: vm.selectedCategoryId == null,
                              onTap: () => vm.setCategory(null),
                            ),
                            ...vm.categories.map((c) {
                              return _CategoryChip(
                                label: c.name,
                                count: vm.countByCategory(c.id),
                                selected: vm.selectedCategoryId == c.id,
                                onTap: () => vm.setCategory(
                                  vm.selectedCategoryId == c.id ? null : c.id,
                                ),
                              );
                            }),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
                if (vm.projects.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.folder_open_rounded,
                            size: 64,
                            color: scheme.onSurface.withOpacity(0.2),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No projects yet',
                            style: TextStyle(color: scheme.onSurface.withOpacity(0.4)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap + to add your first project',
                            style: TextStyle(
                              color: scheme.onSurface.withOpacity(0.3),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverReorderableList(
                    itemCount: vm.projects.length,
                    itemBuilder: (context, index) {
                      final p = vm.projects[index];
                      return ReorderableDelayedDragStartListener(
                        key: Key(p.id),
                        index: index,
                        child: _ProjectCard(
                          project: p,
                          vm: vm,
                          taskVm: taskVm,
                        ).animate().fadeIn(delay: (index * 50).ms, duration: 300.ms).slideY(begin: 0.1),
                      );
                    },
                    onReorder: (oldIndex, newIndex) {
                      vm.reorderProjects(oldIndex, newIndex);
                    },
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddProjectScreen()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Project', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    this.count = 0,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // const Color activeTeal = Color(0xFF1DE9B6);
    final Color activeTeal = Theme.of(context).colorScheme.primary;
    final Color inactiveBorder = Colors.grey.shade800; // Abu-abu gelap untuk border OFF
    final Color inactiveText = Colors.grey.shade400; // Abu-abu medium untuk teks OFF

    // Konfigurasi state OFF (default)
    Color currentOutlineColor = inactiveBorder;
    Color currentLabelColor = inactiveText;
    Color currentCountColor = inactiveText;

    // Modifikasi state jika ON
    if (selected) {
      currentOutlineColor = activeTeal;
      currentLabelColor = activeTeal;
      currentCountColor = activeTeal;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent, // Background Material transparan
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50), // Sesuai bentuk container
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.transparent, // Background Container transparan
              borderRadius: BorderRadius.circular(50), // Rounded penuh (Pill/Stadium shape)
              border: Border.all(
                color: currentOutlineColor, // Outline dinamis
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min, // Sesuai konten
              children: [
                // Indikator Titik (Dot) - Hanya muncul saat Aktif (ON)
                if (selected) ...[
                  GlowingDots(
                    activeColor: Theme.of(context).colorScheme.primary,
                    size: 6,
                  ),
                  const SizedBox(width: 8), // Spasi setelah titik
                ],
                // Teks Label (Contoh: "Semua", "Other")
                Text(
                  label,
                  style: TextStyle(
                    color: currentLabelColor, // Teks label dinamis
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8), // Spasi sebelum counter
                // Teks Counter Angka (Contoh: "3", "0")
                Text(
                  count.toString(),
                  style: TextStyle(
                    color: currentCountColor, // Teks counter dinamis
                    fontWeight: FontWeight.w400,
                    fontSize: 12, // Sedikit lebih kecil dari label
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;
  final ProjectViewModel vm;
  final TaskViewModel taskVm;

  const _ProjectCard({required this.project, required this.vm, required this.taskVm});

  Color _statusColor(String status, ColorScheme scheme) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return Colors.green;
      case 'ditangguhkan':
        return Colors.orange;
      case 'archive':
        return Colors.grey;
      case 'plan':
        return Colors.blue;
      default:
        return scheme.primary;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return Icons.check_circle_rounded;
      case 'ditangguhkan':
        return Icons.pause_circle_rounded;
      case 'archive':
        return Icons.archive_rounded;
      case 'plan':
        return Icons.lightbulb_outline;
      default:
        return Icons.play_circle_fill_rounded;
    }
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
      // failed open browser
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final priority = vm.priorities.firstWhere(
      (p) => p.id == project.priorityId,
      orElse: () => _emptyPriority(),
    );
    final category = vm.categories.firstWhere(
      (c) => c.id == project.categoryId,
      orElse: () => _emptyCategory(),
    );
    final progress = taskVm.getProgress(project.id);
    final timesheetVm = context.watch<TimesheetViewModel>();
    final isRunningThis = timesheetVm.isRunning && timesheetVm.runningProject?.id == project.id;

    return Dismissible(
      key: Key('dismiss_${project.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: scheme.error,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 32),
      ),
      confirmDismiss: (_) => ConfirmDeleteDialog.show(
        context,
        title: 'Delete Project',
        content: 'Delete "${project.name}"? This will also remove all tasks and timesheets.',
      ),
      onDismissed: (_) => vm.deleteProject(project.id),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: scheme.onSurface.withValues(alpha: 0.22),
            width: 1.0,
          ),
        ),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProjectDetailScreen(project: project)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GlowingDots(
                      isActive: project.status.toLowerCase() == 'aktif',
                      activeColor: Colors.orange,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        project.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        isRunningThis ? Icons.stop_circle_rounded : Icons.play_circle_fill_rounded,
                        color: isRunningThis ? Colors.red : Colors.green,
                        size: 28,
                      ),
                      onPressed: () {
                        if (isRunningThis) {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const StopTimesheetSheet(),
                          );
                        } else {
                          timesheetVm.start(project);
                        }
                      },
                    ),
                  ],
                ),
                if (project.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    project.description,
                    style: TextStyle(
                      color: scheme.onSurface.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatusChip(
                      label: project.status.toUpperCase(),
                      color: _statusColor(project.status, scheme),
                      icon: _statusIcon(project.status),
                    ),
                    if (category.name.isNotEmpty)
                      _Tag(label: category.name, icon: Icons.folder_outlined, color: scheme.primary),
                    if (priority.name.isNotEmpty)
                      _Tag(label: priority.name, icon: Icons.flag_outlined, color: Colors.redAccent),
                  ],
                ),
                const SizedBox(height: 16),
                TerminalProgressBar(value: progress),
                const SizedBox(height: 8),

                // Categories and Priority
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (project.dueDate != null) ...[
                      _Tag(
                        label: DateFormat('MMM d, yyyy').format(project.dueDate!),
                        icon: Icons.calendar_today_outlined,
                        color: Colors.orange,
                      ),
                    ]
                  ],
                ),
                
                if (project.techStack.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: project.techStack.map((t) => _Tag(label: t, icon: Icons.code, color: Colors.blueGrey)).toList(),
                  ),
                ],
                
                if (project.urls.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: project.urls.map((u) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: InkWell(
                        onTap: () => _openUrl(u.url),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.link, size: 16, color: Colors.blue),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                u.name,
                                style: const TextStyle(color: Colors.blue, fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )).toList(),
                  )
                ],

                if (project.system != null && project.system!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.computer, size: 16, color: scheme.primary),
                            const SizedBox(width: 8),
                            const Text('System Notes', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(project.system!, style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TaskScreen(project: project)),
                    ),
                    icon: Icon(Icons.list_alt, color: scheme.primary,),
                    label: Text('Daftar To-Do', style: TextStyle(fontSize: 16, color: scheme.primary)),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: scheme.primaryContainer,
                      foregroundColor: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusChip({required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color; // Dibuat opsional jika ingin default ke scheme.primary

  const _Tag({
    required this.label,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = color ?? Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: primaryColor,
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: primaryColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

Priority _emptyPriority() => Priority(id: '', name: '', level: 0);
Category _emptyCategory() => Category(id: '', name: '');
