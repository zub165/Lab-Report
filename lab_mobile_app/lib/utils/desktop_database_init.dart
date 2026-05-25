import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'constants.dart';

/// SQLite on Windows, macOS, and Linux via sqflite_common_ffi.
Future<void> initDesktopDatabaseIfNeeded() async {
  if (kIsWeb || !isDesktopPlatform) return;
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}
