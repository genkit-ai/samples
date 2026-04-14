import 'package:eli5_flutter/genkit_service.dart';
import 'package:eli5_flutter/generation_progress.dart';
import 'package:eli5_flutter/history_service.dart';
import 'package:eli5_flutter/image_viewer.dart';
import 'package:eli5_flutter/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class StoryPage extends StatefulWidget {
  final String question;
  final String? userImage;
  final String? cartoonUserImage;
  final Storybook? savedStorybook;

  const StoryPage({
    super.key,
    required this.question,
    this.userImage,
    this.cartoonUserImage,
    this.savedStorybook,
  });

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> with TickerProviderStateMixin {
  final GenkitService _genkitService = GenkitService();
  final HistoryService _historyService = HistoryService();
  final Map<int, Future<String>> _illustrationFutures = {};

  Storybook? _storybook;
  bool _isLoading = true;
  String? _error;
  int _generationStep = 0;
  bool _usePageView = true;
  int _currentPage = 0;
  late final PageController _pageController;
  late final AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    if (widget.savedStorybook != null) {
      _storybook = widget.savedStorybook;
      _isLoading = false;
      _fadeController.forward();
    } else {
      _generateStory();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _generateStory() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _generationStep = 0;
    });

    // Simulate progress steps (since the API is a single future)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _isLoading) setState(() => _generationStep = 1);
    });
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _isLoading) setState(() => _generationStep = 2);
    });

    try {
      final storybook = await _genkitService.storify(widget.question);
      if (mounted) {
        setState(() {
          _storybook = storybook;
          _isLoading = false;
        });
        _fadeController.forward();
        HapticFeedback.mediumImpact();
        _historyService.saveStory(widget.question, storybook);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Something went wrong generating your story.';
          _isLoading = false;
        });
      }
    }
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

  void _shareStory() {
    if (_storybook == null) return;
    final buffer = StringBuffer();
    buffer.writeln(_storybook!.bookTitle ?? 'My ELI5 Story');
    buffer.writeln();
    buffer.writeln('Question: ${widget.question}');
    buffer.writeln();
    for (final page in _storybook!.pages ?? []) {
      buffer.writeln(page.text);
      buffer.writeln();
    }
    buffer.writeln('Generated with ELI5');
    Share.share(buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_storybook?.bookTitle ?? 'Your Story'),
        actions: [
          if (_storybook != null) ...[
            Semantics(
              label: 'Toggle between page view and scroll view',
              child: IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() => _usePageView = !_usePageView);
                },
                icon: Icon(
                    _usePageView ? Icons.view_agenda : Icons.auto_stories),
                tooltip: _usePageView ? 'Scroll view' : 'Storybook view',
              ),
            ),
            Semantics(
              label: 'Share this story',
              child: IconButton(
                onPressed: _shareStory,
                icon: const Icon(Icons.share),
                tooltip: 'Share story',
              ),
            ),
          ],
          if (widget.cartoonUserImage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Semantics(
                label: 'Your avatar',
                child: CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(widget.cartoonUserImage!),
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(colorScheme, textTheme),
    );
  }

  Widget _buildBody(ColorScheme colorScheme, TextTheme textTheme) {
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GenerationProgress(currentStep: _generationStep),
              const SizedBox(height: 40),
              const ShimmerCard(),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.sentiment_dissatisfied,
                  size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(_error!, style: textTheme.titleMedium, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                'The storyteller tripped! Tap below to try again.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _generateStory,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_storybook == null || _storybook!.pages == null) {
      return Center(child: Text('No story generated.', style: textTheme.bodyLarge));
    }

    final pages = _storybook!.pages!;

    if (_usePageView) {
      return _buildPageView(pages, colorScheme, textTheme);
    } else {
      return _buildScrollView(pages, colorScheme, textTheme);
    }
  }

  Widget _buildPageView(
      List<BookPage> pages, ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: pages.length,
            onPageChanged: (index) {
              HapticFeedback.selectionClick();
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              return FadeTransition(
                opacity: _fadeController,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: _buildStoryCard(
                          pages[index], index, colorScheme, textTheme),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Page indicator
        Semantics(
          label: 'Page ${_currentPage + 1} of ${pages.length}',
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _currentPage > 0
                      ? () => _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          )
                      : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                ...List.generate(pages.length, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _currentPage ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: i == _currentPage
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                    ),
                  );
                }),
                IconButton(
                  onPressed: _currentPage < pages.length - 1
                      ? () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          )
                      : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScrollView(
      List<BookPage> pages, ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pages.length,
          itemBuilder: (context, index) {
            return FadeTransition(
              opacity: _fadeController,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child:
                    _buildStoryCard(pages[index], index, colorScheme, textTheme),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStoryCard(
      BookPage page, int index, ColorScheme colorScheme, TextTheme textTheme) {
    final heroTag = 'illustration_$index';

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FutureBuilder<String>(
            future: _getIllustration(page.illustration, index),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const ShimmerLoading(
                  height: 300,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16)),
                );
              } else if (snapshot.hasError) {
                return SizedBox(
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.image_not_supported,
                            size: 40, color: colorScheme.error),
                        const SizedBox(height: 8),
                        Text(
                          'Illustration unavailable',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (snapshot.hasData) {
                return Semantics(
                  label: 'Story illustration for page ${index + 1}. '
                      'Tap to view full screen.',
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ImageViewer.show(context, snapshot.data!,
                          heroTag: heroTag);
                    },
                    child: Hero(
                      tag: heroTag,
                      child: Image.network(
                        snapshot.data!,
                        fit: BoxFit.contain,
                        width: double.infinity,
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              page.text,
              style: textTheme.bodyLarge?.copyWith(
                fontSize: 18,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
