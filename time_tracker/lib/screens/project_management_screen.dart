import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/time_entry_provider.dart';
import '../widgets/add_project_dialog.dart';
import '../models/project.dart';

class ProjectManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Projects'),
      ),
      body: Consumer<TimeEntryProvider>(
        builder: (context, provider, child) {
          // Lists for managing projects would be implemented here
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new project
        },
        child: Icon(Icons.add),
        tooltip: 'Add Project',
      ),
    );
  }
}