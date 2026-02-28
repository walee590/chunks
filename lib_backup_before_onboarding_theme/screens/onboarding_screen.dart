import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [Color(0xFF0D1B2A), Colors.black],
              ),
            ),
          ),

          PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            children: [
              _buildPage1_Mindfulness(),
              _buildPage2_Comparison(),
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
                        color: _currentPage == index ? Colors.white : Colors.white24,
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
                      color: _currentPage == 0 ? Colors.white.withValues(alpha: 0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: _currentPage == 0 ? Border.all(color: Colors.white24) : null,
                      boxShadow: _currentPage == 1
                          ? [BoxShadow(color: Colors.white.withValues(alpha: 0.2), blurRadius: 20)]
                          : [],
                    ),
                    child: Text(
                      _currentPage == 0 ? "Next" : "Get Started",
                      style: GoogleFonts.outfit(
                        color: _currentPage == 0 ? Colors.white : Colors.black,
                        fontSize: 16,
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

  Widget _buildPage1_Mindfulness() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Meditating Figure (Icon Composition)
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.tealAccent.withValues(alpha: 0.1),
              ),
            ),
            const Icon(Icons.self_improvement, size: 100, color: Colors.tealAccent),
          ],
        ),
        const SizedBox(height: 48),
        Text(
          "Tidy Notes =",
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          "Seamless Navigation",
          style: GoogleFonts.outfit(
            fontSize: 28, // Slightly smaller or same?
            fontWeight: FontWeight.w300,
            color: Colors.tealAccent,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            "Find peace in structure.",
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: Colors.white54,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPage2_Comparison() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Messy Top
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Random scattered words
                  _messyWord("Buy milk", -10, -50),
                  _messyWord("Call mom", 15, -20),
                  _messyWord("Project X", -5, 40),
                  _messyWord("Gym 5pm", 20, 20),
                  _messyWord("Ideas...", -15, 0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text("Without Chunks", style: GoogleFonts.outfit(color: Colors.redAccent)),
                  ),
                ],
              ),
            ),
          ),
          
          // Divider
          const Divider(color: Colors.white24),
          
          // Neat Bottom (Chunks)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text("With Chunks", style: GoogleFonts.outfit(color: Colors.greenAccent)),
                  ),
                  const SizedBox(height: 32),
                  // Grid of pills
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _chunkPill("Groceries", const Color(0xFFF28B82)),
                      _chunkPill("Work", const Color(0xFF80CBC4)),
                      _chunkPill("Health", const Color(0xFFD7AEFB)),
                      _chunkPill("Journal", const Color(0xFFCCFF90)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 100), // Space for button
        ],
      ),
    );
  }

  Widget _messyWord(String text, double angleDeg, double offset) {
    return Transform.rotate(
      angle: angleDeg * math.pi / 180,
      child: Transform.translate(
        offset: Offset(offset, offset),
        child: Text(
          text,
          style: GoogleFonts.outfit(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _chunkPill(String text, Color color) {
    return div(
      // Wait, div? No, Container.
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
             BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
             ),
          ],
        ),
        child: Text(
          text,
          style: GoogleFonts.outfit(
            color: Colors.black.withValues(alpha: 0.8),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  // Correction for _chunkPill helper
  Widget div({required Widget child}) => child; 
}
