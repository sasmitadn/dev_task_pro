import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../viewmodels/timesheet_viewmodel.dart';
import 'stop_timesheet_sheet.dart';

class TimesheetBanner extends StatelessWidget {
  const TimesheetBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TimesheetViewModel>();
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const StopTimesheetSheet(),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [scheme.primary.withOpacity(0.9), scheme.tertiary.withOpacity(0.8)],
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fade(duration: 600.ms, begin: 0.2, end: 1.0),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vm.runningProject?.name ?? 'Unknown Project',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'Timer running • Tap to stop',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              vm.formattedElapsed,
              style: const TextStyle(
                fontFamily: 'Consolas',
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
