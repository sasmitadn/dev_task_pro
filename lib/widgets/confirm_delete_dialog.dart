import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  final String title;
  final String content;

  const ConfirmDeleteDialog({
    super.key,
    required this.title,
    required this.content,
  });

  static Future<bool> show(BuildContext context, {required String title, required String content}) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => ConfirmDeleteDialog(title: title, content: content),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 10),
          Text(title),
        ],
      ),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete'),
        ),
      ],
    ).animate().scale(begin: const Offset(0.9, 0.9), duration: 200.ms);
  }
}
