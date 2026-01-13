import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/time_entry.dart';
import '/provider/time_entry_provider.dart';

class AddTimeEntryScreen extends StatefulWidget {
  @override
  _AddTimeEntryScreenState createState() => _AddTimeEntryScreenState();
}

class _AddTimeEntryScreenState extends State<AddTimeEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  String? projectId;
  String? taskId;

  double totalTime = 0.0;
  DateTime date = DateTime.now();
  String notes = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Time Entry',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFCE7F3), Color(0xFFDDD6FE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: <Widget>[
              _buildFormCard(
                child: DropdownButtonFormField<String>(
                  value: projectId,
                  hint: const Text('Select Project'),
                  onChanged: (String? newValue) {
                    setState(() {
                      projectId = newValue!;
                    });
                  },
                  decoration: _buildInputDecoration(
                    'Project',
                    Icons.business,
                    Color(0xFF8B5CF6),
                  ),
                  items: <String>['Project 1', 'Project 2', 'Project 3']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 16),
              _buildFormCard(
                child: DropdownButtonFormField<String>(
                  value: taskId,
                  hint: const Text('Select Task'),
                  onChanged: (String? newValue) {
                    setState(() {
                      taskId = newValue!;
                    });
                  },
                  decoration: _buildInputDecoration(
                    'Task',
                    Icons.task,
                    Color(0xFF06B6D4),
                  ),
                  items: <String>['Task 1', 'Task 2', 'Task 3']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 16),
              _buildFormCard(
                child: TextFormField(
                  decoration: _buildInputDecoration(
                    'Total Time (hours)',
                    Icons.timer,
                    Color(0xFF10B981),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter total time';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  onSaved: (value) => totalTime = double.parse(value!),
                ),
              ),
              SizedBox(height: 16),
              _buildFormCard(
                child: TextFormField(
                  decoration: _buildInputDecoration(
                    'Notes',
                    Icons.note,
                    Color(0xFFF97316),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some notes';
                    }
                    return null;
                  },
                  onSaved: (value) => notes = value!,
                ),
              ),
              SizedBox(height: 16),

_buildFormCard(
  child: ListTile(
    leading: Icon(Icons.calendar_today, color: Color(0xFF6366F1)),
    title: Text(
      'Date: ${date.toLocal().toString().split(' ')[0]}',
      style: const TextStyle(fontSize: 16),
    ),
    trailing: const Icon(Icons.edit_calendar),
    onTap: () async {
      final picked = await showDatePicker(
        context: context,
        initialDate: date,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
      );
      if (picked != null) {
        setState(() {
          date = picked;
        });
      }
    },
  ),
),

              SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      Provider.of<TimeEntryProvider>(context, listen: false)
                          .addTimeEntry(TimeEntry(
                        id: DateTime.now().toString(),
                        projectId: projectId!,
                        taskId: taskId!,
                        totalTime: totalTime,
                        date: date,
                        notes: notes,
                      ));
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Save Time Entry',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard({required Widget child}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    String label,
    IconData icon,
    Color color,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: color),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: color, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: color.withOpacity(0.3)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }
}