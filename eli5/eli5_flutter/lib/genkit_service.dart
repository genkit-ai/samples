import 'package:genkit/client.dart';
import 'package:json_annotation/json_annotation.dart';

part 'genkit_service.g.dart';

@JsonSerializable()
class Page {
  final String text;
  final String illustration;

  Page({required this.text, required this.illustration});

  factory Page.fromJson(Map<String, dynamic> json) => _$PageFromJson(json);
  Map<String, dynamic> toJson() => _$PageToJson(this);
}

@JsonSerializable()
class Storybook {
  final String? bookTitle;
  final List<Page>? pages;

  Storybook({this.bookTitle, this.pages});

  factory Storybook.fromJson(Map<String, dynamic> json) =>
      _$StorybookFromJson(json);
  Map<String, dynamic> toJson() => _$StorybookToJson(this);
}

final storifyFlow = defineRemoteAction(
  url: 'http://localhost:3000/api/storify',
  fromResponse: (data) => Storybook.fromJson(data),
);

final illustrateFlow = defineRemoteAction(
  url: 'http://localhost:3000/api/illustrate',
  fromResponse: (data) => data as String,
);

final cartoonifyFlow = defineRemoteAction(
  url: 'http://localhost:3000/api/cartoonify',
  fromResponse: (data) => data as String,
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
