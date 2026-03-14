import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<NotesProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            children: [
              _buildSectionHeader(context, 'Typography'),
              const SizedBox(height: 16),
              
              // Font Size Slider
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Font Size', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            '${provider.fontSize.toInt()} px',
                            style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: theme.colorScheme.primary,
                          thumbColor: theme.colorScheme.primary,
                          overlayColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                        ),
                        child: Slider(
                          value: provider.fontSize,
                          min: 10,
                          max: 30,
                          divisions: 20,
                          onChanged: (val) => provider.setFontSize(val),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => provider.setFontSize(14.0),
                          child: const Text('Reset to Default'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              _buildSectionHeader(context, 'Advanced Reading'),
              const SizedBox(height: 16),
              
              // Bionic Toggle
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  title: const Text('Bionic Reading', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Highlight fixation points for faster reading focus.'),
                  secondary: Icon(Icons.auto_stories, color: theme.colorScheme.primary),
                  value: provider.isBionicEnabled,
                  onChanged: (val) => provider.toggleBionic(),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
              
              const SizedBox(height: 40),
              const Center(
                child: Text(
                  'Chunks Version 1.0.0',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
