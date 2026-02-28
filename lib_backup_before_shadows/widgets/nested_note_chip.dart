import 'package:flutter/material.dart';
import '../models/note.dart';
import '../theme/app_theme.dart';

class NestedNoteChip extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onUnpack;

  const NestedNoteChip({
    super.key,
    required this.note,
    required this.onTap,
    required this.onUnpack,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = AppTheme.getAccentColor(note.colorIndex);

    return GestureDetector(
      onTap: onTap,
      onLongPress: () {
        _showContextMenu(context);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sticky_note_2_outlined,
              size: 16,
              color: accentColor,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                note.title.isNotEmpty ? note.title : 'Untitled',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              size: 16,
              color: accentColor.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
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
              leading: const Icon(Icons.open_in_new, color: Colors.white70),
              title: const Text('Open nested note'),
              onTap: () {
                Navigator.pop(ctx);
                onTap();
              },
            ),
            ListTile(
              leading: const Icon(Icons.unarchive_outlined, color: Colors.orange),
              title: const Text('Unpack to parent'),
              subtitle: const Text(
                'Restore text back into the parent note',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              onTap: () {
                Navigator.pop(ctx);
                onUnpack();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
