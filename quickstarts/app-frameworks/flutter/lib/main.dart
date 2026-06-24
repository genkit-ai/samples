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
        colorSchemeSeed: const Color(0xFF1A1A1A),
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
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
        setState(() => _recipe = partial);
      }
      await stream.onResult;
    } on GenkitException catch (err) {
      _showError('Failed to generate recipe: ${err.message}');
    } catch (err) {
      _showError('Failed to generate recipe: $err');
    } finally {
      if (mounted) setState(() => _isStreaming = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final recipe = _recipe;
    final textTheme = Theme.of(context).textTheme;
    final sectionStyle =
        textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold);

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Bargain Chef',
                style: textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  text: 'Backend: ',
                  children: [
                    TextSpan(
                      text: backendUrl,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ],
                ),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Tell me what you feel like eating and I'll suggest a recipe "
                'built around today\'s grocery deals.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _cravingController,
                      enabled: !_isStreaming,
                      onSubmitted: (_) => _generateRecipe(),
                      decoration: const InputDecoration(
                        hintText: 'What are you in the mood for?',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _isStreaming ? null : _generateRecipe,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A1A),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(_isStreaming ? 'Cooking...' : 'Suggest a recipe'),
                  ),
                ],
              ),
              if (recipe != null) ...[
                const SizedBox(height: 24),
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Color(0xFFE5E5E5)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (recipe.title?.isNotEmpty ?? false)
                          Text(
                            recipe.title!,
                            style: textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        if (recipe.description?.isNotEmpty ?? false) ...[
                          const SizedBox(height: 8),
                          Text(recipe.description!),
                        ],
                        if (recipe.ingredients.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Text('Ingredients', style: sectionStyle),
                          const SizedBox(height: 8),
                          for (final ingredient in recipe.ingredients)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Wrap(
                                spacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    '•  ${[ingredient.quantity, ingredient.name].whereType<String>().join(' ')}',
                                  ),
                                  if (ingredient.onSale == true)
                                    Chip(
                                      label: const Text('on sale'),
                                      labelStyle:
                                          TextStyle(color: Colors.green.shade800),
                                      backgroundColor: Colors.green.shade50,
                                      side: BorderSide.none,
                                      visualDensity: VisualDensity.compact,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                ],
                              ),
                            ),
                        ],
                        if (recipe.steps.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Text('Steps', style: sectionStyle),
                          const SizedBox(height: 8),
                          for (final (index, step) in recipe.steps.indexed)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text('${index + 1}.  $step'),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
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
      steps:
          (map['steps'] as List<dynamic>? ?? []).whereType<String>().toList(),
    );
  }
}

class RecipeIngredient {
  const RecipeIngredient({this.name, this.quantity, this.onSale});

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
