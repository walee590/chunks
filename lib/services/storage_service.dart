import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

class StorageService {
  static const String _storageKey = 'chunks_notes_data';

  static Future<Map<String, dynamic>> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      try {
        final parsed = jsonDecode(raw) as Map<String, dynamic>;
        final notesMap = <String, Note>{};
        final notesJson = parsed['notes'] as Map<String, dynamic>? ?? {};
        for (final entry in notesJson.entries) {
          notesMap[entry.key] =
              Note.fromJson(entry.value as Map<String, dynamic>);
        }
        return {
          'notes': notesMap, 
          'rootIds': rootIds,
          'fontSize': (parsed['fontSize'] as num?)?.toDouble() ?? 14.0,
          'isBionicEnabled': parsed['isBionicEnabled'] as bool? ?? false,
        };
      } catch (_) {
        // Corrupt data, return empty
      }
    }
    return {'notes': <String, Note>{}, 'rootIds': <String>[]};
  }

  static Future<void> saveData(
      Map<String, Note> notes, List<String> rootIds, {double? fontSize, bool? isBionicEnabled}) async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = <String, dynamic>{};
    for (final entry in notes.entries) {
      notesJson[entry.key] = entry.value.toJson();
    }
    final data = jsonEncode({
      'notes': notesJson, 
      'rootIds': rootIds,
      'fontSize': fontSize ?? 14.0,
      'isBionicEnabled': isBionicEnabled ?? false,
    });
    await prefs.setString(_storageKey, data);
  }
}
