import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'viewmodels/project_viewmodel.dart';
import 'viewmodels/task_viewmodel.dart';
import 'viewmodels/timesheet_viewmodel.dart';
import 'viewmodels/theme_viewmodel.dart';
import 'views/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeVm = ThemeViewModel();
  await themeVm.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeVm),
        ChangeNotifierProvider(create: (_) => ProjectViewModel()),
        ChangeNotifierProvider(create: (_) => TaskViewModel()),
        ChangeNotifierProvider(create: (_) => TimesheetViewModel()),
      ],
      child: const ProjectManagerApp(),
    ),
  );
}

class ProjectManagerApp extends StatefulWidget {
  const ProjectManagerApp({super.key});

  @override
  State<ProjectManagerApp> createState() => _ProjectManagerAppState();
}

class _ProjectManagerAppState extends State<ProjectManagerApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final projectVm = context.read<ProjectViewModel>();
      await projectVm.loadAll();
      final timesheetVm = context.read<TimesheetViewModel>();
      await timesheetVm.init(projectVm.projects);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeVm = context.watch<ThemeViewModel>();

    return MaterialApp(
      title: 'Project Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeVm.mode,
      home: const HomeScreen(),
    );
  }
}
