import 'package:flutter/material.dart';
import '../models/note.dart';
import '../theme/app_theme.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final int childCount;
  final List<int> childColorIndices;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onLongPress,
    this.childCount = 0,
    this.childColorIndices = const [],
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = AppTheme.getCardColor(note.colorIndex);
    final accentColor = AppTheme.getAccentColor(note.colorIndex);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: note.pinned
                ? accentColor.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.08),
            width: note.pinned ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pin indicator + title
              if (note.title.isNotEmpty) ...[
                Row(
                  children: [
                    if (note.pinned)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Icon(
                          Icons.push_pin,
                          size: 14,
                          color: accentColor.withValues(alpha: 0.7),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        note.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
              ],

              // Content preview
              if (note.content.isNotEmpty)
                Text(
                  note.content,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),

              // Nested notes markers (colored bars)
              if (childColorIndices.isNotEmpty) ...[
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: childColorIndices.take(4).map((index) {
                    final color = AppTheme.getCardColor(index);
                    // If color is same as card (e.g. nested in same color), darken/lighten?
                    // But here child colors are random/vibrant vs root dark.
                    // If root is colored (from old data), we might need contrast.
                    // Assuming random colors differ enough.
                    return Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      height: 8,
                      width: 40 + (index * 5.0) % 40, // Random-ish width variation
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 0.5,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
