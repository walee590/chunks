import 'package:flutter/material.dart';
import '../models/note.dart';
import '../theme/app_theme.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final int childCount;
  final List<Note> subNotes;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onLongPress,
    this.childCount = 0,
    this.subNotes = const [],
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Dynamic card color: Index 0 (Root) is Dark/Light, others (Nested) are Vibrant/Pastel
    final cardColor = isDark 
        ? AppTheme.getCardColor(note.colorIndex) 
        : AppTheme.getLightCardColor(note.colorIndex);
        
    final accentColor = AppTheme.getAccentColor(note.colorIndex);
    
    // Text colors tailored for the background
    final titleColor = isDark ? Colors.white : Colors.black;
    final contentColor = isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7);
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08);

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
                : borderColor,
            width: note.pinned ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1), // Subtler shadow
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
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.w600,
                          color: titleColor,
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
                    fontSize: 15,
                    color: contentColor,
                    height: 1.4,
                  ),
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),

              // Nested notes markers (colored bars with text)
              if (subNotes.isNotEmpty) ...[
                const SizedBox(height: 12), // Keep space
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: subNotes.take(4).where((n) => n != null).map((childNote) {
                    // Use Accent Color for vibrancy
                    final color = AppTheme.getAccentColor(childNote.colorIndex);
                    final text = childNote.title.isNotEmpty 
                        ? childNote.title 
                        : (childNote.content.isNotEmpty ? childNote.content : 'Untitled');
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 2),
                      constraints: const BoxConstraints(maxWidth: 180), 
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(50), 
                      ),
                      child: Text(
                        text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          // Use Black text for better contrast on vibrant/light accent colors
                          color: Colors.black.withValues(alpha: 0.8), 
                          fontWeight: FontWeight.w600, 
                          height: 1.2,
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
