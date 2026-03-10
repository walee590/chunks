import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../widgets/note_card.dart';
import 'note_editor_screen.dart';
import 'drawing_screen.dart';
import 'bin_screen.dart';
import 'archive_screen.dart';
import '../theme/app_theme.dart';
import 'dart:ui';

export '../models/note.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  bool _isSearchExpanded = false;
  final _searchController = TextEditingController();
  final Set<String> _selectedNoteIds = {};

  bool get _isSelectionMode => _selectedNoteIds.isNotEmpty;

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedNoteIds.contains(id)) {
        _selectedNoteIds.remove(id);
      } else {
        _selectedNoteIds.add(id);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedNoteIds.clear();
    });
  }

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
              leading: const Icon(Icons.archive_outlined),
              title: const Text('Archive note'),
              onTap: () {
                Navigator.pop(ctx);
                provider.toggleArchive(note.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Note archived'),
                    duration: Duration(seconds: 1),
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

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesProvider>(
      builder: (context, provider, _) {
        final pinnedNotes = provider.getPinnedNotes();
        final unpinnedNotes = provider.getUnpinnedNotes();
        final hasNotes = pinnedNotes.isNotEmpty || unpinnedNotes.isNotEmpty;
        final isDark = provider.themeMode == ThemeMode.dark;

        return Scaffold(
          key: _scaffoldKey,
          extendBody: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Chunks',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                  title: Text(isDark ? 'Light Theme' : 'Dark Theme'),
                  onTap: () {
                    provider.toggleTheme();
                    // Navigator.pop(context); // Optional: close drawer after toggle
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                     Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Bin'),
                  onTap: () {
                     Navigator.pop(context); // close drawer
                     Navigator.push(
                       context,
                       MaterialPageRoute(builder: (_) => const BinScreen()),
                     );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.archive_outlined),
                  title: const Text('Archive'),
                  onTap: () {
                     Navigator.pop(context); // close drawer
                     Navigator.push(
                       context,
                       MaterialPageRoute(builder: (_) => const ArchiveScreen()),
                     );
                  },
                ),
              ],
            ),
          ),
          body: Stack(
            children: [
              SafeArea(
                bottom: false,
                child: !hasNotes
                    ? _buildEmptyState()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.only(left: 12, right: 12, top: 80, bottom: 160),
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
                          ],
                        ),
                      ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: _isSelectionMode
                      ? _buildSelectionAppBar(provider)
                      : _buildSearchBar(provider),
                ),
              ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLiquidFAB(isDark),
                  const SizedBox(height: 16),
                  _buildLiquidTray(isDark),
                ],
              ),
            ),
          ),
        ],
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
        // Fetch children for markers
        final children = provider.getNoteChildren(note.id);
        
        return NoteCard(
          note: note,
          childCount: childCount,
          subNotes: children,
          isSelected: _selectedNoteIds.contains(note.id),
          onTap: () {
            if (_isSelectionMode) {
              _toggleSelection(note.id);
            } else {
              _openNote(note);
            }
          },
          onLongPress: () {
            if (!_isSelectionMode) {
              _toggleSelection(note.id);
            }
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Text(
            'Tap + to create your first note',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(NotesProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!_isSearchExpanded)
            _buildLiquidCircleButton(Icons.person, isDark, () {
              _scaffoldKey.currentState?.openDrawer();
            }),
          if (!_isSearchExpanded) const Spacer(),
          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.fastOutSlowIn,
            height: 56,
            width: _isSearchExpanded ? MediaQuery.of(context).size.width - 32 : 56,
            child: _isSearchExpanded
                ? _buildLiquidSearchPill(provider, isDark)
                : _buildLiquidCircleButton(Icons.search, isDark, () {
                    setState(() {
                      _isSearchExpanded = true;
                    });
                  }),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassContainer({
    required Widget child,
    required double borderRadius,
    required bool isDark,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              // Apple's signature rim light
              color: isDark ? Colors.white.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.6),
              width: 0.5,
            ),
            // The magic gradient fill that creates the volume
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withValues(alpha: 0.2),
                      Colors.white.withValues(alpha: 0.02), // Fades to almost pure glass
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.6),
                      Colors.white.withValues(alpha: 0.1),
                    ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildLiquidCircleButton(IconData icon, bool isDark, VoidCallback onTap) {
    return _buildGlassContainer(
      borderRadius: 28,
      isDark: isDark,
      child: SizedBox(
        height: 56,
        width: 56,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(28),
            child: Center(
              child: Icon(icon, color: isDark ? Colors.white : Colors.black, size: 26),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiquidSearchPill(NotesProvider provider, bool isDark) {
    return _buildGlassContainer(
      borderRadius: 28,
      isDark: isDark,
      child: Material(
        color: Colors.transparent,
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(Icons.search, color: isDark ? Colors.white70 : Colors.black54),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Search your notes...',
                      hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black38),
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
                    icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
                    onPressed: () {
                      setState(() {
                        _isSearching = false;
                        _searchController.clear();
                        provider.setSearchQuery('');
                      });
                    },
                  ),
                IconButton(
                  icon: Icon(Icons.cancel, color: isDark ? Colors.white70 : Colors.black54),
                  onPressed: () {
                    setState(() {
                      _isSearchExpanded = false;
                      _isSearching = false;
                      _searchController.clear();
                      provider.setSearchQuery('');
                    });
                  },
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
    );
  }

  Widget _buildSelectionAppBar(NotesProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: 56, // Fixed height similar to search bar
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
            icon: const Icon(Icons.close),
            onPressed: _clearSelection,
          ),
          Text(
            '${_selectedNoteIds.length}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.push_pin_outlined),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              for (final id in _selectedNoteIds) {
                provider.togglePin(id);
              }
              _clearSelection();
            },
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _showColorPickerDialog(provider),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              for (final id in _selectedNoteIds) {
                 provider.toggleArchive(id);
              }
              _clearSelection();
            },
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
               for (final id in _selectedNoteIds) {
                  provider.deleteNote(id);
               }
               _clearSelection();
            },
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.copy_outlined),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
               for (final id in _selectedNoteIds) {
                  provider.duplicateNote(id);
               }
               _clearSelection();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  void _showColorPickerDialog(NotesProvider provider) {
    // Safe copy of ids in case selection changes
    final idsToColor = Set<String>.from(_selectedNoteIds); 
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Change Color'),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Material(
            color: Colors.transparent,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: List.generate(7, (index) {
                return GestureDetector(
                  onTap: () {
                    for (final id in idsToColor) {
                      provider.updateNote(id, colorIndex: index);
                    }
                    Navigator.pop(ctx);
                    _clearSelection();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.getCardColor(index),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark && index == 0
                             ? Colors.white24 
                             : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  Widget _buildLiquidFAB(bool isDark) {
    return _buildGlassContainer(
      borderRadius: 20,
      isDark: isDark,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _createNote,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              Icons.add,
              size: 28,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiquidTray(bool isDark) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: _buildGlassContainer(
            borderRadius: 30,
            isDark: isDark,
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                _buildTrayIcon(Icons.check_box, isDark, () {
                  final provider = Provider.of<NotesProvider>(context, listen: false);
                  final id = provider.addNote(isList: true);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => NoteEditorScreen(noteId: id)));
                }),
                _buildTrayIcon(Icons.brush, isDark, () async {
                  final imagePath = await Navigator.push(context, MaterialPageRoute(builder: (_) => const DrawingScreen()));
                  if (imagePath != null && context.mounted) {
                    final provider = Provider.of<NotesProvider>(context, listen: false);
                    final id = provider.addNote();
                    provider.updateNote(id, images: [imagePath]);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => NoteEditorScreen(noteId: id)));
                  }
                }),
                _buildTrayIcon(Icons.image, isDark, () async {
                  final picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                  if (image != null && context.mounted) {
                    final provider = Provider.of<NotesProvider>(context, listen: false);
                    final id = provider.addNote();
                    provider.updateNote(id, images: [image.path]);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => NoteEditorScreen(noteId: id)));
                  }
                }),
                _buildTrayIcon(Icons.mic, isDark, () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Voice Notes coming soon! 🎙️'), duration: Duration(seconds: 1), behavior: SnackBarBehavior.floating));
                }),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildTrayIcon(IconData icon, bool isDark, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: isDark ? Colors.white : Colors.black, size: 24),
      onPressed: onTap,
    );
  }
}


