import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/note.dart';
import '../theme/app_theme.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final int childCount;
  final List<Note> subNotes;
  final bool isNeutral; // Use neutral background if true
  final bool isSelected; // Indicates if the card is selected

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onLongPress,
    this.childCount = 0,
    this.subNotes = const [],
    this.isNeutral = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Logic: If isNeutral, use specific neutral color. Else use Vibrant/AppTheme color.
    final cardColor = isNeutral
        ? (isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F5F5)) // Neutral Grey
        : (isDark 
            ? AppTheme.getCardColor(note.colorIndex) 
            : AppTheme.getLightCardColor(note.colorIndex));
        
    final accentColor = AppTheme.getAccentColor(note.colorIndex);
    
    // If card has color (index > 0), it's now Vibrant/Pastel even in Dark Mode.
    // So we need BLACK text for contrast, unless it's the Default Grey (index 0).
    final bool isColorful = note.colorIndex > 0;
    
    // Text colors tailored for the background
    final titleColor = (isDark && !isColorful) ? Colors.white : Colors.black;
    // Make content fully opaque for maximum richness
    final contentColor = (isDark && !isColorful) ? Colors.white : Colors.black.withValues(alpha: 0.85);
    final borderColor = (isDark && !isColorful) ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.1);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : borderColor,
            width: isSelected ? 3.0 : (isNeutral ? 1.0 : (note.pinned ? 1.0 : 0.5)), // Thinner border
          ),
          boxShadow: [
            // Bubbly Drop Shadow
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2), // Slightly darker for pop
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
             // Subtle top highlight (Mimics light source)
            BoxShadow(
              color: Colors.white.withValues(alpha: isDark ? 0.05 : 0.4),
              blurRadius: 2,
              offset: const Offset(0, -1),
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
                          fontWeight: FontWeight.w500, // Reduced from w600 for cleaner look
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
                if (note.isList)
                  // Render Checklist as Colorful Pills
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: note.content.split('\n').take(4).map((line) {
                      // Strip [ ] or [x]
                      final regex = RegExp(r'^\[([ xX])?\]\s*');
                      final match = regex.firstMatch(line.trim());
                      var text = line.trim();
                      bool isChecked = false;
                      if (match != null) {
                        isChecked = match.group(0)!.contains('x') || match.group(0)!.contains('X');
                        text = line.trim().substring(match.end);
                      }
                      if (text.isEmpty) return const SizedBox.shrink();

                      // Cycle colors based on line hash or index
                      // We don't have index easily in map, so use hashcode
                      int colorIndex = (text.hashCode % 6) + 1; // 1-6 are vibrant
                      final color = AppTheme.getAccentColor(colorIndex);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 2),
                        constraints: const BoxConstraints(maxWidth: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08), // Reduced from 0.15 to 0.08 (~50%)
                            blurRadius: 2, // Reduced from 3 to 2
                            offset: const Offset(0, 1), // Reduced from 2 to 1
                          ),
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.1), // Reduced from 0.2 to 0.1
                            blurRadius: 1,
                            offset: const Offset(0, -0.5),
                          ),
                        ],
                      ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6.5,
                              height: 6.5,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7), // Slightly darker for pop
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                text,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                   fontSize: 11,
                                   color: Colors.black.withValues(alpha: 0.8),
                                   fontWeight: FontWeight.w600,
                                   height: 1.2,
                                   decoration: isChecked ? TextDecoration.lineThrough : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  )
                else
                  Text(
                    note.content,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: contentColor,
                      height: 1.5,
                      fontSize: 18, 
                    ),
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                  ),
              
              // Drawing Preview
              if (note.images.isNotEmpty) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(note.images.first),
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        width: double.infinity,
                        color: Colors.black12,
                        child: const Center(child: Icon(Icons.broken_image, color: Colors.white24)),
                      );
                    },
                  ),
                ),
              ],

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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.1), 
                            blurRadius: 1,
                            offset: const Offset(0, -0.5),
                          ),
                        ],
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
