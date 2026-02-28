import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/color_picker.dart';
import '../widgets/note_card.dart';

class NoteEditorScreen extends StatefulWidget {
  final String noteId;

  const NoteEditorScreen({super.key, required this.noteId});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _showColorPicker = false;
  bool _isRoot = false;
  bool _isList = false;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<NotesProvider>(context, listen: false);
    final note = provider.getNote(widget.noteId);
    if (note != null) {
      _isRoot = note.parentId == null;
      _isList = note.isList;
      _titleController = TextEditingController(text: note.title);
      // If root, use field for Quick Add (start empty). If nested, edit content.
      _contentController = TextEditingController(text: _isRoot ? '' : note.content);
    } else {
      _titleController = TextEditingController();
      _contentController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _saveNote();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final provider = Provider.of<NotesProvider>(context, listen: false);
    final note = provider.getNote(widget.noteId);
    if (note == null) return;

    final newTitle = _titleController.text;
    final newContent = _contentController.text;

    if (_isRoot) {
      if (newTitle != note.title || _isList != note.isList) {
        provider.updateNote(widget.noteId, title: newTitle, isList: _isList);
      }
    } else {
      if (newTitle != note.title || newContent != note.content || _isList != note.isList) {
        provider.updateNote(widget.noteId, title: newTitle, content: newContent, isList: _isList);
      }
    }
    
    // Deletion logic...
    final contentToCheck = _isRoot ? note.content : newContent;
    if (newTitle.isEmpty && contentToCheck.isEmpty && note.childIds.isEmpty && !_isList) {
       provider.deleteNote(widget.noteId);
    }
  }

  void _submitQuickAdd() {
    final text = _contentController.text.trim();
    if (text.isEmpty) return;

    final provider = Provider.of<NotesProvider>(context, listen: false);
    provider.addNote(parentId: widget.noteId, content: text);

    _contentController.clear();
    setState(() {}); // refresh UI state
    
    // Optional: Scroll to bottom?
  }

  void _convertLineToNote(String text) {
    final provider = Provider.of<NotesProvider>(context, listen: false);
    
    // Save current content first
    provider.updateNote(widget.noteId,
        title: _titleController.text, content: _contentController.text);

    // Convert the line
    provider.convertTextToNote(widget.noteId, text);

    // Update the content controller
    final updatedNote = provider.getNote(widget.noteId);
    if (updatedNote != null) {
      _contentController.text = updatedNote.content;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✨ Line turned into nested note'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _deleteLine(int lineIndex) {
    final lines = _contentController.text.split('\n');
    if (lineIndex >= 0 && lineIndex < lines.length) {
      lines.removeAt(lineIndex);
      _contentController.text = lines.join('\n');
    }
  }

  void _openChildNote(Note childNote) {
    // Save current note first
    _saveNote();

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, secondaryAnimation) => NoteEditorScreen(noteId: childNote.id),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _addChildNote() {
    final provider = Provider.of<NotesProvider>(context, listen: false);

    // Save current note first
    provider.updateNote(widget.noteId,
        title: _titleController.text, content: _contentController.text);

    final childId = provider.addNote(parentId: widget.noteId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteEditorScreen(noteId: childId),
      ),
    );
  }

