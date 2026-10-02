import 'package:flutter/material.dart';

class QuickAddField extends StatefulWidget {
  final String hintText;
  final void Function(String) onAdd;
  final bool autofocus;

  const QuickAddField({
    super.key,
    required this.hintText,
    required this.onAdd,
    this.autofocus = false,
  });

  @override
  State<QuickAddField> createState() => _QuickAddFieldState();
}

class _QuickAddFieldState extends State<QuickAddField> {
  final _controller = TextEditingController();

  void _submit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onAdd(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      autofocus: widget.autofocus,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => _submit(),
      decoration: InputDecoration(
        hintText: widget.hintText,
        suffixIcon: IconButton(
          onPressed: _submit,
          icon: const Icon(Icons.add_circle_outline_rounded),
          color: Theme.of(context).colorScheme.primary,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
