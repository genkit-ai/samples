import 'package:schemantic/schemantic.dart';

part 'schemas.g.dart';

@Schematic()
abstract class $CartoonifyRequest {
  @StringField(description: 'A data URI of an image of a person to cartoonify')
  String get image;
}

@Schematic()
abstract class $IllustrationRequest {
  @StringField(description: "the user's image as a data URI")
  String get userImage;

  @StringField(description: 'a description of the illustration to generate')
  String get illustration;

  @StringField(description: 'the question the story is about')
  String get question;
}

@Schematic()
abstract class $StorifyRequest {
  @StringField(description: 'the question to generate a story for')
  String get question;
}

@Schematic()
abstract class $PageSchema {
  @StringField(
      description:
          '1-2 paragraphs of text explaining a key concept or idea about the subject')
  String get text;

  @StringField(
      description:
          'a detailed description of the image that should accompany the text for this page of the lesson')
  String get illustration;
}

@Schematic()
abstract class $Storybook {
  @StringField(description: 'do not fill this in')
  String? get status;

  @StringField(description: 'a fun title for the lesson')
  String? get bookTitle;

  List<$PageSchema>? get pages;
}
