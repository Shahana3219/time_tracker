import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/time_entry_provider.dart';
import '../provider/project_task_provider.dart';
import '../dialogs/add_project_dialog.dart';

// Helper to convert hex string to Color
Color _hexToColor(dynamic color) {
  if (color is Color) return color;
  if (color is String) {
    return Color(int.parse(color.replaceFirst('#', '0x')));
  }
  return Colors.grey;
}


class ProjectManagementScreen extends StatefulWidget {
  @override
  _ProjectManagementScreenState createState() => _ProjectManagementScreenState();
}

class _ProjectManagementScreenState extends State<ProjectManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Projects',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer2<ProjectTaskProvider, TimeEntryProvider>(
        builder: (context, projectTaskProvider, timeEntryProvider, child) {
          // Combine user-added projects with projects from time entries
          final userProjects = projectTaskProvider.projects;
          final timeEntryProjectNames = timeEntryProvider.entries
              .map((entry) => entry.projectId)
              .toSet()
              .toList();
          
          // Merge both lists, avoiding duplicates
          final allProjects = [...userProjects];
          for (var projectName in timeEntryProjectNames) {
            if (!allProjects.any((p) => p['name'] == projectName)) {
              allProjects.add({
                'name': projectName,
                'color': Colors.primaries[timeEntryProjectNames.indexOf(projectName) % Colors.primaries.length],
              });
            }
          }

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: allProjects.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_off, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No projects yet',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('Add a project when creating a time entry'),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: allProjects.length,
                    itemBuilder: (context, index) {
                      final project = allProjects[index];
                      return _buildProjectListItem(project);
                    },
                  ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
  onPressed: () async {
    final newProjectName = await showAddProjectDialog(context);
    if (newProjectName != null && newProjectName.isNotEmpty) {
      final projectTaskProvider = Provider.of<ProjectTaskProvider>(context, listen: false);
      await projectTaskProvider.addProject({
        'name': newProjectName,
        'color': Colors.primaries[projectTaskProvider.projects.length % Colors.primaries.length],
      });
    }
  },
  child: const Icon(Icons.add, size: 28),
  tooltip: 'Add Project',
),

    );
  }

  Widget _buildProjectListItem(Map<String, dynamic> project) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              _hexToColor(project['color']),
              _hexToColor(project['color']).withOpacity(0.7)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListTile(
          leading: Icon(
            project['icon'],
            size: 32,
            color: Colors.white,
          ),
          title: Text(
            project['name'],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                onPressed: () => _editProject(project),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.white70, size: 20),
                onPressed: () => _deleteProject(project),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editProject(Map<String, dynamic> project) {
    final controller = TextEditingController(text: project['name']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Project'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Project Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final updated = {...project, 'name': controller.text};
                Provider.of<ProjectTaskProvider>(context, listen: false)
                    .updateProject(project, updated);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteProject(Map<String, dynamic> project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text('Delete "${project['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Provider.of<ProjectTaskProvider>(context, listen: false)
                  .deleteProject(project);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Project deleted'), duration: Duration(seconds: 2)),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
