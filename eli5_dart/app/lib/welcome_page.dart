import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eli5_flutter/eli5_logo.dart';

class _QuestionCategory {
  final String name;
  final IconData icon;
  final List<String> questions;

  const _QuestionCategory({
    required this.name,
    required this.icon,
    required this.questions,
  });
}

const _categories = [
  _QuestionCategory(
    name: 'Science',
    icon: Icons.science,
    questions: [
      'How can a cold help your body fight COVID-19?',
      'Why does the sky change colors at sunset?',
      'How do plants know which way is up?',
    ],
  ),
  _QuestionCategory(
    name: 'Space',
    icon: Icons.rocket_launch,
    questions: [
      'What did Chang\'e-6 find on the moon\'s far side?',
      'Why can\'t we see stars during the day?',
      'How do astronauts sleep in space?',
    ],
  ),
  _QuestionCategory(
    name: 'Weather',
    icon: Icons.cloud,
    questions: [
      'Why was the 2025 hurricane season quiet, then active?',
      'What makes thunder so loud?',
      'How do snowflakes get their shapes?',
    ],
  ),
];

class WelcomePage extends StatefulWidget {
  final Function(String) onQuestion;
  final String? cartoonUserImage;

  const WelcomePage({
    super.key,
    required this.onQuestion,
    this.cartoonUserImage,
  });

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _questionController = TextEditingController();
  late final AnimationController _staggerController;
  int _selectedCategory = 0;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _questionController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  void _submit(String question) {
    if (question.trim().isEmpty) return;
    HapticFeedback.mediumImpact();
    widget.onQuestion(question.trim());
    _questionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Avatar
                if (widget.cartoonUserImage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Semantics(
                      label: 'Your cartoon avatar',
                      child: CircleAvatar(
                        radius: 28,
                        backgroundImage:
                            NetworkImage(widget.cartoonUserImage!),
                      ),
                    ),
                  ),

                // Logo
                const Eli5Logo(fontSize: 100),
                const SizedBox(height: 8),

                Text(
                  'Submit a question and get a simple explanation.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),

                // Question input
                Semantics(
                  label: 'Enter your question',
                  child: TextField(
                    controller: _questionController,
                    textInputAction: TextInputAction.send,
                    onSubmitted: _submit,
                    decoration: InputDecoration(
                      hintText: 'What do you want explained?',
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Semantics(
                          label: 'Submit question',
                          child: FilledButton(
                            onPressed: () => _submit(_questionController.text),
                            style: FilledButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(12),
                            ),
                            child: const Icon(Icons.arrow_forward, size: 22),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Category tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_categories.length, (i) {
                      final cat = _categories[i];
                      final selected = i == _selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Semantics(
                          label: '${cat.name} category',
                          selected: selected,
                          child: FilterChip(
                            selected: selected,
                            avatar: Icon(cat.icon, size: 18),
                            label: Text(cat.name),
                            onSelected: (_) {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedCategory = i);
                              _staggerController
                                ..reset()
                                ..forward();
                            },
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 16),

                // Animated question chips
                AnimatedBuilder(
                  animation: _staggerController,
                  builder: (context, _) {
                    final questions =
                        _categories[_selectedCategory].questions;
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: List.generate(questions.length, (i) {
                        final delay = i * 0.2;
                        final t = ((_staggerController.value - delay) / 0.6)
                            .clamp(0.0, 1.0);
                        final curve = Curves.easeOutBack.transform(t);

                        return Transform.scale(
                          scale: curve,
                          child: Opacity(
                            opacity: t,
                            child: Semantics(
                              label: 'Ask: ${questions[i]}',
                              child: ActionChip(
                                label: Text(
                                  questions[i],
                                  style: textTheme.bodySmall,
                                ),
                                avatar:
                                    const Icon(Icons.lightbulb_outline, size: 16),
                                onPressed: () => _submit(questions[i]),
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),

                if (widget.cartoonUserImage == null) ...[
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withAlpha(80),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.face_retouching_natural,
                            color: colorScheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Add a selfie in your Profile to personalize story illustrations!',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
