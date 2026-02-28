import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/notes_provider.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ChunksApp());
}

class ChunksApp extends StatelessWidget {
  const ChunksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotesProvider()..loadNotes(),
      child: Consumer<NotesProvider>(
        builder: (context, provider, _) {
          return MaterialApp(
            title: 'Chunks',
            debugShowCheckedModeBanner: false,
            themeMode: provider.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const _LoadingWrapper(),
          );
        },
      ),
    );
  }
}

class _LoadingWrapper extends StatefulWidget {
  const _LoadingWrapper();

  @override
  State<_LoadingWrapper> createState() => _LoadingWrapperState();
}

class _LoadingWrapperState extends State<_LoadingWrapper> {
  bool? _seenOnboarding;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesProvider>(
      builder: (context, provider, _) {
        if (!provider.isLoaded || _seenOnboarding == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        if (_seenOnboarding == false) {
          return const OnboardingScreen();
        }

        return const HomeScreen();
      },
    );
  }
}
