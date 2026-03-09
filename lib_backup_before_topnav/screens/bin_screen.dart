import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../widgets/note_card.dart';

class BinScreen extends StatelessWidget {
  const BinScreen({super.key});

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
                leading: const Icon(Icons.restore, color: Colors.blue),
                title: const Text('Restore Note'),
                onTap: () {
                  provider.restoreNote(note.id);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Note restored'), duration: Duration(seconds: 1)),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
                title: const Text('Delete Permanently', style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  provider.permanentDeleteNote(note.id);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Note deleted permanently'), duration: Duration(seconds: 1)),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmEmptyBin(BuildContext context) {
     final provider = Provider.of<NotesProvider>(context, listen: false);
     showCupertinoDialog(
       context: context,
       builder: (ctx) => CupertinoAlertDialog(
         title: const Text('Empty Bin?'),
         content: const Text('All notes in the bin will be permanently deleted. This action cannot be undone.'),
         actions: [
           CupertinoDialogAction(
             onPressed: () => Navigator.pop(ctx),
             child: const Text('Cancel'),
           ),
           CupertinoDialogAction(
             isDestructiveAction: true,
             onPressed: () {
                provider.emptyBin();
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bin emptied'), duration: Duration(seconds: 1)),
                );
             },
             child: const Text('Empty Bin'),
           ),
         ],
       ),
     );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bin'),
        actions: [
          Consumer<NotesProvider>(
            builder: (context, provider, _) {
              if (provider.deletedNotes.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
                tooltip: 'Empty Bin',
                onPressed: () => _confirmEmptyBin(context),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotesProvider>(
        builder: (context, provider, _) {
          final binNotes = provider.deletedNotes;

          if (binNotes.isEmpty) {
             return Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Icon(Icons.delete_outline, size: 64, color: Colors.grey.withValues(alpha: 0.3)),
                   const SizedBox(height: 16),
                   Text(
                     'Bin is empty',
                     style: TextStyle(fontSize: 18, color: Colors.grey.withValues(alpha: 0.5)),
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
              itemCount: binNotes.length,
              itemBuilder: (context, index) {
                final note = binNotes[index];
                final childCount = note.childIds.length;
                final children = provider.getNoteChildren(note.id, includeDeleted: true);
                
                return NoteCard(
                  note: note,
                  childCount: childCount,
                  subNotes: children,
                  onTap: () => _showNoteOptions(context, note),
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
