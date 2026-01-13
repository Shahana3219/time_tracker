import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/provider/time_entry_provider.dart';
import 'add_time_entry_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Tracker'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16), // Bootstrap-like spacing
        child: Consumer<TimeEntryProvider>(
          builder: (context, provider, child) {
            if (provider.entries.isEmpty) {
              return const Center(
                child: Text(
                  'No time entries yet',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              itemCount: provider.entries.length,
              itemBuilder: (context, index) {
                final entry = provider.entries[index];

                return Card(
                  elevation: 4, // Bootstrap shadow
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      entry.projectId,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Task: ${entry.taskId}'),
                          Text('Hours: ${entry.totalTime}'),
                          Text(
                            'Date: ${entry.date.toLocal().toString().split(' ')[0]}',
                          ),
                          if (entry.notes.isNotEmpty)
                            Text('Notes: ${entry.notes}'),
                        ],
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        Provider.of<TimeEntryProvider>(
                          context,
                          listen: false,
                        ).deleteTimeEntry(entry.id);
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue, // Bootstrap primary
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddTimeEntryScreen()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Time Entry',
      ),
    );
  }
}
