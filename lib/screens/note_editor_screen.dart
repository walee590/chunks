import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/note.dart';
import '../providers/notes_provider.dart';
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
  // Local state removed: bool _isGridMode = true;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<NotesProvider>(context, listen: false);
    final note = provider.getNote(widget.noteId);
    if (note != null) {
      _isRoot = note.parentId == null;
      _isList = note.isList;
      _titleController = TextEditingController(text: note.title);
      // FIX: If root and NOT a list, use empty content (Quick Add). If List or Child, load content.
      _contentController = TextEditingController(text: (_isRoot && !_isList) ? '' : note.content);
    } else {
      _titleController = TextEditingController();
      _contentController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // ... (existing methods _saveNote, _submitQuickAdd, _openChildNote, _buildChecklistItem, _buildContentEditor remain unchanged) ...
  // Note: I will use a separate replace call for _buildContentEditor or assume it is skipped here as I am targeting class start.
  // Wait, I need to be careful not to overwrite the middle of the class. 
  // I will target the variable declaration area and initState.
  
  // Actually, I can just add `bool _isGridMode = true;` near other bools.
  // And update AppBar actions.
  
  // Let's do it in chunks. This replacement is for State variables.


  void _saveNote() {
    if (!mounted) return;
    
    final provider = Provider.of<NotesProvider>(context, listen: false);
    final note = provider.getNote(widget.noteId);
    if (note == null) return;

    final newTitle = _titleController.text;
    final newContent = _contentController.text;
    
    // FIX: Determine if we should save content.
    // Save content if: 
    // 1. It is NOT a root note (nested note) OR
    // 2. It IS a list (root checklists must persist content)
    bool shouldSaveContent = !_isRoot || _isList;

    if (shouldSaveContent) {
       if (newTitle != note.title || newContent != note.content || _isList != note.isList) {
          provider.updateNote(widget.noteId, title: newTitle, content: newContent, isList: _isList);
       }
    } else {
       // Root Text Note: Content is transient (Quick Add), only save title/type
       if (newTitle != note.title || _isList != note.isList) {
          provider.updateNote(widget.noteId, title: newTitle, isList: _isList);
       }
    }
    
    // Deletion logic...
    // If saving content, check against newContent. If transient, check against note.content.
    // Wait, if transient, note.content might be old stuff?
    // Actually, for root text notes, we don't auto-delete based on transient content emptiness usually.
    // But let's keep existing logic safe:
    final contentToCheck = shouldSaveContent ? newContent : note.content;
    
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
    setState(() {}); 
  }

  void _openChildNote(Note childNote) {
    _saveNote();
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => NoteEditorScreen(noteId: childNote.id),
      ),
    );
  }

  void _showReminderPicker(BuildContext context, NotesProvider provider, Note note) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        final theme = Theme.of(context);
        
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            left: 20,
            right: 20,
            top: 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Handle
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
              
              // Header
              Row(
                children: [
                   Container(
                     padding: const EdgeInsets.all(8),
                     decoration: BoxDecoration(
                       color: theme.colorScheme.primary.withValues(alpha: 0.1),
                       borderRadius: BorderRadius.circular(12),
                     ),
                     child: Icon(Icons.notifications_active_outlined, color: theme.colorScheme.primary),
                   ),
                   const SizedBox(width: 16),
                   Text(
                     'Set Reminder',
                     style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                   ),
                ],
              ),
              const SizedBox(height: 24),

              // Active reminder banner
              if (note.reminderDate != null) ...[
                 Container(
                   padding: const EdgeInsets.all(16),
                   decoration: BoxDecoration(
                     color: Colors.redAccent.withValues(alpha: 0.1),
                     borderRadius: BorderRadius.circular(16),
                     border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                   ),
                   child: Row(
                     children: [
                       const Icon(Icons.alarm_on, color: Colors.redAccent, size: 20),
                       const SizedBox(width: 12),
                       Expanded(
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             const Text(
                               'Active Reminder', 
                               style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)
                             ),
                             Builder(
                               builder: (context) {
                                 final d = note.reminderDate!.toLocal();
                                 final min = d.minute.toString().padLeft(2, '0');
                                 final hour = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
                                 final ampm = d.hour >= 12 ? 'PM' : 'AM';
                                 final dateStr = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} at $hour:$min $ampm';
                                 return Text(
                                   dateStr,
                                   style: TextStyle(color: Colors.redAccent.withValues(alpha: 0.8), fontSize: 13),
                                 );
                               }
                             ),
                           ],
                         ),
                       ),
                       TextButton(
                         onPressed: () {
                           provider.updateReminder(note.id, null);
                           Navigator.pop(ctx);
                         },
                         style: TextButton.styleFrom(
                           foregroundColor: Colors.redAccent,
                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                           minimumSize: Size.zero,
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                         ),
                         child: const Text('Clear', style: TextStyle(fontWeight: FontWeight.bold)),
                       ),
                     ],
                   ),
                 ),
                 const SizedBox(height: 24),
              ],
              
              // Preset times
              Text('Quick Suggestions', style: theme.textTheme.titleSmall?.copyWith(color: Colors.grey)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                   _buildReminderChip(
                     context,
                     icon: Icons.hourglass_bottom,
                     label: '+1 Hour',
                     onTap: () {
                        provider.updateReminder(note.id, DateTime.now().add(const Duration(hours: 1)));
                        Navigator.pop(ctx);
                     },
                   ),
                   _buildReminderChip(
                     context,
                     icon: Icons.wb_sunny_outlined,
                     label: 'Tomorrow 9AM',
                     onTap: () {
                        final now = DateTime.now();
                        provider.updateReminder(note.id, DateTime(now.year, now.month, now.day + 1, 9, 0));
                        Navigator.pop(ctx);
                     },
                   ),
                   _buildReminderChip(
                     context,
                     icon: Icons.calendar_month_outlined,
                     label: 'Next Week',
                     onTap: () {
                        provider.updateReminder(note.id, DateTime.now().add(const Duration(days: 7)));
                        Navigator.pop(ctx);
                     },
                   ),
                ],
              ),
              const SizedBox(height: 24),

              // Custom Date Time Button
              ElevatedButton.icon(
                onPressed: () async {
                    Navigator.pop(ctx); // Close sheet before opening dialogs
                    DateTime? selectedDate = DateTime.now();
                    
                    await showCupertinoModalPopup(
                      context: context,
                      builder: (BuildContext pickerCtx) {
                        return Container(
                          height: 300,
                          color: Theme.of(context).scaffoldBackgroundColor,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CupertinoButton(
                                    child: const Text('Cancel'),
                                    onPressed: () {
                                      selectedDate = null;
                                      Navigator.pop(pickerCtx);
                                    },
                                  ),
                                  CupertinoButton(
                                    child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
                                    onPressed: () => Navigator.pop(pickerCtx),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: CupertinoDatePicker(
                                  mode: CupertinoDatePickerMode.dateAndTime,
                                  initialDateTime: DateTime.now(),
                                  minimumDate: DateTime.now(),
                                  onDateTimeChanged: (DateTime newDate) {
                                    selectedDate = newDate;
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    );
                    
                    if (selectedDate != null) {
                       provider.updateReminder(note.id, selectedDate!);
                    }
                },
                icon: const Icon(Icons.more_time),
                label: const Text('Custom Date & Time'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  foregroundColor: theme.colorScheme.onSurface,
                  elevation: 0,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMoreOptionsBottomSheet(BuildContext context, NotesProvider provider, Note note) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        final theme = Theme.of(context);

        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            left: 20,
            right: 20,
            top: 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
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
              const SizedBox(height: 20),

              // Delete
              _buildOptionTile(
                context,
                icon: Icons.delete_outline,
                label: 'Delete',
                color: Colors.redAccent,
                onTap: () {
                  final messenger = ScaffoldMessenger.of(context);
                  provider.deleteNote(widget.noteId);
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Note deleted'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),

              // Archive / Unarchive
              _buildOptionTile(
                context,
                icon: note.isArchived ? Icons.unarchive_outlined : Icons.archive_outlined,
                label: note.isArchived ? 'Unarchive' : 'Archive',
                color: theme.colorScheme.onSurface,
                onTap: () {
                  provider.toggleArchive(widget.noteId);
                  final isNowArchived = !note.isArchived;
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isNowArchived ? 'Note archived' : 'Note unarchived'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                  if (isNowArchived) {
                    _saveNote();
                    Navigator.pop(context);
                  }
                },
              ),
              const SizedBox(height: 8),

              // Send
              _buildOptionTile(
                context,
                icon: Icons.share_outlined,
                label: 'Send',
                color: theme.colorScheme.onSurface,
                onTap: () {
                  Navigator.pop(ctx);
                  _shareNote(note);
                },
              ),
              const SizedBox(height: 16),

              // Cancel
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionTile(BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareNote(Note note) {
    final buffer = StringBuffer();
    if (note.title.isNotEmpty) {
      buffer.writeln(note.title);
      buffer.writeln();
    }
    
    if (note.isList) {
      final text = _contentController.text;
      if (text.isNotEmpty) {
         final lines = text.split('\n');
         for (var line in lines) {
           final trimmed = line.trim();
           if (trimmed.startsWith('[x] ') || trimmed.startsWith('[X] ')) {
             buffer.writeln('☑ ${trimmed.substring(4)}');
           } else if (trimmed.startsWith('[ ] ')) {
             buffer.writeln('☐ ${trimmed.substring(4)}');
           } else {
             buffer.writeln(line);
           }
         }
      }
    } else {
      buffer.write(_contentController.text);
    }
    
    final shareText = buffer.toString().trim();
    if (shareText.isNotEmpty) {
       Share.share(shareText);
    }
  }

  void _showNoteOptions(BuildContext context, NotesProvider provider, Note note) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        final theme = Theme.of(context);

        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            left: 20,
            right: 20,
            top: 12,
          ),
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
              const SizedBox(height: 20),

              // Copy
              _buildOptionTile(
                context,
                icon: Icons.copy_outlined,
                label: 'Copy text',
                color: theme.colorScheme.onSurface,
                onTap: () {
                  final textToCopy = note.title.isNotEmpty 
                      ? '${note.title}\n\n${note.content}'
                      : note.content;
                  Clipboard.setData(ClipboardData(text: textToCopy));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Copied to clipboard'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),

              // Delete
              _buildOptionTile(
                context,
                icon: Icons.delete_outline,
                label: 'Delete note',
                color: Colors.redAccent,
                onTap: () {
                  provider.deleteNote(note.id);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Note deleted'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Cancel
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReminderChip(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
     return ActionChip(
       avatar: Icon(icon, size: 16),
       label: Text(label),
       onPressed: onTap,
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
       side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
       backgroundColor: Theme.of(context).cardColor,
     );
  }

  // Helper to build Checklist Item
  Widget _buildChecklistItem(String line, int originalIndex, Function(String) onUpdate, Function() onDelete) {
    // Robust Regex: Matches [ ], [x], [], [X] with optional spaces inside and after
    final regex = RegExp(r'^\[([ xX])?\]\s*');
    final match = regex.firstMatch(line.trim());
    
    bool isChecked = false;
    String text = line.trim();

    if (match != null) {
      isChecked = match.group(0)!.contains('x') || match.group(0)!.contains('X');
      text = line.trim().substring(match.end);
    } else {
      // No prefix found
    }

    return ChecklistItem(
      key: ValueKey('item_$originalIndex'),
      text: text,
      isChecked: isChecked,
      index: originalIndex,
      onUpdate: (newText) => onUpdate(newText),
      onDelete: onDelete,
    );
  }

  Widget _buildContentEditor() {
    if (!_isList) {
       // Standard Text Editor
       return TextField(
          controller: _contentController,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
            fontSize: 20,
          ),
          decoration: InputDecoration(
            hintText: 'Write here...',
            border: InputBorder.none,
            hintStyle: TextStyle(
              fontSize: 20,
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
      // Split Logic
      final allLines = _contentController.text.split('\n');
      // If empty, init with one text '[ ] '
      if (_contentController.text.isEmpty) {
         if (allLines.isEmpty || (allLines.length == 1 && allLines[0].isEmpty)) {
            // Only force [ ] if user explicitly made it a list and it's empty
            // But doing this in build causes infinite loops sometimes if we setState.
            // Better to just render one item.
         }
      }
      
      // Ensure we have at least one line to render if the text is truly empty
      final linesToRender = (_contentController.text.isEmpty) ? ['[ ] '] : allLines;

      final activeItems = <Map<String, dynamic>>[];
      final checkedItems = <Map<String, dynamic>>[];

      for (int i = 0; i < linesToRender.length; i++) {
        final line = linesToRender[i];
        if (line.trim().startsWith('[x] ')) {
          checkedItems.add({'text': line, 'index': i});
        } else {
          activeItems.add({'text': line, 'index': i});
        }
      }

      // Update helper
      void updateLine(int index, String newText) {
         final lines = _contentController.text.isEmpty ? ['[ ] '] : _contentController.text.split('\n');
         
         // If we are editing the phantom '[ ] ' of an empty note, we are actually setting the text.
         if (_contentController.text.isEmpty && index == 0) {
            _contentController.text = newText;
            setState(() {});
            return;
         }

         if (index < lines.length) {
            lines[index] = newText;
            _contentController.text = lines.join('\n');
            setState(() {});
         }
      }

      void deleteLine(int index) {
         final lines = _contentController.text.split('\n');
         if (index < lines.length) {
            lines.removeAt(index);
            _contentController.text = lines.join('\n');
            setState(() {});
         }
      }

      return Column(
        children: [
          // Active List (Reorderable)
          if (activeItems.isNotEmpty)
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activeItems.length,
              itemBuilder: (ctx, i) {
                final item = activeItems[i];
                final originalIndex = item['index'] as int;
                return Container(
                  key: ValueKey('active_$originalIndex'), // Stable key
                  child: _buildChecklistItem(
                    item['text'] as String,
                    i, 
                    (val) => updateLine(originalIndex, val),
                    () => deleteLine(originalIndex),
                  ),
                );
              },
              onReorder: (oldIndex, newIndex) {
                 if (oldIndex < newIndex) newIndex -= 1;
                 
                 final item = activeItems.removeAt(oldIndex);
                 activeItems.insert(newIndex, item);
                 
                 final newLines = [
                    ...activeItems.map((e) => e['text'] as String),
                    ...checkedItems.map((e) => e['text'] as String),
                 ];
                 
                 _contentController.text = newLines.join('\n');
                 setState(() {});
              },
            ),

          // Add Item Button
          InkWell(
            onTap: () {
               final newText = _contentController.text + (_contentController.text.isEmpty ? '' : '\n') + '[ ] ';
               _contentController.text = newText;
               setState(() {});
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.add, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text('List item', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          ),

          // Checked Items
          if (checkedItems.isNotEmpty) ...[
            const SizedBox(height: 16),
            ExpansionTile(
              title: Text(
                '${checkedItems.length} ticked item${checkedItems.length == 1 ? '' : 's'}',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              initiallyExpanded: false,
              shape: const Border(), // Remove borders
              collapsedShape: const Border(),
              tilePadding: EdgeInsets.zero,
              children: checkedItems.map((item) {
                 final originalIndex = item['index'] as int;
                 return _buildChecklistItem(
                    item['text'] as String,
                    originalIndex,
                    (val) => updateLine(originalIndex, val),
                    () => deleteLine(originalIndex),
                 );
              }).toList(),
            ),
          ],
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
        final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
               _saveNote();
            }
          },
          child: Scaffold(
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
                icon: Icon(_isGridMode ? Icons.grid_view : Icons.view_agenda_outlined),
                tooltip: _isGridMode ? 'Switch to List' : 'Switch to Grid',
                onPressed: () {
                  setState(() => _isGridMode = !_isGridMode);
                },
              ),
              IconButton(
                icon: Icon(
                  note.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                  color: note.pinned ? Colors.amber : null,
                ),
                onPressed: () => provider.togglePin(widget.noteId),
              ),
              IconButton(
                icon: Icon(
                  note.reminderDate != null ? Icons.notifications_active : Icons.notifications_outlined,
                  color: note.reminderDate != null ? Colors.amber : null,
                ),
                onPressed: () => _showReminderPicker(context, provider, note),
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
                            if (note.images.isNotEmpty) ...[
                              SizedBox(
                                height: 200,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: note.images.length,
                                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                                  itemBuilder: (context, index) {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Stack(
                                        children: [
                                          Image.file(
                                            File(note.images[index]),
                                            height: 200,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(
                                              width: 200,
                                              height: 200,
                                              color: Colors.white10,
                                              child: const Icon(Icons.broken_image, color: Colors.white24),
                                            ),
                                          ),
                                          Positioned(
                                            top: 4,
                                            right: 4,
                                            child: GestureDetector(
                                              onTap: () {
                                                // Remove image
                                                final newImages = List<String>.from(note.images)..removeAt(index);
                                                provider.updateNote(widget.noteId, images: newImages);
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: const BoxDecoration(
                                                  color: Colors.black54,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(Icons.close, size: 16, color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            if (note.parentId == null)
                              TextField(
                                controller: _titleController,
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Title',
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                                  ),
                                ),
                                maxLines: null,
                              ),
                            const SizedBox(height: 8),
                            _buildContentEditor(),
                          ],
                        ),
                      ),
                    ),
                    if (children.isNotEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        sliver: SliverMasonryGrid.count(
                          crossAxisCount: _isGridMode ? 2 : 1,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childCount: children.length,
                          itemBuilder: (context, index) {
                            final child = children[index];
                            final grandchildren = provider.getNoteChildren(child.id);
                            return NoteCard(
                              note: child,
                              childCount: child.childIds.length,
                              subNotes: grandchildren,
                              onTap: () => _openChildNote(child),
                              onLongPress: () => _showNoteOptions(context, provider, child),
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
          extendBody: true,
          bottomNavigationBar: BottomAppBar(
            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1C1C1E) : Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
            child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_box_outlined),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Add feature coming soon!'), duration: Duration(seconds: 1)),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.palette_outlined),
                      onPressed: () {
                        setState(() => _showColorPicker = !_showColorPicker);
                      },
                    ),
                  ],
                ),
                Text(
                  'Edited ${timeago.format(note.updatedAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showMoreOptionsBottomSheet(context, provider, note),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
}

class ChecklistItem extends StatefulWidget {
  final String text;
  final bool isChecked;
  final int index;
  final Function(String) onUpdate;
  final VoidCallback onDelete;

  const ChecklistItem({
    super.key,
    required this.text,
    required this.isChecked,
    required this.index,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<ChecklistItem> createState() => _ChecklistItemState();
}

class _ChecklistItemState extends State<ChecklistItem> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
  }

  @override
  void didUpdateWidget(ChecklistItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text && _controller.text != widget.text) {
       final sel = _controller.selection;
       _controller.text = widget.text;
       if (sel.start <= widget.text.length && sel.end <= widget.text.length) {
         _controller.selection = sel;
       }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: const BoxDecoration(
        color: Colors.transparent, 
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        children: [
          if (!widget.isChecked)
             ReorderableDragStartListener(
               index: widget.index,
               child: Padding(
                 padding: const EdgeInsets.only(left: 8.0, right: 4.0),
                 child: Icon(Icons.drag_indicator, size: 20, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
               ),
             ),
          
          Transform.scale(
            scale: 0.9,
            child: Checkbox(
              value: widget.isChecked,
              onChanged: (val) {
                 final prefix = val == true ? '[x] ' : '[ ] ';
                 widget.onUpdate(prefix + widget.text);
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              activeColor: Theme.of(context).colorScheme.primary,
              checkColor: Theme.of(context).colorScheme.onPrimary,
              side: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
          
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              ),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: widget.isChecked 
                    ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5) 
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
                decoration: widget.isChecked ? TextDecoration.lineThrough : null,
              ),
              cursorColor: Theme.of(context).colorScheme.primary,
              onChanged: (val) {
                 final prefix = widget.isChecked ? '[x] ' : '[ ] ';
                 widget.onUpdate(prefix + val);
              },
            ),
          ),
          
          IconButton(
            icon: Icon(Icons.close, size: 18, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
            onPressed: widget.onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            style: IconButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}



