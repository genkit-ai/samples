import 'package:eli5_flutter/selfie_page.dart';
import 'package:eli5_flutter/story_page.dart';
import 'package:eli5_flutter/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool? _hasSelfie;

  @override
  void initState() {
    super.initState();
    _checkSelfie();
  }

  Future<void> _checkSelfie() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasSelfie = prefs.containsKey('cartoon-selfie');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ELI5'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_hasSelfie == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_hasSelfie!) {
      return FutureBuilder<String?>(
        future: SharedPreferences.getInstance()
            .then((prefs) => prefs.getString('cartoon-selfie')),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return WelcomePage(
              cartoonUserImage: snapshot.data!,
              onQuestion: (question) async {
                final prefs = await SharedPreferences.getInstance();
                final selfie = prefs.getString('selfie');
                if (selfie != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StoryPage(
                          question: question,
                          userImage: selfie,
                          cartoonUserImage: snapshot.data!),
                    ),
                  );
                }
              },
              onEdit: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('selfie');
                await prefs.remove('cartoon-selfie');
                setState(() {
                  _hasSelfie = false;
                });
              },
            );
          }
          return const Center(child: Text('Error loading avatar.'));
        },
      );
    }
    return SelfiePage(
      onSelfieTaken: () {
        setState(() {
          _hasSelfie = true;
        });
      },
    );
  }
}
