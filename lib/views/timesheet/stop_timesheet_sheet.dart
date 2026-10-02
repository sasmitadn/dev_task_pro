import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/timesheet_viewmodel.dart';

class StopTimesheetSheet extends StatefulWidget {
  const StopTimesheetSheet({super.key});

  @override
  State<StopTimesheetSheet> createState() => _StopTimesheetSheetState();
}

class _StopTimesheetSheetState extends State<StopTimesheetSheet> {
  final _noteController = TextEditingController();
  bool _stopping = false;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TimesheetViewModel>();
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Stop Timer',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Project: ${vm.runningProject?.name ?? "Unknown"}',
              style: TextStyle(color: scheme.onSurface.withOpacity(0.6)),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: scheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: scheme.primary.withOpacity(0.3)),
              ),
              child: Text(
                vm.formattedElapsed,
                style: TextStyle(
                  fontFamily: 'Consolas',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: scheme.primary,
                  letterSpacing: 4,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Add a note (optional)...',
                labelText: 'Session Note',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Keep Running'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _stopping
                        ? null
                        : () async {
                            setState(() => _stopping = true);
                            await vm.stop(_noteController.text.trim());
                            if (mounted) Navigator.pop(context);
                          },
                    icon: const Icon(Icons.stop_rounded),
                    label: const Text('Stop & Save'),
                    style: FilledButton.styleFrom(backgroundColor: scheme.error),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}
