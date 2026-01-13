import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProjectTaskProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _projects = [];
  final List<Map<String, dynamic>> _tasks = [];
  bool _isLoaded = false;

  List<Map<String, dynamic>> get projects => _projects;
  List<Map<String, dynamic>> get tasks => _tasks;
  bool get isLoaded => _isLoaded;

  ProjectTaskProvider() {
    _loadFromStorage(); // 🔑 LOAD ON START
  }

  Future<void> addProject(Map<String, dynamic> project) async {
    try {
      // Convert color to hex string before storing
      final projectToStore = {...project};
      if (projectToStore['color'] != null) {
        final color = projectToStore['color'] as Color;
        print('🎨 Color object type: ${color.runtimeType}');
        print('🎨 Color value: ${color.value}');
        final hexColor = '#${color.value.toRadixString(16).padLeft(8, '0')}';
        projectToStore['color'] = hexColor;
        print('🎨 Color conversion: ${color.runtimeType} -> $hexColor');
      }
      _projects.add(projectToStore);
      print('✅ Project added to list. Total projects: ${_projects.length}');
      print('📦 Projects data: $_projects');
      
      // Save to storage
      final result = await _saveProjectsToStorage(); // 🔑 SAVE
      print('💾 Storage save result: $result');
      
      notifyListeners();
      print('✅ notifyListeners() called');
    } catch (e, stackTrace) {
      print('❌ Error adding project: $e');
      print('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> updateProject(Map<String, dynamic> oldProject, Map<String, dynamic> newProject) async {
    final index = _projects.indexOf(oldProject);
    if (index != -1) {
      _projects[index] = newProject;
      await _saveProjectsToStorage(); // 🔑 SAVE
      notifyListeners();
    }
  }

  Future<void> deleteProject(Map<String, dynamic> project) async {
    _projects.remove(project);
    await _saveProjectsToStorage(); // 🔑 SAVE
    print('✅ Project deleted. Remaining projects: ${_projects.length}');
    notifyListeners();
  }

  Future<void> addTask(Map<String, dynamic> task) async {
    try {
      // Convert color to hex string before storing
      final taskToStore = {...task};
      if (taskToStore['color'] != null) {
        final color = taskToStore['color'] as Color;
        print('🎨 Color object type: ${color.runtimeType}');
        print('🎨 Color value: ${color.value}');
        final hexColor = '#${color.value.toRadixString(16).padLeft(8, '0')}';
        taskToStore['color'] = hexColor;
        print('🎨 Color conversion: ${color.runtimeType} -> $hexColor');
      }
      _tasks.add(taskToStore);
      print('✅ Task added to list. Total tasks: ${_tasks.length}');
      print('📦 Tasks data: $_tasks');
      
      // Save to storage
      final result = await _saveTasksToStorage(); // 🔑 SAVE
      print('💾 Storage save result: $result');
      
      notifyListeners();
      print('✅ notifyListeners() called');
    } catch (e, stackTrace) {
      print('❌ Error adding task: $e');
      print('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> updateTask(Map<String, dynamic> oldTask, Map<String, dynamic> newTask) async {
    final index = _tasks.indexOf(oldTask);
    if (index != -1) {
      _tasks[index] = newTask;
      await _saveTasksToStorage(); // 🔑 SAVE
      notifyListeners();
    }
  }

  Future<void> deleteTask(Map<String, dynamic> task) async {
    _tasks.remove(task);
    await _saveTasksToStorage(); // 🔑 SAVE
    print('✅ Task deleted. Remaining tasks: ${_tasks.length}');
    notifyListeners();
  }

  Future<bool> _saveProjectsToStorage() async {
    try {
      print('💾 Starting project storage save...');
      print('💾 Projects to save: $_projects');
      final prefs = await SharedPreferences.getInstance();
      print('💾 SharedPreferences instance obtained');
      
      final jsonList = jsonEncode(_projects);
      print('💾 JSON encoded: $jsonList');
      
      final saved = await prefs.setString('projects', jsonList);
      print('💾 Project storage save result: $saved');
      print('📦 projects key: $jsonList');
      
      // Verify it was saved
      final verified = prefs.getString('projects');
      print('✅ Verification - Value in storage: $verified');
      
      return saved;
    } catch (e) {
      print('❌ Error saving projects: $e');
      return false;
    }
  }

  Future<bool> _saveTasksToStorage() async {
    try {
      print('💾 Starting task storage save...');
      print('💾 Tasks to save: $_tasks');
      final prefs = await SharedPreferences.getInstance();
      print('💾 SharedPreferences instance obtained');
      
      final jsonList = jsonEncode(_tasks);
      print('💾 JSON encoded: $jsonList');
      
      final saved = await prefs.setString('tasks', jsonList);
      print('💾 Task storage save result: $saved');
      print('📦 tasks key: $jsonList');
      
      // Verify it was saved
      final verified = prefs.getString('tasks');
      print('✅ Verification - Value in storage: $verified');
      
      return saved;
    } catch (e) {
      print('❌ Error saving tasks: $e');
      return false;
    }
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load projects
      final projectsData = prefs.getString('projects');
      print('📦 Loading projects from storage: $projectsData');
      if (projectsData == null) {
        _projects.clear();
        await prefs.setString('projects', jsonEncode([]));
        print('📦 projects: []');
      } else {
        final decoded = jsonDecode(projectsData) as List;
        _projects.addAll(decoded.map((p) {
          final project = Map<String, dynamic>.from(p);
          // Convert hex color back to Color
          if (project['color'] is String) {
            try {
              project['color'] = Color(int.parse(project['color'].replaceFirst('#', '0x')));
              print('🎨 Loaded color: ${project['color']}');
            } catch (e) {
              print('❌ Error parsing color: $e');
              project['color'] = Colors.grey;
            }
          }
          return project;
        }).toList());
        print('📦 projects: $projectsData');
      }

      // Load tasks
      final tasksData = prefs.getString('tasks');
      print('📦 Loading tasks from storage: $tasksData');
      if (tasksData == null) {
        _tasks.clear();
        await prefs.setString('tasks', jsonEncode([]));
        print('📦 tasks: []');
      } else {
        final decoded = jsonDecode(tasksData) as List;
        _tasks.addAll(decoded.map((t) {
          final task = Map<String, dynamic>.from(t);
          // Convert hex color back to Color
          if (task['color'] is String) {
            try {
              task['color'] = Color(int.parse(task['color'].replaceFirst('#', '0x')));
              print('🎨 Loaded color: ${task['color']}');
            } catch (e) {
              print('❌ Error parsing color: $e');
              task['color'] = Colors.grey;
            }
          }
          return task;
        }).toList());
        print('📦 tasks: $tasksData');
      }

      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      print('❌ Error loading from storage: $e');
      _isLoaded = true;
      notifyListeners();
    }
  }

  List<String> getProjectNames() {
    return _projects.map((p) => p['name'] as String).toList();
  }

  List<String> getTaskNames() {
    return _tasks.map((t) => t['name'] as String).toList();
  }
}
