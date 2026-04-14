import 'package:genkit/client.dart';
import 'package:json_annotation/json_annotation.dart';

part 'genkit_service.g.dart';

/// A single page in a generated storybook.
///
/// Named [BookPage] to avoid collision with Flutter's [Page] widget class.
@JsonSerializable()
class BookPage {
  final String text;
  final String illustration;

  BookPage({required this.text, required this.illustration});

  factory BookPage.fromJson(Map<String, dynamic> json) => _$BookPageFromJson(json);
  Map<String, dynamic> toJson() => _$BookPageToJson(this);
}

/// The complete storybook response from the `storify` Genkit flow.
@JsonSerializable()
class Storybook {
  final String? status;
  final String? bookTitle;
  final List<BookPage>? pages;

  Storybook({this.status, this.bookTitle, this.pages});

  factory Storybook.fromJson(Map<String, dynamic> json) =>
      _$StorybookFromJson(json);
  Map<String, dynamic> toJson() => _$StorybookToJson(this);
}

// ---------------------------------------------------------------------------
// Genkit remote action definitions.
//
// Each [defineRemoteAction] creates a callable reference to a Genkit flow
// hosted on the backend server at localhost:8080. The [fromResponse] callback
// deserializes the JSON response into the appropriate Dart type.
// ---------------------------------------------------------------------------

/// Calls the `storify` flow — generates a full storybook from a question.
final storifyFlow = defineRemoteAction(
  url: 'http://localhost:8080/api/storify',
  fromResponse: (data) => Storybook.fromJson(data),
);

/// Calls the `illustrate` flow — generates a single storybook illustration.
final illustrateFlow = defineRemoteAction(
  url: 'http://localhost:8080/api/illustrate',
  fromResponse: (data) => data as String,
);

/// Calls the `cartoonify` flow — converts a user photo into a cartoon avatar.
final cartoonifyFlow = defineRemoteAction(
  url: 'http://localhost:8080/api/cartoonify',
  fromResponse: (data) => data as String,
);

/// Service layer that wraps Genkit remote flow calls with convenience methods.
///
/// Handles encoding images as base64 data URIs before sending them to the
/// backend, and exposes a clean API for the UI layer to consume.
class GenkitService {
  /// Generates a storybook explaining [question] in simple terms.
  Future<Storybook> storify(String question) async {
    final response = await storifyFlow(input: {'question': question});
    return response;
  }

  /// Generates an illustration for a storybook page.
  ///
  /// [userImage] is an optional base64-encoded selfie. When provided, the
  /// backend includes it so the AI model can draw the user as a character.
  /// [illustration] is the text description of what to draw.
  Future<String> illustrate(
      String? userImage, String illustration, String question) async {
    final input = <String, dynamic>{
      'illustration': illustration,
      'question': question,
    };
    if (userImage != null && userImage.isNotEmpty) {
      input['userImage'] = 'data:image/jpeg;base64,$userImage';
    }
    final response = await illustrateFlow(input: input);
    return response;
  }

  /// Converts a user's photo into a cartoon avatar.
  ///
  /// [image] is the base64-encoded photo. Returns a data URI of the cartoon.
  Future<String> cartoonify(String image) async {
    final response = await cartoonifyFlow(input: {
      'image': 'data:image/jpeg;base64,$image',
    });
    return response;
  }
}