  // Helper to build Checklist Item
  Widget _buildChecklistItem(String line, int index, StateSetter setState) {
    bool isChecked = line.trim().startsWith('[x] ');
    String text = line.trim().replaceFirst(RegExp(r'^\[[ x]\] '), '');
    final controller = TextEditingController(text: text);
    
    return Row(
      children: [
        Checkbox(
          value: isChecked,
          onChanged: (val) {
             final lines = _contentController.text.split('\n');
             if (index < lines.length) {
               final prefix = val == true ? '[x] ' : '[ ] ';
               lines[index] = prefix + text;
               _contentController.text = lines.join('\n');
               setState(() {});
             }
          },
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
            ),
            style: TextStyle(
              fontSize: 16,
              color: isChecked ? Colors.grey : Theme.of(context).colorScheme.onSurface,
              decoration: isChecked ? TextDecoration.lineThrough : null,
            ),
            onChanged: (val) {
               final lines = _contentController.text.split('\n');
               if (index < lines.length) {
                 final prefix = isChecked ? '[x] ' : '[ ] ';
                 lines[index] = prefix + val;
                 _contentController.text = lines.join('\n');
               }
            },
            onSubmitted: (_) {
               // Add new item below
               final lines = _contentController.text.split('\n');
               lines.insert(index + 1, '[ ] ');
               _contentController.text = lines.join('\n');
               setState(() {});
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, size: 16, color: Colors.grey),
          onPressed: () {
             final lines = _contentController.text.split('\n');
             if (index < lines.length) {
               lines.removeAt(index);
               _contentController.text = lines.join('\n');
               setState(() {});
             }
          },
        ),
      ],
    );
  }

  Widget _buildContentEditor() {
    if (!_isList) {
       // Standard Text Editor
       return TextField(
          controller: _contentController,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
            height: 1.6,
          ),
          decoration: InputDecoration(
            hintText: 'Write here...',
            border: InputBorder.none,
            hintStyle: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
          maxLines: null,
          onChanged: (val) {
            if (_isRoot) setState(() {});
          },
          textInputAction: _isRoot ? TextInputAction.send : null,
          onSubmitted: _isRoot ? (_) => _submitQuickAdd() : null,
        );
    } else {
      // Checklist Editor
      final lines = _contentController.text.split('\n');
      if (_contentController.text.isEmpty) {
         // Start with one empty item if empty
         if (lines.isEmpty || (lines.length == 1 && lines[0].isEmpty)) {
            _contentController.text = '[ ] ';
            // Re-split
            // But we can just handle the UI rendering below
         }
      }
      
      // Ensure at least one line if empty
      final displayLines = _contentController.text.isEmpty ? ['[ ] '] : lines;

      return Column(
        children: [
          ...displayLines.asMap().entries.map((entry) {
             return _buildChecklistItem(entry.value, entry.key, setState);
          }).toList(),
          // Add Item Button
          InkWell(
            onTap: () {
               final current = _contentController.text;
               _contentController.text = current + (current.endsWith('\n') || current.isEmpty ? '' : '\n') + '[ ] ';
               setState(() {});
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.add, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text('Add Item', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesProvider>(
      builder: (context, provider, _) {
        final note = provider.getNote(widget.noteId);
        if (note == null) {
          return const Scaffold(
            body: Center(child: Text('Note not found')),
          );
        }

        final children = provider.getNoteChildren(widget.noteId);

        // Tint the background with the note's vibrant color
        final accentColor = AppTheme.getAccentColor(note.colorIndex);
        final backgroundColor = Color.alphaBlend(
          accentColor.withValues(alpha: 0.08), // Subtle tint (8-10%)
          Theme.of(context).scaffoldBackgroundColor,
        );

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: backgroundColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                _saveNote();
                Navigator.pop(context);
              },
            ),
            actions: [
              IconButton(
                icon: Icon(
                  note.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                  color: note.pinned ? Colors.amber : null,
                ),
                onPressed: () => provider.togglePin(widget.noteId),
              ),
              IconButton(
                icon: const Icon(Icons.palette_outlined),
                onPressed: () {
                  setState(() => _showColorPicker = !_showColorPicker);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  final messenger = ScaffoldMessenger.of(context);
                  provider.deleteNote(widget.noteId);
                  Navigator.pop(context);
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Note deleted'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              if (_showColorPicker)
                ColorPicker(
                  selectedIndex: note.colorIndex,
                  onColorSelected: (index) {
                    provider.updateNote(widget.noteId, colorIndex: index);
                  },
                ),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Title (only for root notes)
                            if (note.parentId == null)
                              TextField(
                                controller: _titleController,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Title',
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                                  ),
                                ),
                                maxLines: null,
                              ),
                            const SizedBox(height: 8),
                            // Content Editor (Text or Checklist)
                            _buildContentEditor(),
                          ],
                        ),
                      ),
                    ),
                    if (children.isNotEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        sliver: SliverMasonryGrid.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childCount: children.length,
                          itemBuilder: (context, index) {
                            final child = children[index];
                            // Fetch grandchildren for markers
                            final grandchildren = provider.getNoteChildren(child.id);

                            return NoteCard(
                              note: child,
                              childCount: child.childIds.length,
                              subNotes: grandchildren,
                              onTap: () => _openChildNote(child),
                              onLongPress: () {
                                // Optional: Context menu for child
                              },
                            );
                          },
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: (_isRoot && _contentController.text.isNotEmpty && !_isList)
              ? FloatingActionButton(
                  onPressed: _submitQuickAdd,
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.arrow_upward, size: 28),
                )
              : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }
}
