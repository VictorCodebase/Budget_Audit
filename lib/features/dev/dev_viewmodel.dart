import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:budget_audit/core/services/dev_service.dart';

class DevViewModel extends ChangeNotifier {
  final DevService _devService;

  DevViewModel(this._devService);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<String> _allTables = [];
  List<String> get allTables => _allTables;

  String _output = "";
  String get output => _output;

  Future<void> loadTables() async {
    _allTables = _devService.listTables();
    notifyListeners();
  }

  Future<void> resetAllTables() async {
    await _run(() => _devService.resetAllTables(), "All tables reset");
  }

  Future<void> resetSingleTable(String name) async {
    await _run(() => _devService.resetSingleTable(name), "$name reset");
  }

  Future<void> clearTable(String name) async {
    await _run(() => _devService.clearTableRecords(name), "$name cleared");
  }

  Future<void> logTable(String name) async {
    final data = await _devService.getTableDump(name);
    // Use proper JSON encoding with indentation for readability
    const encoder = JsonEncoder.withIndent('  ');
    final logMsg = "TABLE: $name\n${encoder.convert(data)}";
    debugPrint(logMsg);
    _output = "Table $name logged to debug console.";
    notifyListeners();
  }

  Future<void> logContext() async {
    final ctx = _devService.dumpContext();
    const encoder = JsonEncoder.withIndent('  ');
    final logMsg = "APP CONTEXT:\n${encoder.convert(ctx)}";
    debugPrint(logMsg);
    _output = "App Context logged to debug console.";
    notifyListeners();
  }

  Future<void> _run(Future<void> Function() action, String msg) async {
    _isLoading = true;
    notifyListeners();

    try {
      await action();
      _output = msg;
    } catch (e) {
      _output = "ERROR: $e";
    }

    _isLoading = false;
    notifyListeners();
  }
}
