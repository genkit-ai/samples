import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eli5_flutter/welcome_page.dart';
import 'package:eli5_flutter/selfie_page.dart';
import 'package:eli5_flutter/history_page.dart';
import 'package:eli5_flutter/history_service.dart';
import 'package:eli5_flutter/story_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String? _cartoonSelfie;
  String? _selfie;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadSelfie();
  }

  Future<void> _loadSelfie() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _cartoonSelfie = prefs.getString('cartoon-selfie');
        _selfie = prefs.getString('selfie');
        _loaded = true;
      });
    }
  }

  void _navigateToStory(String question) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryPage(
          question: question,
          userImage: _selfie,
          cartoonUserImage: _cartoonSelfie,
        ),
      ),
    );
  }

  void _openSavedStory(StorySummary summary) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryPage(
          question: summary.question,
          userImage: _selfie,
          cartoonUserImage: _cartoonSelfie,
          savedStorybook: summary.storybook,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          WelcomePage(
            cartoonUserImage: _cartoonSelfie,
            onQuestion: _navigateToStory,
          ),
          HistoryPage(onStoryTap: _openSavedStory),
          SelfiePage(
            currentCartoonSelfie: _cartoonSelfie,
            onSelfieTaken: () => _loadSelfie(),
            onSelfieCleared: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('selfie');
              await prefs.remove('cartoon-selfie');
              setState(() {
                _cartoonSelfie = null;
                _selfie = null;
              });
            },
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          HapticFeedback.selectionClick();
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
