import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'provider/time_entry_provider.dart';
import 'provider/project_task_provider.dart';
import 'screens/add_time_entry_screen.dart';
import 'screens/project_management_screen.dart';
import 'screens/task_management_screen.dart';


void main() {
  runApp(const TimeTrackerApp());
}


class TimeTrackerApp extends StatelessWidget {
  const TimeTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TimeEntryProvider()),
        ChangeNotifierProvider(create: (context) => ProjectTaskProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Time Tracker',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color(0xFF6366F1),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF6366F1),
            foregroundColor: Colors.white,
            elevation: 8,
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF10B981),
            foregroundColor: Colors.white,
          ),
        ),
        home: HomeScreen(),
        routes: {
        '/add-entry': (_) => AddTimeEntryScreen(),
        '/projects': (_) => ProjectManagementScreen(),
        '/tasks': (_) => TaskManagementScreen(),
      },
      ),
    );
  }
}
