

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
            return Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                child: ListView(
                  children: [
                    if (storybook.bookTitle != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 24.0, horizontal: 16.0),
                        child: Text(
                          storybook.bookTitle!,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    if (storybook.pages != null)
                      ...storybook.pages!.asMap().entries.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 16.0),
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    FutureBuilder<String>(
                                      future: _getIllustration(
                                          entry.value.illustration, entry.key),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const SizedBox(
                                            height: 300,
                                            child: Center(
                                                child:
                                                    CircularProgressIndicator()),
                                          );
                                        } else if (snapshot.hasError) {
                                          return const SizedBox(
                                            height: 300,
                                            child: Center(
                                              child: Icon(Icons.error,
                                                  size: 48, color: Colors.red),
                                            ),
                                          );
                                        } else if (snapshot.hasData) {
                                          return Image.network(
                                            snapshot.data!,
                                            fit: BoxFit.cover,
                                          );
                                        } else {
                                          return const SizedBox.shrink();
                                        }
                                      },
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Text(
                                        entry.value.text,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              fontSize: 18,
                                              height: 1.6,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text('No story generated.'));
          }
        },
      ),
    );
  }
}
