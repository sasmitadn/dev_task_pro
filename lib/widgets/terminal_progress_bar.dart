import 'package:flutter/material.dart';

class TerminalProgressBar extends StatelessWidget {
  final double value;
  final Color? color;
  final int ticks;

  const TerminalProgressBar({
    super.key,
    required this.value,
    this.color,
    this.ticks = 20,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final barColor = color ?? scheme.primary;
    final pct = (value * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final filled = (value * ticks).round();
                  return Row(
                    children: List.generate(ticks, (i) {
                      final isFilled = i < filled;
                      return Expanded(
                        child: Container(
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: isFilled
                                ? barColor
                                : barColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '$pct%',
              style: TextStyle(
                fontFamily: 'Consolas',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: barColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
