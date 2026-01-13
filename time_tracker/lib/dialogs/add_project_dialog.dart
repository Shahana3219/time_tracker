import 'package:flutter/material.dart';

Future<String?> showAddProjectDialog(BuildContext context) async {
  String projectName = '';
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Add New Project'),
        content: TextField(
          onChanged: (value) {
            projectName = value;
          },
          decoration: InputDecoration(hintText: "Project Name"),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: Text('Add'),
            onPressed: () => Navigator.of(context).pop(projectName),
          ),
        ],
      );
    },
  );
}
