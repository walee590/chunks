import 'package:flutter/material.dart';
import 'dart:math';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import '../services/storage_service.dart';

class NotesProvider extends ChangeNotifier {
  Map<String, Note> _notes = {};
  List<String> _rootIds = [];
  bool _isLoaded = false;
  String _searchQuery = '';

  final _uuid = const Uuid();

  // Getters
  Map<String, Note> get notes => _notes;
  List<String> get rootIds => _rootIds;
  bool get isLoaded => _isLoaded;
  String get searchQuery => _searchQuery;

  // Initialize — load from storage
  Future<void> loadNotes() async {
    if (_isLoaded) return;
    final data = await StorageService.loadData();
    _notes = data['notes'] as Map<String, Note>;
    _rootIds = data['rootIds'] as List<String>;
    _isLoaded = true;
    notifyListeners();
  }

  // Persist to storage
  Future<void> _save() async {
    await StorageService.saveData(_notes, _rootIds);
  }

  // Get root-level notes (filtered by search)
  List<Note> getRootNotes() {
    var roots = _rootIds.map((id) => _notes[id]).whereType<Note>().toList();
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      roots = roots.where((n) {
        return n.title.toLowerCase().contains(q) ||
            n.content.toLowerCase().contains(q);
      }).toList();
    }
    // Pinned first, then by updatedAt descending
    roots.sort((a, b) {
      if (a.pinned && !b.pinned) return -1;
      if (!a.pinned && b.pinned) return 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return roots;
  }

  // Get pinned root notes
  List<Note> getPinnedNotes() {
    return getRootNotes().where((n) => n.pinned).toList();
  }

  // Get unpinned root notes
  List<Note> getUnpinnedNotes() {
    return getRootNotes().where((n) => !n.pinned).toList();
  }

  // Get children of a note
  List<Note> getNoteChildren(String noteId) {
    final note = _notes[noteId];
    if (note == null) return [];
    return note.childIds.map((cid) => _notes[cid]).whereType<Note>().toList();
  }

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Add a new note
  String addNote({String? parentId, String title = '', String content = '', int? colorIndex}) {
    final id = _uuid.v4();
    // Random color (1-6) for nested notes, default (0) for root notes
    final int effectiveColorIndex = colorIndex ?? (parentId != null ? (Random().nextInt(6) + 1) : 0);

    final note = Note(
      id: id,
      parentId: parentId,
      title: title,
      content: content,
      colorIndex: effectiveColorIndex,
    );

    _notes[id] = note;

    if (parentId != null && _notes.containsKey(parentId)) {
      final parent = _notes[parentId]!;
      _notes[parentId] = parent.copyWith(
        childIds: [...parent.childIds, id],
        updatedAt: DateTime.now(),
      );
    } else {
      _rootIds.insert(0, id);
    }

    _save();
    notifyListeners();
    return id;
  }

  // Update a note
  void updateNote(String id, {String? title, String? content, int? colorIndex, bool? pinned}) {
    final note = _notes[id];
    if (note == null) return;

    _notes[id] = note.copyWith(
      title: title,
      content: content,
      colorIndex: colorIndex,
      pinned: pinned,
      updatedAt: DateTime.now(),
    );

    _save();
    notifyListeners();
  }

  // Delete a note (recursive)
  void deleteNote(String id) {
    final note = _notes[id];
    if (note == null) return;

    // Collect all descendants
    final toDelete = <String>{};
    final queue = [id];
    while (queue.isNotEmpty) {
      final cur = queue.removeLast();
      toDelete.add(cur);
      final n = _notes[cur];
      if (n != null) queue.addAll(n.childIds);
    }

    // Remove from parent's children
    if (note.parentId != null && _notes.containsKey(note.parentId)) {
      final parent = _notes[note.parentId]!;
      final newChildIds = parent.childIds.where((c) => c != id).toList();
      final newPreviews = Map<String, String>.from(parent.childPreviews);
      newPreviews.remove(id);
      _notes[note.parentId!] = parent.copyWith(
        childIds: newChildIds,
        childPreviews: newPreviews,
        updatedAt: DateTime.now(),
      );
    }

    // Remove all descendants from map
    for (final did in toDelete) {
      _notes.remove(did);
    }

    // Remove from root IDs
    _rootIds.removeWhere((rid) => toDelete.contains(rid));

    _save();
    notifyListeners();
  }

  // Toggle pin
  void togglePin(String id) {
    final note = _notes[id];
    if (note == null) return;
    _notes[id] = note.copyWith(pinned: !note.pinned, updatedAt: DateTime.now());
    _save();
    notifyListeners();
  }

  // CORE FEATURE: Convert a text line into a nested note
  void convertTextToNote(String parentId, String text) {
    final parent = _notes[parentId];
    if (parent == null) return;

    final childId = _uuid.v4();
    final childNote = Note(
      id: childId,
      parentId: parentId,
      title: text.length > 60 ? '${text.substring(0, 60)}...' : text,
      content: text,
      colorIndex: parent.colorIndex,
    );

    // Remove the line from parent content
    final contentLines = parent.content.split('\n');
    final lineIdx = contentLines.indexWhere((l) => l.trim() == text.trim());
    if (lineIdx != -1) {
      contentLines.removeAt(lineIdx);
    }

    final newChildIds = [...parent.childIds, childId];
    final newPreviews = Map<String, String>.from(parent.childPreviews);
    newPreviews[childId] = text;

    _notes[parentId] = parent.copyWith(
      content: contentLines.join('\n'),
      childIds: newChildIds,
      childPreviews: newPreviews,
      updatedAt: DateTime.now(),
    );
    _notes[childId] = childNote;

    _save();
    notifyListeners();
  }

  // CORE FEATURE: Unpack — restore nested note text back to parent
  void unpackNestedNote(String childId) {
    final child = _notes[childId];
    if (child == null || child.parentId == null) return;

    final parent = _notes[child.parentId];
    if (parent == null) return;

    // Restore original text
    final originalText = parent.childPreviews[childId] ??
        (child.content.isNotEmpty ? child.content : child.title);

    final newContent = parent.content.isNotEmpty
        ? '${parent.content}\n$originalText'
        : originalText;

    // Remove child from parent
    final newChildIds = parent.childIds.where((c) => c != childId).toList();
    final newPreviews = Map<String, String>.from(parent.childPreviews);
    newPreviews.remove(childId);

    _notes[child.parentId!] = parent.copyWith(
      content: newContent,
      childIds: newChildIds,
      childPreviews: newPreviews,
      updatedAt: DateTime.now(),
    );

    // Recursively delete child and its descendants
    final toDelete = <String>{};
    final queue = [childId];
    while (queue.isNotEmpty) {
      final cur = queue.removeLast();
      toDelete.add(cur);
      final n = _notes[cur];
      if (n != null) queue.addAll(n.childIds);
    }
    for (final did in toDelete) {
      _notes.remove(did);
    }

    _save();
    notifyListeners();
  }

  // Get a single note by ID
  Note? getNote(String id) => _notes[id];
}
