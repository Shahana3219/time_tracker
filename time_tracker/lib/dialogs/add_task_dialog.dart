import 'package:flutter/material.dart';

Future<Map<String, dynamic>?> showAddTaskDialog(BuildContext context) async {
  final _formKey = GlobalKey<FormState>();
  String taskName = '';
  String status = 'Pending';
  double progress = 0.0;

  return await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Add New Task'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Task Name',
                  prefixIcon: Icon(Icons.task, color: Color(0xFF8B5CF6)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter task name' : null,
                onSaved: (value) => taskName = value!,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: status,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: ['Pending', 'In Progress', 'Completed']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) => status = val!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                Navigator.pop(context, {
                  'name': taskName,
                  'status': status,
                  'color': Colors.primaries[DateTime.now().millisecondsSinceEpoch % Colors.primaries.length],
                  'progress': status == 'Completed' ? 1.0 : 0.0,
                });
              }
            },
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
}
