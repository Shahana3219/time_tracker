import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/time_entry.dart';

class TimeEntryProvider extends ChangeNotifier {
  List<TimeEntry> _entries = [];
  bool _isLoaded = false;

  List<TimeEntry> get entries => _entries;
  bool get isLoaded => _isLoaded;

  TimeEntryProvider() {
    _loadFromStorage();
  }

  Future<void> addTimeEntry(TimeEntry entry) async {
    _entries.add(entry);
    await _saveToStorage(); // 🔑 SAVE
    print('✅ Entry added. Stored entries: ${_entries.length}');
    notifyListeners();
  }

  Future<void> deleteTimeEntry(String id) async {
    _entries.removeWhere((entry) => entry.id == id);
    await _saveToStorage(); // 🔑 SAVE
    print('✅ Entry deleted. Remaining entries: ${_entries.length}');
    notifyListeners();
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _entries.map((e) => e.toJson()).toList();
    await prefs.setString('timeEntries', jsonEncode(jsonList));
    print('📦 timeEntries: ${jsonEncode(jsonList)}');
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('timeEntries');

    if (data == null) {
      _entries = [];
      // Initialize with empty array if not exists
      await prefs.setString('timeEntries', jsonEncode([]));
      print('📦 timeEntries: []');
    } else {
      final decoded = jsonDecode(data) as List;
      _entries = decoded.map((e) => TimeEntry.fromJson(e)).toList();
      print('📦 timeEntries: $data');
    }
    _isLoaded = true;
    notifyListeners();
  }
}
