import 'package:flutter/material.dart';
import 'package:genkit/client.dart';

const backendUrl = String.fromEnvironment(
  'BARGAIN_CHEF_URL',
  defaultValue: 'http://localhost:8080/bargainChefFlow',
);

void main() {
  runApp(const BargainChefApp());
}

class BargainChefApp extends StatelessWidget {
  const BargainChefApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bargain Chef',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff1a1a1a),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xfffafafa),
        useMaterial3: true,
      ),
      home: const BargainChefPage(),
    );
  }
}

class BargainChefPage extends StatefulWidget {
  const BargainChefPage({super.key});

  @override
  State<BargainChefPage> createState() => _BargainChefPageState();
}

class _BargainChefPageState extends State<BargainChefPage> {
  final _cravingController = TextEditingController(
    text: 'something warm with chicken',
  );
  final RemoteAction<Map<String, dynamic>, Recipe, Recipe, void>
      _bargainChefFlow = defineRemoteAction(
    url: backendUrl,
    fromResponse: Recipe.fromJson,
    fromStreamChunk: Recipe.fromJson,
  );

  Recipe? _recipe;
  bool _isStreaming = false;

  @override
  void dispose() {
    _cravingController.dispose();
    _bargainChefFlow.dispose();
    super.dispose();
  }

  Future<void> _generateRecipe() async {
    final craving = _cravingController.text.trim();
    if (craving.isEmpty || _isStreaming) return;

    setState(() {
      _recipe = null;
      _isStreaming = true;
    });

    try {
      final stream = _bargainChefFlow.stream(input: {'craving': craving});
      await for (final partial in stream) {
        if (!mounted) return;
        setState(() {
          _recipe = partial;
        });
      }
      await stream.onResult;
    } on GenkitException catch (err) {
      _showError('Failed to generate recipe: ${err.message}');
    } catch (err) {
      _showError('Failed to generate recipe: $err');
    } finally {
      if (mounted) {
        setState(() {
          _isStreaming = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bargain Chef',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: const Color(0xff1a1a1a),
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text.rich(
                    TextSpan(
                      text: 'Backend: ',
                      children: [
                        TextSpan(
                          text: backendUrl,
                          style: const TextStyle(
                            color: Color(0xff1a1a1a),
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    style: const TextStyle(
                      color: Color(0xff555555),
                      fontSize: 13.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _PromptForm(
                    controller: _cravingController,
                    isStreaming: _isStreaming,
                    onSubmit: _generateRecipe,
                  ),
                  const SizedBox(height: 40),
                  if (_recipe != null) RecipeCard(recipe: _recipe!),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PromptForm extends StatelessWidget {
  const _PromptForm({
    required this.controller,
    required this.isStreaming,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool isStreaming;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;
        final input = TextField(
          controller: controller,
          enabled: !isStreaming,
          onSubmitted: (_) => onSubmit(),
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            enabledBorder: _inputBorder(const Color(0xffd0d0d0)),
            focusedBorder: _inputBorder(const Color(0xff1a1a1a)),
            disabledBorder: _inputBorder(const Color(0xffd0d0d0)),
          ),
        );
        final button = SizedBox(
          width: compact ? double.infinity : null,
          child: FilledButton(
            onPressed: isStreaming ? null : onSubmit,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xff1a1a1a),
              disabledBackgroundColor: const Color(0xff999999),
              disabledForegroundColor: Colors.white,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 19),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            child: Text(isStreaming ? 'Cooking...' : 'Suggest a recipe'),
          ),
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              input,
              const SizedBox(height: 8),
              button,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: input),
            const SizedBox(width: 8),
            button,
          ],
        );
      },
    );
  }

  OutlineInputBorder _inputBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color),
    );
  }
}

class RecipeCard extends StatelessWidget {
  const RecipeCard({super.key, required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffe5e5e5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (recipe.title != null && recipe.title!.isNotEmpty)
            Text(
              recipe.title!,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xff1a1a1a),
                    fontWeight: FontWeight.w700,
                  ),
            ),
          if (recipe.description != null && recipe.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              recipe.description!,
              style: const TextStyle(
                color: Color(0xff1a1a1a),
                fontSize: 16,
                height: 1.45,
              ),
            ),
          ],
          if (recipe.ingredients.isNotEmpty) ...[
            const SizedBox(height: 24),
            const _SectionTitle('Ingredients'),
            const SizedBox(height: 8),
            _IngredientList(ingredients: recipe.ingredients),
          ],
          if (recipe.steps.isNotEmpty) ...[
            const SizedBox(height: 24),
            const _SectionTitle('Steps'),
            const SizedBox(height: 8),
            _StepList(steps: recipe.steps),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: const Color(0xff1a1a1a),
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _IngredientList extends StatelessWidget {
  const _IngredientList({required this.ingredients});

  final List<RecipeIngredient> ingredients;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final ingredient in ingredients)
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(height: 1.6)),
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Text(
                        [
                          ingredient.quantity,
                          ingredient.name,
                        ].whereType<String>().join(' '),
                        style: const TextStyle(fontSize: 16, height: 1.6),
                      ),
                      if (ingredient.onSale == true) const SaleBadge(),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _StepList extends StatelessWidget {
  const _StepList({required this.steps});

  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (index, step) in steps.indexed)
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${index + 1}. ', style: const TextStyle(height: 1.6)),
                Expanded(
                  child: Text(
                    step,
                    style: const TextStyle(fontSize: 16, height: 1.6),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class SaleBadge extends StatelessWidget {
  const SaleBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xffe8f5e9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        'on sale',
        style: TextStyle(
          color: Color(0xff2e7d32),
          fontSize: 12,
          height: 1.2,
        ),
      ),
    );
  }
}

class Recipe {
  const Recipe({
    this.title,
    this.description,
    this.servings,
    this.ingredients = const [],
    this.steps = const [],
  });

  final String? title;
  final String? description;
  final num? servings;
  final List<RecipeIngredient> ingredients;
  final List<String> steps;

  factory Recipe.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>;
    return Recipe(
      title: map['title'] as String?,
      description: map['description'] as String?,
      servings: map['servings'] as num?,
      ingredients: (map['ingredients'] as List<dynamic>? ?? [])
          .map(RecipeIngredient.fromJson)
          .toList(),
      steps: (map['steps'] as List<dynamic>? ?? []).whereType<String>().toList(),
    );
  }
}

class RecipeIngredient {
  const RecipeIngredient({
    this.name,
    this.quantity,
    this.onSale,
  });

  final String? name;
  final String? quantity;
  final bool? onSale;

  factory RecipeIngredient.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>;
    return RecipeIngredient(
      name: map['name'] as String?,
      quantity: map['quantity'] as String?,
      onSale: map['onSale'] as bool?,
    );
  }
}
