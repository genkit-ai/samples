import 'package:genkit/genkit.dart';
import 'package:genkit_google_genai/genkit_google_genai.dart';
import 'package:schemantic/schemantic.dart';

part 'storify.g.dart';

@Schema()
abstract class $Page {
  @Field(
      description:
          '1-2 paragraphs of text explaining a key concept or idea about the subject')
  String get text;

  @Field(
      description:
          'a detailed description of the image that should accompany the text for this page of the lesson')
  String get illustration;
}

@Schema()
abstract class $Storybook {
  @Field(description: 'do not fill this in', defaultValue: '')
  String get status;

  @Field(description: 'a fun title for the lesson', defaultValue: '')
  String get bookTitle;

  @Field(defaultValue: [])
  List<$Page> get pages;
}

@Schema()
abstract class $StorifyRequest {
  String get question;
}

Flow<StorifyRequest, Storybook, Storybook, void> defineStorifyFlow(Genkit ai) =>
    ai.defineFlow(
      name: 'storify',
      inputSchema: StorifyRequest.$schema,
      outputSchema: Storybook.$schema,
      streamSchema: Storybook.$schema,
      fn: (StorifyRequest input, ctx) async {
        // Generate the baseline lesson plan using gemini-2.5-pro
        final lessonResponse = await ai.generate(
          model: googleAI.gemini('gemini-2.5-pro'),
          prompt:
              '''You are an app that helps people understand complex concepts in a simple and fun way. The user has a question that they want explained in an engaging way. Your task is:

1. Search Google to get an accurate and grounded picture of the topic at hand.
2. Generate a "lesson plan" that accurately and approachably explains the core concepts of the lesson.
3. Break the lesson down into no more than 10 key ideas. Make sure to include details that could be turned into nice illustrations.

User question: ${input.question}''',
          config: GeminiOptions(
            googleSearch: GoogleSearch(),
          ),
        );

        final lessonText = lessonResponse.text;

        // Generate the storybook structure
        final storybookResponse = await ai.generate(
          model: googleAI.gemini('gemini-2.5-flash'),
          outputSchema: Storybook.$schema,
          config: {
            'temperature': 2,
          },
          prompt:
              '''You are an app that helps people understand complex concepts in a simple and fun way. The user has a question that they want explained in an engaging way. A lesson plan has already been generated and included below. Your task is to generate up to 10 pages of a simple "storybook lesson" that explains the subject. Each page should include 1-2 paragraphs and a detailed description of an illustration to accompany it.

Illustration descriptions will be generated using an image model starring the user as a cartoon character. Use `USER` in the image description to incorporate them in. For example: "USER is riding a jeep through the African Serengeti, pointing at a galloping herd of wildebeests." ONLY use `USER` in image descriptions, not in titles or page text. ONLY include the user when the image might need a stand-in for a person, many pages will not require it. Try to include USER in the first page's illustration.

Your explanations should be approachable, fun, and easy to understand. Write in a simple and clear manner an adult would like to read using concepts that are simple and universal. You should cover all of the most important parts of the topic but you need to keep it short - no more than 10 pages.

=== LESSON ===

$lessonText''',
          onChunk: (chunk) {
            if (chunk.output != null) {
              ctx.sendChunk(chunk.output!);
            }
          },
        );

        final storybook = storybookResponse.output;
        if (storybook == null) {
          throw Exception('Failed to generate storybook output schema');
        }

        // Since storybookResponse.output might be a dynamic map depending on schemantic,
        // Genkit handles casting via the outputSchema mapping (if applicable),
        // or we might need to cast it manually. Schemantic returns the mapped Record type for Schemantic classes.
        return storybook;
      },
    );
