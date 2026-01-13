import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/time_entry_provider.dart';
import 'add_time_entry_screen.dart';
import 'project_management_screen.dart';
import 'task_management_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TimeEntryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Time Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              child: Text(
                'All Entries',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
            Tab(
              child: Text(
                'Group by Project',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),

      /* =======================
         HAMBURGER MENU (menu.png)
         ======================= */
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF6366F1)),
              child: Text(
                'Time Tracker',
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Projects'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProjectManagementScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.task),
              title: const Text('Tasks'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TaskManagementScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      /* =======================
         BODY
         ======================= */
      body: provider.entries.isEmpty
          ? _buildEmptyState()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAllEntries(provider),
                _buildGroupedEntries(provider),
              ],
            ),

      /* =======================
         ADD ENTRY BUTTON
         ======================= */
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddTimeEntryScreen()),
          );
        },
      ),
    );
  }

  /* =======================
     EMPTY STATE (home-empty.png)
     ======================= */
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timer_off, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No time entries yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Tap + to add your first entry'),
        ],
      ),
    );
  }

  /* =======================
     ALL ENTRIES (home-entries.png)
     DELETE → entry-delete.png
     ======================= */
  Widget _buildAllEntries(TimeEntryProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: provider.entries.length,
      itemBuilder: (context, index) {
        final entry = provider.entries[index];

        return Dismissible(
          key: ValueKey(entry.id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (_) {
            provider.deleteTimeEntry(entry.id);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Entry deleted'), duration: Duration(seconds: 2)),
            );
          },
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(
                entry.projectId,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
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
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                tooltip: 'Delete entry',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Entry'),
                      content: Text('Delete "${entry.projectId}" entry?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            provider.deleteTimeEntry(entry.id);
                            Navigator.pop(context);
                          },
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  /* =======================
     GROUPED VIEW (home-entries-group.png)
     ======================= */
  Widget _buildGroupedEntries(TimeEntryProvider provider) {
    final grouped = <String, List<dynamic>>{};

    for (var entry in provider.entries) {
      grouped.putIfAbsent(entry.projectId, () => []).add(entry);
    }

    return ListView(
      children: grouped.entries.map((group) {
        return ExpansionTile(
          title: Text(
            group.key,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          children: group.value.map((entry) {
            return ListTile(
              title: Text(entry.taskId),
              subtitle: Text(
                '${entry.totalTime} hrs • ${entry.date.toLocal().toString().split(' ')[0]}',
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
