import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/timesheet_viewmodel.dart';
import '../views/timesheet/timesheet_banner.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final String? breadcrumb;
  final Widget body;
  final Widget? floatingActionButton;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final bool showBack;

  const AppScaffold({
    super.key,
    required this.title,
    this.breadcrumb,
    required this.body,
    this.floatingActionButton,
    this.actions,
    this.bottomNavigationBar,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    final timesheetVm = context.watch<TimesheetViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            if (breadcrumb != null)
              Text(
                breadcrumb!,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        actions: actions,
        automaticallyImplyLeading: showBack,
      ),
      body: Column(
        children: [
          if (timesheetVm.isRunning) const TimesheetBanner(),
          Expanded(child: body),
        ],
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
