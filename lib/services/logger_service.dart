import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';

class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  LoggerService._internal();

  final _box = GetStorage();

  void info(String event, [Map<String, dynamic>? context]) {
    final payload = {
      'level': 'info',
      'event': event,
      'context': context ?? {},
      'ts': DateTime.now().toIso8601String(),
    };
    debugPrint('[INFO] ${jsonEncode(payload)}');
    _box.write('last_info', payload);
  }

  void error(String event, Object error, [StackTrace? stack, Map<String, dynamic>? context]) {
    final payload = {
      'level': 'error',
      'event': event,
      'error': error.toString(),
      'stack': stack?.toString(),
      'context': context ?? {},
      'ts': DateTime.now().toIso8601String(),
    };
    debugPrint('[ERROR] ${jsonEncode(payload)}');
    _box.write('last_error', payload);
  }
}