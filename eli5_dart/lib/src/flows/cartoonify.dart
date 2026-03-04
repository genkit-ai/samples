import 'package:genkit/genkit.dart';
import 'package:genkit_google_genai/genkit_google_genai.dart';
import 'package:schemantic/schemantic.dart';

import '../genkit.dart';

part 'cartoonify.g.dart';

@Schema()
abstract class $CartoonifyRequest {
  String get image;
}

final cartoonifyFlow = ai.defineFlow(
  name: 'cartoonify',
  inputSchema: CartoonifyRequest.$schema,
  outputSchema: SchemanticType.string(),
  fn: (CartoonifyRequest input, _) async {
    final response = await ai.generate(
      model: googleAI.gemini('gemini-2.5-flash-image'),
      messages: [
        Message(
          role: Role.user,
          content: [
            TextPart(text: 'Transform the person in the following image into a full-body cartoon character in a neutral pose. The background should be white.'),
            MediaPart(media: Media(url: input.image)),
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
