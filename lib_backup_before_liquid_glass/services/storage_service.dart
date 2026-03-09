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
        final rootIds = (parsed['rootIds'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [];
        return {'notes': notesMap, 'rootIds': rootIds};
      } catch (_) {
        // Corrupt data, return empty
      }
    }
    return {'notes': <String, Note>{}, 'rootIds': <String>[]};
  }

  static Future<void> saveData(
      Map<String, Note> notes, List<String> rootIds) async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = <String, dynamic>{};
    for (final entry in notes.entries) {
      notesJson[entry.key] = entry.value.toJson();
    }
    final data = jsonEncode({'notes': notesJson, 'rootIds': rootIds});
    await prefs.setString(_storageKey, data);
  }
}
