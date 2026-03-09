import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'dart:math' as math;

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding_v2', true); // New key to force show

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            children: [
              _buildPage1_Mindfulness(theme, colorScheme, textTheme),
              _buildPage2_Comparison(theme, colorScheme, textTheme),
            ],
          ),

          // Indicators & Controls
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(2, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index ? colorScheme.onSurface : colorScheme.onSurface.withValues(alpha: 0.24),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                
                // Button
                GestureDetector(
                  onTap: () {
                    if (_currentPage == 0) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _completeOnboarding();
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: EdgeInsets.symmetric(
                      horizontal: _currentPage == 0 ? 32 : 48,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: _currentPage == 0 ? colorScheme.onSurface.withValues(alpha: 0.1) : Colors.black, // Changed to black background
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.24)), // Added border so it stands out
                      boxShadow: _currentPage == 1
                          ? [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20)]
                          : [],
                    ),
                    child: Text(
                      _currentPage == 0 ? "Next" : "Get Started",
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface, // White text
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage1_Mindfulness(ThemeData theme, ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Meditating Figure (Icon Composition)
        Icon(Icons.self_improvement, size: 100, color: colorScheme.onSurface),
        const SizedBox(height: 48),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            "Get Relief From Wall of Text Anxiety",
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            "Find peace in structure.",
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.54),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPage2_Comparison(ThemeData theme, ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          const SizedBox(height: 60), // Top padding
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Without Chunks (Left Side)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "THE DAILY DUMP",
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "The secret to the best scrambled eggs is a tablespoon of cold butter and constant stirring Check if the local farmer's market is open on Tuesdays or just weekends Remember to water the spider plant; it's looking a bit dramatic today Buy more light bulbs specifically the warm ones, not the 'hospital' white ones That movie ending made absolutely no sense. Why did the protagonist just walk into the ocean? Started reading that new sci-fi novel. The first chapter is 80 pages long for some reason Note: The red guitar strings look cool, but they sound a bit muddy compared to the nickel ones Try to beat the high score on that retro arcade game before the weekend ends Sync with the team regarding the color palette for the new dashboard The 15-minute standup turned into a 2-hour philosophical debate about buttons. Follow up on the email about the missing invoices from three months ago Update the 'Readme' file because half the instructions are now obsolete The 15-minute standup turned into a 2-hour philosophical debate about buttons.",
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.9),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Divider
                Container(
                  width: 1,
                  color: colorScheme.onSurface.withValues(alpha: 0.24),
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                ),
                
                // With Chunks (Right Side)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "THE DAILY DUMP",
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Write here...",
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.4),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _chunkBubble("The secret to the best scrambled eggs is a tablespoon of cold butter and constant stirring.", const Color(0xFFE57373), textTheme), // Red
                          const SizedBox(height: 8),
                          _chunkBubble("Check if the local farmer's market is open on Tuesdays or just weekends.", const Color(0xFFF48FB1), textTheme), // Pink
                          const SizedBox(height: 8),
                          _chunkBubble("Remember to water the spider plant; it's looking a bit dramatic today", const Color(0xFFCE93D8), textTheme), // Purple-Pink
                          const SizedBox(height: 8),
                          _chunkBubble("Buy more light bulbs specifically the warm ones, not the 'hospital' white ones", const Color(0xFF80CBC4), textTheme), // Teal
                          const SizedBox(height: 8),
                          _chunkBubble("That movie ending made absolutely no sense. Why did the protagonist just walk into the ocean?", const Color(0xFF80CBC4), textTheme), // Teal
                          const SizedBox(height: 8),
                          _chunkBubble("Started reading that new sci-fi novel. The first chapter is 80 pages long for some reason.", const Color(0xFF80CBC4), textTheme), // Teal
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100), // Space for bottom button/indicators
        ],
      ),
    );
  }

  Widget _chunkBubble(String text, Color color, TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: textTheme.bodySmall?.copyWith(
          color: Colors.black.withValues(alpha: 0.8),
          height: 1.3,
        ),
      ),
    );
  }
}

