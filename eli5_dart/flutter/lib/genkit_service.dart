import 'package:genkit/client.dart';
import 'package:schemantic/schemantic.dart';

part 'genkit_service.g.dart';

@Schema()
abstract class $Page {
  @Field(description: "1-2 paragraphs of text explaining a key concept")
  String get text;

  @Field(description: "a detailed description of the image")
  String get illustration;
}

@Schema()
abstract class $Storybook {
  @Field(defaultValue: "")
  String get status;

  @Field(defaultValue: "")
  String get bookTitle;

  @Field(defaultValue: [])
  List<$Page> get pages;
}

final storifyFlow = defineRemoteAction(
  url: 'http://localhost:3400/storify',
  outputSchema: Storybook.$schema,
);

final illustrateFlow = defineRemoteAction(
  url: 'http://localhost:3400/illustrate',
  outputSchema: SchemanticType.string(),
);

final cartoonifyFlow = defineRemoteAction(
  url: 'http://localhost:3400/cartoonify',
  outputSchema: SchemanticType.string(),
);

class GenkitService {
  Future<Storybook> storify(String question) async {
    final response = await storifyFlow(input: {'question': question});
    return response;
  }

  Future<String> illustrate(
      String userImage, String illustration, String question) async {
    final response = await illustrateFlow(input: {
      'userImage': 'data:image/jpeg;base64,$userImage',
      'illustration': illustration,
      'question': question,
    });
    return response;
  }

  Future<String> cartoonify(String image) async {
    final response = await cartoonifyFlow(input: {
      'image': 'data:image/jpeg;base64,$image',
    });
    return response;
  }
}
