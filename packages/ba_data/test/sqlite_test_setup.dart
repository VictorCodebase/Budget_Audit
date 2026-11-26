import 'dart:ffi';
import 'dart:io';

import 'package:sqlite3/open.dart';

void configureSqliteTestLibrary() {
  open.overrideForAll(() {
    if (Platform.isLinux) {
      for (final path in const [
        'libsqlite3.so',
        'libsqlite3.so.0',
        '/lib64/libsqlite3.so.0',
        '/lib/x86_64-linux-gnu/libsqlite3.so.0',
        '/usr/lib64/libsqlite3.so.0',
        '/usr/lib/x86_64-linux-gnu/libsqlite3.so.0',
      ]) {
        try {
          return DynamicLibrary.open(path);
        } on ArgumentError {
          // Try the next system location.
        }
      }
    } else if (Platform.isWindows) {
      for (final path in const ['sqlite3.dll', 'winsqlite3.dll']) {
        try {
          return DynamicLibrary.open(path);
        } on ArgumentError {
          // Try the Windows SQLite fallback.
        }
      }
    } else if (Platform.isMacOS) {
      for (final path in const [
        'libsqlite3.dylib',
        '/usr/lib/libsqlite3.dylib',
      ]) {
        try {
          return DynamicLibrary.open(path);
        } on ArgumentError {
          // Try the next macOS location.
        }
      }
    }
    throw ArgumentError('Unable to locate a system SQLite library');
  });
}
