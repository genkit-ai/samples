import 'package:genkit/genkit.dart';
import 'package:genkit_google_genai/genkit_google_genai.dart';
import 'package:schemantic/schemantic.dart';
import 'schemas.dart';

Flow getGenerateLessonFlow(Genkit ai) {
  return ai.defineFlow(
    name: 'generateLesson',
    inputSchema: GenerateLessonRequest.$schema,
    outputSchema: stringSchema(),
    fn: (input, _) async {
      final req = input as GenerateLessonRequest;
      final response = await ai.generate(
        model: googleAI.gemini('gemini-2.5-flash'),
        config: GeminiOptions(
          googleSearch: GoogleSearch(),
        ),
        messages: [
          Message(
            role: Role.system,
            content: [
              TextPart(text: '''
You are an app that helps people understand complex concepts in a simple and fun way. The user has a question that they want explained in an engaging way. Your task is:

1. Search Google to get an accurate and grounded picture of the topic at hand.
2. Generate a "lesson plan" that accurately and approachably explains the core concepts of the lesson.
3. Break the lesson down into no more than 10 key ideas. Make sure to include details that could be turned into nice illustrations.
''')
            ],
          ),
          Message(
            role: Role.user,
            content: [TextPart(text: 'User question: ${req.question}')],
          ),
        ],
      );
      return response.text;
    },
  );
}

Flow getCartoonifyFlow(Genkit ai) {
  return ai.defineFlow(
    name: 'cartoonify',
    inputSchema: CartoonifyRequest.$schema,
    outputSchema: stringSchema(),
    fn: (input, _) async {
      final req = input as CartoonifyRequest;
      final response = await ai.generate(
        model: googleAI.gemini('gemini-2.5-flash-image'),
        messages: [
          Message(
            role: Role.user,
            content: [
              TextPart(
                  text:
                      'Transform the person in the following image into a full-body cartoon character in a neutral pose. The background should be white.'),
              MediaPart(media: Media(url: req.image, contentType: 'image/jpeg')),
            ],
          )
        ],
      );
      if (response.media == null) {
        throw Exception("Image generation failed.");
      }
      return response.media!.url;
    },
  );
}

Flow getIllustrateFlow(Genkit ai) {
  return ai.defineFlow(
    name: 'illustrate',
    inputSchema: IllustrationRequest.$schema,
    outputSchema: stringSchema(),
    fn: (input, _) async {
      final req = input as IllustrationRequest;
      final response = await ai.generate(
        model: googleAI.gemini('gemini-2.5-flash-image'),
        messages: [
          Message(
            role: Role.user,
            content: [
              TextPart(text: '[USER]:\n'),
              MediaPart(media: Media(url: req.userImage, contentType: 'image/jpeg')),
              TextPart(text: '''
You are illustrating a page in an educational storybook for a child. The story is about the question "${req.question}". Generate the illustration described below in a friendly cartoon style. ONLY illustrate exactly what is described below. The illustration should be colorful with full-image backgrounds.

${req.illustration}
'''),
            ],
          )
        ],
      );
      if (response.media == null) {
        throw Exception("Image generation failed.");
      }
      return response.media!.url;
    },
  );
}

Flow getStorifyFlow(Genkit ai) {
  final generateLessonFlow = getGenerateLessonFlow(ai);
  return ai.defineFlow(
    name: 'storify',
    inputSchema: StorifyRequest.$schema,
    outputSchema: Storybook.$schema,
    streamSchema: Storybook.$schema,
    fn: (input, context) async {
      final req = input as StorifyRequest;

      context.sendChunk(Storybook(status: "Studying to prepare lesson..."));
      final lesson = await generateLessonFlow(
          GenerateLessonRequest(question: req.question));

      context.sendChunk(Storybook(status: "Generating lesson storybook..."));
      final response = await ai.generate(
        model: googleAI.gemini('gemini-2.5-flash'),
        messages: [
          Message(
            role: Role.system,
            content: [
              TextPart(text: '''
You are an app that helps people understand complex concepts in a simple and fun way. The user has a question that they want explained in an engaging way. A lesson plan has already been generated and included below. Your task is to generate up to 10 pages of a simple "storybook lesson" that explains the subject. Each page should include 1-2 paragraphs and a detailed description of an illustration to accompany it.

Illustration descriptions will be generated using an image model starring the user as a cartoon character. Use `USER` in the image description to incorporate them in. For example: "USER is riding a jeep through the African Serengeti, pointing at a galloping herd of wildebeests." ONLY use `USER` in image descriptions, not in titles or page text. ONLY include the user when the image might need a stand-in for a person, many pages will not require it. Try to include USER in the first page's illustration.

Your explanations should be approachable, fun, and easy to understand. Write in a simple and clear manner an adult would like to read using concepts that are simple and universal. You should cover all of the most important parts of the topic but you need to keep it short - no more than 10 pages.

=== LESSON ===

$lesson
''')
            ],
          ),
          Message(
            role: Role.user,
            content: [TextPart(text: 'Generate the storybook.')],
          ),
        ],
        outputSchema: Storybook.$schema,
      );

      final book = response.output as Storybook;
      return Storybook(
        status: "Done",
        bookTitle: book.bookTitle,
        pages: book.pages,
      );
    },
  );
}
