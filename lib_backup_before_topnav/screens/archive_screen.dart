import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../widgets/note_card.dart';
import 'note_editor_screen.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  void _openNote(BuildContext context, Note note) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, secondaryAnimation) => NoteEditorScreen(noteId: note.id),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _showNoteOptions(BuildContext context, Note note) {
    final provider = Provider.of<NotesProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(context);
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.only(top: 12, bottom: 24, left: 16, right: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.unarchive, color: Colors.blue),
                title: const Text('Unarchive'),
                onTap: () {
                  provider.toggleArchive(note.id);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Note unarchived'), duration: Duration(seconds: 1)),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                title: const Text('Delete note'),
                onTap: () {
                  provider.deleteNote(note.id);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Note deleted'), duration: Duration(seconds: 1)),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Archive'),
      ),
      body: Consumer<NotesProvider>(
        builder: (context, provider, _) {
          final archivedNotes = provider.archivedNotes;

          if (archivedNotes.isEmpty) {
             return Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Icon(Icons.archive_outlined, size: 64, color: Colors.grey.withValues(alpha: 0.3)),
                   const SizedBox(height: 16),
                   Text(
                     'Your archived notes appear here',
                     style: TextStyle(fontSize: 16, color: Colors.grey.withValues(alpha: 0.5)),
                   )
                 ],
               ),
             );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: MasonryGridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: archivedNotes.length,
              itemBuilder: (context, index) {
                final note = archivedNotes[index];
                final childCount = note.childIds.length;
                final children = provider.getNoteChildren(note.id);
                
                return NoteCard(
                  note: note,
                  childCount: childCount,
                  subNotes: children,
                  onTap: () => _openNote(context, note),
                  onLongPress: () => _showNoteOptions(context, note),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
