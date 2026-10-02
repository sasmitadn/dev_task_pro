import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../viewmodels/project_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';
import '../../core/db/app_database.dart';

import '../../widgets/app_scaffold.dart';
import '../../widgets/confirm_delete_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Widget _buildSectionCard({
    Key? key,
    required BuildContext context,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 24),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Icon(icon, size: 20, color: scheme.primary),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeVm = context.watch<ThemeViewModel>();
    final projectVm = context.watch<ProjectViewModel>();
    final scheme = Theme.of(context).colorScheme;

    return AppScaffold(
      title: 'Settings',
      breadcrumb: 'Home > Settings',
      body: ListView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. APPEARANCE
          _buildSectionCard(
            key: const ValueKey('section_appearance'),
            context: context,
            title: 'Appearance',
            icon: Icons.palette_outlined,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: themeVm.isDark ? Colors.indigo.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    themeVm.isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: themeVm.isDark ? Colors.indigoAccent : Colors.orange,
                  ),
                ),
                title: const Text('Theme', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(themeVm.isDark ? 'Dark Mode' : 'Light Mode'),
                trailing: Switch(
                  value: themeVm.isDark,
                  activeColor: scheme.primary,
                  onChanged: (_) => themeVm.toggle(),
                ),
              ),
            ),
          ).animate().fadeIn(delay: 50.ms),

          // 2. CATEGORIES
          _buildSectionCard(
            key: const ValueKey('section_categories'),
            context: context,
            title: 'Categories',
            icon: Icons.category_outlined,
            child: Column(
              children: [
                ..._buildCategoryItems(context, projectVm, scheme),
                _InlineAddItem(
                  hint: 'Add new category...',
                  onAdd: (name) => projectVm.addCategory(name),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms),

          // 3. PRIORITIES
          _buildSectionCard(
            key: const ValueKey('section_priorities'),
            context: context,
            title: 'Priorities',
            icon: Icons.flag_outlined,
            child: Column(
              children: [
                ..._buildPriorityItems(context, projectVm, scheme),
                _InlineAddItem(
                  hint: 'Add new priority...',
                  onAdd: (name) => projectVm.addPriority(name, 1),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 150.ms),

          // 4. DATA MANAGEMENT
          _buildSectionCard(
            key: const ValueKey('section_data'),
            context: context,
            title: 'Data Management',
            icon: Icons.storage_rounded,
            child: Column(
              children: [
                _DataTile(
                  icon: Icons.upload_file_rounded,
                  iconColor: Colors.blue,
                  title: 'Export Data',
                  subtitle: 'Save all data as JSON file',
                  onTap: () => _exportData(context),
                ),
                const Divider(height: 1, indent: 64, endIndent: 20),
                _DataTile(
                  icon: Icons.download_rounded,
                  iconColor: Colors.green,
                  title: 'Import Data',
                  subtitle: 'Load data from JSON file',
                  onTap: () => _importData(context),
                ),
                const Divider(height: 1, indent: 64, endIndent: 20),
                _DataTile(
                  icon: Icons.bluetooth_rounded,
                  iconColor: Colors.purple,
                  title: 'Transfer via Bluetooth',
                  subtitle: 'Send/receive data to another device',
                  isLast: true,
                  onTap: () => _showBluetoothInfo(context),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms),

          // APP INFO
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'Project Manager v1.0.0\nby Sasmitadn',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: scheme.onSurface.withValues(alpha: 0.3),
                  fontSize: 12,
                  fontFamily: 'Consolas',
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryItems(BuildContext context, ProjectViewModel vm, ColorScheme scheme) {
    return vm.categories.asMap().entries.map((entry) {
      final cat = entry.value;
      return Column(
        key: ValueKey('cat_${cat.id}'), // Tambahkan Key untuk stabilitas UI
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            leading: Icon(Icons.folder_outlined, size: 22, color: scheme.onSurfaceVariant),
            title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  color: scheme.primary,
                  onPressed: () => _showEditDialog(
                    context,
                    title: 'Edit Category',
                    initial: cat.name,
                    onSave: (name) {
                      cat.name = name;
                      vm.updateCategory(cat);
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded, size: 18, color: scheme.error),
                  onPressed: () async {
                    final confirm = await ConfirmDeleteDialog.show(
                      context,
                      title: 'Delete Category',
                      content: 'Delete "${cat.name}"?',
                    );
                    if (confirm) vm.deleteCategory(cat.id);
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 60, endIndent: 20),
        ],
      );
    }).toList();
  }

  List<Widget> _buildPriorityItems(BuildContext context, ProjectViewModel vm, ColorScheme scheme) {
    return vm.priorities.asMap().entries.map((entry) {
      final pri = entry.value;
      return Column(
        key: ValueKey('pri_${pri.id}'), // Tambahkan Key untuk stabilitas UI
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            leading: Icon(Icons.flag_outlined, size: 22, color: scheme.onSurfaceVariant),
            title: Text(pri.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('Level ${pri.level}', style: const TextStyle(fontSize: 12)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  color: scheme.primary,
                  onPressed: () => _showEditDialog(
                    context,
                    title: 'Edit Priority',
                    initial: pri.name,
                    onSave: (name) {
                      pri.name = name;
                      vm.updatePriority(pri);
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded, size: 18, color: scheme.error),
                  onPressed: () async {
                    final confirm = await ConfirmDeleteDialog.show(
                      context,
                      title: 'Delete Priority',
                      content: 'Delete "${pri.name}"?',
                    );
                    if (confirm) vm.deletePriority(pri.id);
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 60, endIndent: 20),
        ],
      );
    }).toList();
  }

  // BUG FIX: Gunakan class StatefulWidget khusus agar siklus hidup _ctrl terikat
  // langsung dengan dialog dan tidak dispose saat dialog masih sedang di-animasikan tutup
  Future<void> _showEditDialog(
      BuildContext context, {
        required String title,
        required String initial,
        required void Function(String) onSave,
      }) async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => _EditItemDialog(title: title, initial: initial),
    );

    if (result != null && result.isNotEmpty && result != initial) {
      onSave(result);
    }
  }

  Future<void> _exportData(BuildContext context) async {
    try {
      final data = await AppDatabase.instance.exportAll();
      final json = jsonEncode(data);
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/project_manager_export.json');
      await file.writeAsString(json);
      await Share.shareXFiles([XFile(file.path)], text: 'Project Manager Data Export');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }

  Future<void> _importData(BuildContext context) async {
    try {
      final files = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
      if (files.isEmpty || files.first.path == null) return;
      final json = await File(files.first.path!).readAsString();
      final data = jsonDecode(json) as Map<String, dynamic>;
      await AppDatabase.instance.importAll(data);
      if (context.mounted) {
        await context.read<ProjectViewModel>().loadAll();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data imported successfully!')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Import failed: $e')));
      }
    }
  }

  void _showBluetoothInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.bluetooth_rounded, color: Colors.blue),
            SizedBox(width: 10),
            Text('Bluetooth Transfer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: const Text(
          'To transfer data:\n\n'
              '1. Export data to JSON on this device.\n'
              '2. Use your device\'s Bluetooth file sharing to send the JSON file to the other device.\n'
              '3. On the receiving device, use Import Data to load it.\n\n'
              'The import uses "replace" strategy — newer entries will overwrite older ones.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogCtx),
            style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

// Helper Widget: Data Management Tile
class _DataTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isLast;

  const _DataTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 12 : 0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        onTap: onTap,
      ),
    );
  }
}

// STATEFUL WIDGET BARU: Memastikan _ctrl tidak di dispose sebelum animasi Dialog benar-benar selesai
class _EditItemDialog extends StatefulWidget {
  final String title;
  final String initial;

  const _EditItemDialog({required this.title, required this.initial});

  @override
  State<_EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<_EditItemDialog> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _ctrl.dispose(); // Terjamin aman, karena baru dihancurkan saat dialog hilang dari pohon elemen
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          labelText: 'Name',
          filled: true,
          fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: scheme.primary)),
        ),
        onSubmitted: (val) => Navigator.pop(context, val.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _ctrl.text.trim()),
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// UI/UX Baru untuk Inline Input
class _InlineAddItem extends StatefulWidget {
  final String hint;
  final void Function(String) onAdd;
  const _InlineAddItem({required this.hint, required this.onAdd});

  @override
  State<_InlineAddItem> createState() => _InlineAddItemState();
}

class _InlineAddItemState extends State<_InlineAddItem> {
  final _ctrl = TextEditingController();

  void _submit() {
    final text = _ctrl.text.trim();
    if (text.isNotEmpty) {
      _ctrl.clear(); // BUG FIX: Harus clear teks DULUAN sebelum memanggil widget.onAdd
      widget.onAdd(text); // Karena onAdd akan merender ulang layout list yang ada
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: TextField(
        controller: _ctrl,
        onSubmitted: (_) => _submit(),
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          hintText: widget.hint,
          filled: true,
          fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: scheme.primary),
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.add_circle_rounded),
            color: scheme.primary,
            onPressed: _submit,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}