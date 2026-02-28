import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../widgets/note_card.dart';
import 'note_editor_screen.dart';

export '../models/note.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openNote(Note note) {
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

  void _createNote() {
    final provider = Provider.of<NotesProvider>(context, listen: false);
    final id = provider.addNote();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteEditorScreen(noteId: id),
      ),
    );
  }

  void _showNoteOptions(Note note) {
    final provider = Provider.of<NotesProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(
                note.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                color: note.pinned ? Colors.amber : Colors.white70,
              ),
              title: Text(note.pinned ? 'Unpin note' : 'Pin note'),
              onTap: () {
                Navigator.pop(ctx);
                provider.togglePin(note.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(note.pinned ? 'Note unpinned' : 'Note pinned'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: const Text('Delete note'),
              onTap: () {
                Navigator.pop(ctx);
                provider.deleteNote(note.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Note deleted'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesProvider>(
      builder: (context, provider, _) {
        final pinnedNotes = provider.getPinnedNotes();
        final unpinnedNotes = provider.getUnpinnedNotes();
        final hasNotes = pinnedNotes.isNotEmpty || unpinnedNotes.isNotEmpty;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                // Custom Search Bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () {}, // TODO: Open drawer
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search your notes',
                            border: InputBorder.none,
                          ),
                          onChanged: (q) {
                            setState(() {
                              _isSearching = q.isNotEmpty;
                            });
                            provider.setSearchQuery(q);
                          },
                        ),
                      ),
                      if (_isSearching)
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _isSearching = false;
                              _searchController.clear();
                              provider.setSearchQuery('');
                            });
                          },
                        )
                      else
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.transparent, // Placeholder for profile
                          child: Icon(Icons.account_circle, color: Colors.grey),
                        ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: !hasNotes
                      ? _buildEmptyState()
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (pinnedNotes.isNotEmpty) ...[
                                Padding(
                                  padding: const EdgeInsets.only(left: 12, top: 12, bottom: 8),
                                  child: Text(
                                    'PINNED',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ),
                                _buildGrid(pinnedNotes, provider),
                                const SizedBox(height: 16),
                              ],
                              if (unpinnedNotes.isNotEmpty) ...[
                                if (pinnedNotes.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12, bottom: 8),
                                    child: Text(
                                      'OTHERS',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ),
                                _buildGrid(unpinnedNotes, provider),
                              ],
                              const SizedBox(height: 80),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _createNote,
            elevation: 0,
            backgroundColor: Colors.transparent, // No background
            child: const Icon(Icons.add, size: 48, color: Colors.white), // Big white plus
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 8.0,
            color: Colors.transparent,
            elevation: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Minimalist: Menu/Settings on left
                IconButton(
                  icon: const Icon(Icons.check_box_outlined),
                  onPressed: () {}, // TODO: Checklist feature
                  tooltip: 'New List',
                ),
                IconButton(
                  icon: const Icon(Icons.brush_outlined),
                  onPressed: () {}, // TODO: Drawing feature
                  tooltip: 'New Drawing',
                ),
                const SizedBox(width: 48), // Space for FAB
                IconButton(
                  icon: const Icon(Icons.image_outlined),
                  onPressed: () {}, // TODO: Image feature
                  tooltip: 'New Image',
                ),
                IconButton(
                  icon: const Icon(Icons.mic_none),
                  onPressed: () {}, // TODO: Recording feature
                  tooltip: 'New Recording',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGrid(List<Note> notes, NotesProvider provider) {
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        final childCount = note.childIds.length;
        // Fetch children to get their colors for the markers
        final children = provider.getNoteChildren(note.id);
        final childColorIndices = children.map((c) => c.colorIndex).toList();

        return NoteCard(
          note: note,
          childCount: childCount,
          childColorIndices: childColorIndices,
          onTap: () => _openNote(note),
          onLongPress: () => _showNoteOptions(note),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 80,
            color: Colors.white.withValues(alpha: 0.15),
          ),
          const SizedBox(height: 16),
          Text(
            'Notes you add appear here',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to create your first note',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.25),
            ),
          ),
        ],
      ),
    );
  }
}


