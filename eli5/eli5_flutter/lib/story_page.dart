import 'dart:convert';

import 'package:eli5_flutter/genkit_service.dart';
import 'package:flutter/material.dart';

class StoryPage extends StatefulWidget {
  final String question;
  final String userImage;
  final String cartoonUserImage;

  const StoryPage(
      {super.key,
      required this.question,
      required this.userImage,
      required this.cartoonUserImage});

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  late final Future<Storybook> _storybookFuture;
  final GenkitService _genkitService = GenkitService();
  final Map<int, Future<String>> _illustrationFutures = {};

  @override
  void initState() {
    super.initState();
    _storybookFuture = _genkitService.storify(widget.question);
  }

  Future<String> _getIllustration(String illustration, int index) {
    if (_illustrationFutures.containsKey(index)) {
      return _illustrationFutures[index]!;
    }
    final future = _genkitService.illustrate(
        widget.userImage, illustration, widget.question);
    _illustrationFutures[index] = future;
    return future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Story'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(widget.cartoonUserImage),
            ),
          ),
        ],
      ),
      body: FutureBuilder<Storybook>(
        future: _storybookFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final storybook = snapshot.data!;
            return ListView(
              children: [
                if (storybook.bookTitle != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      storybook.bookTitle!,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                if (storybook.pages != null)
                  ...storybook.pages!.asMap().entries.map(
                        (entry) => Column(
                          children: [
                            FutureBuilder<String>(
                              future: _getIllustration(
                                  entry.value.illustration, entry.key),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return const Icon(Icons.error);
                                } else if (snapshot.hasData) {
                                  return Image.network(snapshot.data!);
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(entry.value.text),
                            ),
                          ],
                        ),
                      ),
              ],
            );
          } else {
            return const Center(child: Text('No story generated.'));
          }
        },
      ),
    );
  }
}
