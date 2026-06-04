import 'dart:io';

import 'package:genkit/genkit.dart';
import 'package:genkit_google_genai/genkit_google_genai.dart';
import 'package:genkit_shelf/genkit_shelf.dart';
import 'package:schemantic/schemantic.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';

part 'my_genkit_shelf.g.dart';

@Schema()
abstract class $IngredientOnSaleInput {
  @Field(description: 'Whether to fetch weekday or weekend sale prices.')
  @StringField(enumValues: ['weekday', 'weekend'])
  String get dayType;
}

@Schema()
abstract class $SaleIngredient {
  String get name;
  String get price;
}

@Schema()
abstract class $RecipeIngredient {
  String get name;
  String get quantity;
  bool get onSale;
}

@Schema()
abstract class $Recipe {
  String get title;
  String get description;
  int get servings;
  List<$RecipeIngredient> get ingredients;
  List<String> get steps;
}

@Schema()
abstract class $BargainChefInput {
  @Field(description: 'What the user feels like eating right now.')
  String get craving;
}

void main() async {
  final ai = Genkit(plugins: [googleAI()]);

  final getIngredientsOnSale = ai.defineTool(
    name: 'getIngredientsOnSale',
    description:
        'Returns the ingredients on sale at the local grocery store, with prices. '
        'The sale set differs between weekdays and weekends.',
    inputSchema: IngredientOnSaleInput.$schema,
    outputSchema: .list(SaleIngredient.$schema),
    fn: (input, _) async {
      if (input.dayType == 'weekend') {
        return [
          SaleIngredient(name: 'chicken breast', price: r'$2.99/lb'),
          SaleIngredient(name: 'pasta', price: r'$0.79'),
          SaleIngredient(name: 'canned tomatoes', price: r'$0.99'),
          SaleIngredient(name: 'garlic', price: r'$0.50 / head'),
          SaleIngredient(name: 'olive oil', price: r'$6.99'),
        ];
      }
      return [
        SaleIngredient(name: 'eggs', price: r'$3.49 / dozen'),
        SaleIngredient(name: 'spinach', price: r'$1.99'),
        SaleIngredient(name: 'parmesan', price: r'$4.99'),
        SaleIngredient(name: 'lemons', price: r'$0.50 each'),
        SaleIngredient(name: 'rice', price: r'$2.49'),
        SaleIngredient(name: 'butter', price: r'$3.99'),
      ];
    },
  );

  final bargainChefFlow = ai.defineFlow(
    name: 'bargainChefFlow',
    inputSchema: BargainChefInput.$schema,
    outputSchema: Recipe.$schema,
    streamSchema: Recipe.$schema,
    fn: (input, ctx) async {
      final today = _weekdayName(DateTime.now().weekday);

      final stream = ai.generateStream(
        model: googleAI.gemini('gemini-flash-latest'),
        config: GeminiOptions(temperature: 0.7),
        prompt:
            'Today is $today. The user is craving: ${input.craving}.\n\n'
            'Call the getIngredientsOnSale tool with the dayType that matches '
            'today. Saturday and Sunday are weekends; all other days are '
            'weekdays. Then propose ONE recipe that takes advantage of those '
            'deals. For each ingredient, set onSale=true if it appears in the '
            "tool's response, false otherwise.",
        toolNames: [getIngredientsOnSale.name],
        outputSchema: Recipe.$schema,
      );

      await for (final chunk in stream) {
        if (ctx.streamingRequested && chunk.output != null) {
          ctx.sendChunk(chunk.output!);
        }
      }

      final response = await stream.onResult;
      if (response.output == null) {
        throw GenkitException(
          'Failed to generate recipe',
          status: StatusCodes.INTERNAL,
        );
      }
      return response.output!;
    },
  );

  final router = Router();
  router.post('/bargainChefFlow', shelfHandler(bargainChefFlow));

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(router.call);
  final server = await io.serve(handler, InternetAddress.anyIPv4, 8080);
  print('Server running on http://localhost:${server.port}');
}

String _weekdayName(int weekday) => const [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
][weekday - 1];
