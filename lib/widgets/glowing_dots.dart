import 'package:flutter/material.dart';

class GlowingDots extends StatefulWidget {
  final bool isActive;
  final Color activeColor;
  final Color? inactiveColor;
  final double size;

  const GlowingDots({
    super.key,
    this.isActive = true,
    required this.activeColor,
    this.inactiveColor,
    this.size = 8.0,
  });

  @override
  State<GlowingDots> createState() => _GlowingDotsState();
}

class _GlowingDotsState extends State<GlowingDots> {
  @override
  Widget build(BuildContext context) {
    final inactive = widget.inactiveColor ?? Colors.grey.shade600;
    final currentColor = widget.isActive ? widget.activeColor : inactive;

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: currentColor,
        boxShadow: [
          BoxShadow(
            color: currentColor.withValues(alpha: 0.28),
            spreadRadius: widget.size * 0.5,
            blurRadius: widget.size * 0.4,
          )
        ],
      ),
    );
  }
}