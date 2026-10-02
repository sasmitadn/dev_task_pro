import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart'; // Jangan lupa import intl

import '../../models/project.dart';
import '../../viewmodels/project_viewmodel.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/glowing_dots.dart';
// Sesuaikan import path untuk GlowingDots:
// import '../../widgets/glowing_dots.dart';

class AddProjectScreen extends StatefulWidget {
  final Project? project;
  const AddProjectScreen({super.key, this.project});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _systemCtrl = TextEditingController();
  final _brainstormCtrl = TextEditingController();

  final List<String> _statuses = ['plan', 'ditangguhkan', 'aktif', 'selesai', 'archive'];
  String _selectedStatus = 'aktif';

  String? _selectedCategoryId;
  String? _selectedPriorityId;

  DateTime? _dueDate;

  List<String> _techStack = [];
  final _techCtrl = TextEditingController();

  List<ProjectUrl> _urls = [];
  final _urlNameCtrl = TextEditingController();
  final _urlLinkCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.project != null) {
      final p = widget.project!;
      _nameCtrl.text = p.name;
      _descCtrl.text = p.description;
      _systemCtrl.text = p.system ?? '';
      _brainstormCtrl.text = p.brainstorming ?? '';
      _selectedStatus = p.status;
      _selectedCategoryId = p.categoryId.isEmpty ? null : p.categoryId;
      _selectedPriorityId = p.priorityId.isEmpty ? null : p.priorityId;
      _dueDate = p.dueDate;
      _techStack = List.from(p.techStack);
      _urls = List.from(p.urls);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _systemCtrl.dispose();
    _brainstormCtrl.dispose();
    _techCtrl.dispose();
    _urlNameCtrl.dispose();
    _urlLinkCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<ProjectViewModel>();
    final p = Project(
      id: widget.project?.id ?? const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      system: _systemCtrl.text.trim(),
      brainstorming: _brainstormCtrl.text.trim(),
      status: _selectedStatus,
      categoryId: _selectedCategoryId ?? '',
      priorityId: _selectedPriorityId ?? '',
      dueDate: _dueDate,
      techStack: _techStack,
      urls: _urls,
      order: widget.project?.order ?? vm.projects.length,
      createdAt: widget.project?.createdAt ?? DateTime.now(),
    );

    if (widget.project == null) {
      vm.addProject(p);
    } else {
      vm.updateProject(p);
    }
    Navigator.pop(context);
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Widget child}) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.03),
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
                style: TextStyle(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // Helper input decoration standar
  InputDecoration _inputDecor(String hint) {
    final scheme = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProjectViewModel>();
    final scheme = Theme.of(context).colorScheme;
    final isEditing = widget.project != null;

    return AppScaffold(
      title: isEditing ? 'Edit Project' : 'New Project',
      breadcrumb: 'Home > ${isEditing ? 'Edit Project' : 'New Project'}',
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check_rounded, size: 18),
            label: const Text('Save'),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          children: [
            // SECTION 1: GENERAL INFO
            _buildSectionCard(
              title: 'General Information',
              icon: Icons.info_outline_rounded,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    decoration: _inputDecor('Project Name').copyWith(
                      prefixIcon: const Icon(Icons.title_rounded),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Project name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descCtrl,
                    maxLines: 3,
                    minLines: 1,
                    decoration: _inputDecor('Description (Optional)'),
                  ),
                ],
              ),
            ),

            // SECTION 2: CLASSIFICATION
            _buildSectionCard(
              title: 'Classification',
              icon: Icons.category_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Status', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _statuses.map((s) {
                      final isSelected = _selectedStatus == s;
                      return ChoiceChip(
                        showCheckmark: false,
                        avatar: GlowingDots( // <-- Menggunakan GlowingDots di sini
                          isActive: isSelected,
                          activeColor: s == 'aktif' ? Colors.orange : scheme.primary,
                          size: 8,
                        ),
                        label: Text(s.toUpperCase()),
                        selected: isSelected,
                        selectedColor: scheme.primaryContainer,
                        labelStyle: TextStyle(
                          color: isSelected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                        onSelected: (val) {
                          if (val) setState(() => _selectedStatus = s);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  const Text('Category', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: vm.categories.map((c) {
                      final isSelected = _selectedCategoryId == c.id;
                      return FilterChip(
                        label: Text(c.name),
                        selected: isSelected,
                        showCheckmark: false,
                        selectedColor: scheme.primary.withValues(alpha: 0.15),
                        shape: StadiumBorder(
                          side: BorderSide(color: isSelected ? scheme.primary : scheme.outlineVariant),
                        ),
                        onSelected: (val) {
                          setState(() => _selectedCategoryId = val ? c.id : null);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  const Text('Priority', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: vm.priorities.map((p) {
                      final isSelected = _selectedPriorityId == p.id;
                      return FilterChip(
                        label: Text(p.name),
                        selected: isSelected,
                        showCheckmark: false,
                        selectedColor: Colors.red.withValues(alpha: 0.15),
                        shape: StadiumBorder(
                          side: BorderSide(color: isSelected ? Colors.red : scheme.outlineVariant),
                        ),
                        onSelected: (val) {
                          setState(() => _selectedPriorityId = val ? p.id : null);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // SECTION 3: SCHEDULE
            _buildSectionCard(
              title: 'Schedule',
              icon: Icons.calendar_month_outlined,
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                tileColor: scheme.surfaceContainerHighest.withValues(alpha: 0.2),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.event_rounded, color: Colors.orange),
                ),
                title: Text(
                  _dueDate == null ? 'Set Due Date' : DateFormat('dd MMMM yyyy').format(_dueDate!),
                  style: TextStyle(
                    fontWeight: _dueDate == null ? FontWeight.normal : FontWeight.bold,
                    color: _dueDate == null ? scheme.onSurfaceVariant : scheme.onSurface,
                  ),
                ),
                trailing: _dueDate != null
                    ? IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                  onPressed: () => setState(() => _dueDate = null), // Clear date
                  tooltip: 'Clear Date',
                )
                    : const Icon(Icons.chevron_right_rounded),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _dueDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: scheme.copyWith(primary: Colors.orange),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (d != null) setState(() => _dueDate = d);
                },
              ),
            ),

            // SECTION 4: TECH STACK & URLS
            _buildSectionCard(
              title: 'Tech Stack & Resources',
              icon: Icons.code_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tech Stack', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._techStack.map((t) => InputChip(
                        label: Text(t),
                        deleteIcon: const Icon(Icons.cancel, size: 18),
                        onDeleted: () => setState(() => _techStack.remove(t)),
                        backgroundColor: scheme.secondaryContainer,
                        side: BorderSide.none,
                      )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _techCtrl,
                          decoration: _inputDecor('Add technology (e.g. Laravel)'),
                          onSubmitted: (val) {
                            if (val.trim().isNotEmpty) {
                              setState(() {
                                _techStack.add(val.trim());
                                _techCtrl.clear();
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        onPressed: () {
                          if (_techCtrl.text.trim().isNotEmpty) {
                            setState(() {
                              _techStack.add(_techCtrl.text.trim());
                              _techCtrl.clear();
                            });
                          }
                        },
                        icon: const Icon(Icons.add),
                      )
                    ],
                  ),

                  const Divider(height: 40),

                  const Text('URLs & Links', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ..._urls.map((u) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.3)),
                    ),
                    child: ListTile(
                      dense: true,
                      leading: const Icon(Icons.link_rounded, color: Colors.blue),
                      title: Text(u.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(u.url, style: const TextStyle(color: Colors.blue)),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline_rounded, color: scheme.error),
                        onPressed: () => setState(() => _urls.remove(u)),
                      ),
                    ),
                  )),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: _urlNameCtrl,
                          decoration: _inputDecor('Name'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _urlLinkCtrl,
                          decoration: _inputDecor('https://...'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        onPressed: () {
                          if (_urlNameCtrl.text.isNotEmpty && _urlLinkCtrl.text.isNotEmpty) {
                            setState(() {
                              _urls.add(ProjectUrl(name: _urlNameCtrl.text.trim(), url: _urlLinkCtrl.text.trim()));
                              _urlNameCtrl.clear();
                              _urlLinkCtrl.clear();
                            });
                          }
                        },
                        icon: const Icon(Icons.add),
                      )
                    ],
                  ),
                ],
              ),
            ),

            // SECTION 5: NOTES
            _buildSectionCard(
              title: 'System Notes & Ideas',
              icon: Icons.lightbulb_outline_rounded,
              child: Column(
                children: [
                  TextFormField(
                    controller: _systemCtrl,
                    maxLines: 4,
                    minLines: 2,
                    decoration: _inputDecor('System architecture, design notes...'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _brainstormCtrl,
                    maxLines: 4,
                    minLines: 2,
                    decoration: _inputDecor('Brainstorming, sketches, raw ideas...'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80), // Padding bawah
          ],
        ),
      ),
    );
  }
}