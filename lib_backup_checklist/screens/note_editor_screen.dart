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

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<NotesProvider>(context, listen: false);
    final note = provider.getNote(widget.noteId);
    if (note != null) {
      _isRoot = note.parentId == null;
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

    // For Root notes, we don't save the "content" field to the note body
    // because it's used for Quick Add.
    // For Nested notes, we DO save it.
    if (_isRoot) {
      if (newTitle != note.title) {
        provider.updateNote(widget.noteId, title: newTitle);
      }
    } else {
      if (newTitle != note.title || newContent != note.content) {
        provider.updateNote(widget.noteId, title: newTitle, content: newContent);
      }
    }

    // If the note is completely empty and was just created, delete it
    // Logic: If title empty AND content empty (for nested) AND has no children
    final contentToCheck = _isRoot ? note.content : newContent;
    if (newTitle.isEmpty && contentToCheck.isEmpty && note.childIds.isEmpty) {
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

  void _showLineContextMenu(String lineText, int lineIndex) {
    if (lineText.trim().isEmpty) return;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Selected text preview
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.format_quote,
                    size: 16,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      lineText,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.7),
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.sticky_note_2, color: Color(0xFF8AB4F8)),
              title: const Text('Turn into nested note'),
              subtitle: Text(
                'Create a sticky note from this line',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _convertLineToNote(lineText);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: const Text('Delete line'),
              onTap: () {
                Navigator.pop(ctx);
                _deleteLine(lineIndex);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
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

        final cardColor = AppTheme.getCardColor(note.colorIndex);
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
                            TextField(
                              controller: _contentController,
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
                                height: 1.6,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Write here',
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
                            ),
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
          floatingActionButton: (_isRoot && _contentController.text.isNotEmpty)
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
