import 'package:genkit/genkit.dart';
import 'package:genkit_google_genai/genkit_google_genai.dart';
import 'package:schemantic/schemantic.dart';

part 'illustrate.g.dart';

@Schema()
abstract class $IllustrationSchema {
  @Field(description: "the user's image as a data URI")
  String get userImage;

  @Field(description: "a description of the illustration to generate")
  String get illustration;

  @Field(description: "the question the story is about")
  String get question;
}

Flow<IllustrationSchema, String, void, void> defineIllustrateFlow(Genkit ai) =>
    ai.defineFlow(
      name: 'illustrate',
      inputSchema: IllustrationSchema.$schema,
      outputSchema: SchemanticType.string(),
      fn: (IllustrationSchema input, _) async {
        final response = await ai.generate(
          model: googleAI.gemini('gemini-2.5-flash-image'),
          messages: [
            Message(
              role: Role.user,
              content: [
                TextPart(text: '[USER]:\n'),
                MediaPart(media: Media(url: input.userImage)),
                TextPart(
                    text:
                        'You are illustrating a page in an educational storybook for a child. The story is about the question "${input.question}". Generate the illustration described below in a friendly cartoon style. ONLY illustrate exactly what is described below. The illustration should be colorful with full-image backgrounds.\n\n${input.illustration}'),
              ],
            ),
          ],
        );

        final mediaUrl = response.media?.url;
        if (mediaUrl == null) {
          throw Exception('Image generation failed.');
        }
        return mediaUrl;
      },
    );
