import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../dialogs/add_task_dialog.dart';
import '../provider/time_entry_provider.dart';
import '../provider/project_task_provider.dart';

// Helper to convert hex string to Color
Color _hexToColor(dynamic color) {
  if (color is Color) return color;
  if (color is String) {
    return Color(int.parse(color.replaceFirst('#', '0x')));
  }
  return Colors.grey;
}

class TaskManagementScreen extends StatefulWidget {
  @override
  _TaskManagementScreenState createState() => _TaskManagementScreenState();
}

class _TaskManagementScreenState extends State<TaskManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Tasks',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer2<ProjectTaskProvider, TimeEntryProvider>(
        builder: (context, projectTaskProvider, timeEntryProvider, child) {
          // Combine user-added tasks with tasks from time entries
          final userTasks = projectTaskProvider.tasks;
          final timeEntryTaskNames = timeEntryProvider.entries
              .map((entry) => entry.taskId)
              .toSet()
              .toList();
          
          // Merge both lists, avoiding duplicates
          final allTasks = [...userTasks];
          for (var taskName in timeEntryTaskNames) {
            if (!allTasks.any((t) => t['name'] == taskName)) {
              allTasks.add({
                'name': taskName,
                'status': 'Active',
                'progress': 0.5,
                'color': Colors.primaries[timeEntryTaskNames.indexOf(taskName) % Colors.primaries.length],
              });
            }
          }

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: allTasks.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.task_alt, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No tasks yet',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('Add a task when creating a time entry'),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: allTasks.length,
                    itemBuilder: (context, index) {
                      final task = allTasks[index];
                      return _buildTaskCard(task);
                    },
                  ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTask = await showAddTaskDialog(context);
          if (newTask != null) {
            await Provider.of<ProjectTaskProvider>(context, listen: false).addTask(newTask);
          }
        },
        child: const Icon(Icons.add, size: 28),
        tooltip: 'Add Task',
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              _hexToColor(task['color']),
              _hexToColor(task['color']).withOpacity(0.7)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  task['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    task['status'],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Progress', style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text(
                  '${(task['progress'] * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: task['progress'],
                minHeight: 8,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                  onPressed: () {
                    _editTask(context, task);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white70, size: 20),
                  onPressed: () {
                    _deleteTask(context, task);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _editTask(BuildContext context, Map<String, dynamic> task) {
    final controller = TextEditingController(text: task['name']);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Task'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Task Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final updated = {...task, 'name': controller.text};
                await Provider.of<ProjectTaskProvider>(context, listen: false)
                    .updateTask(task, updated);
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteTask(BuildContext context, Map<String, dynamic> task) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Delete "${task['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await Provider.of<ProjectTaskProvider>(context, listen: false)
                  .deleteTask(task);
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Task deleted'), duration: Duration(seconds: 2)),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}