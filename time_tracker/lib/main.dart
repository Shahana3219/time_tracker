import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'provider/time_entry_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => TimeEntryProvider(),
      child: const TimeTrackerApp(),
    ),
  );
}


class TimeTrackerApp extends StatelessWidget {
  const TimeTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TimeEntryProvider(),
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
      ),
    );
  }
}
