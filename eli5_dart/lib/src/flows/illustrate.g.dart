// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'illustrate.dart';

// **************************************************************************
// SchemaGenerator
// **************************************************************************

base class IllustrationSchema {
  factory IllustrationSchema.fromJson(Map<String, dynamic> json) =>
      $schema.parse(json);

  IllustrationSchema._(this._json);

  IllustrationSchema({
    required String userImage,
    required String illustration,
    required String question,
  }) {
    _json = {
      'userImage': userImage,
      'illustration': illustration,
      'question': question,
    };
  }

  late final Map<String, dynamic> _json;

  static const SchemanticType<IllustrationSchema> $schema =
      _IllustrationSchemaTypeFactory();

  String get userImage {
    return _json['userImage'] as String;
  }

  set userImage(String value) {
    _json['userImage'] = value;
  }

  String get illustration {
    return _json['illustration'] as String;
  }

  set illustration(String value) {
    _json['illustration'] = value;
  }

  String get question {
    return _json['question'] as String;
  }

  set question(String value) {
    _json['question'] = value;
  }

  @override
  String toString() {
    return _json.toString();
  }

  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _IllustrationSchemaTypeFactory
    extends SchemanticType<IllustrationSchema> {
  const _IllustrationSchemaTypeFactory();

  @override
  IllustrationSchema parse(Object? json) {
    return IllustrationSchema._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
        name: 'IllustrationSchema',
        definition: $Schema.object(
          properties: {
            'userImage': $Schema.string(
              description: 'the user\'s image as a data URI',
            ),
            'illustration': $Schema.string(
              description: 'a description of the illustration to generate',
            ),
            'question': $Schema.string(
              description: 'the question the story is about',
            ),
          },
          required: ['userImage', 'illustration', 'question'],
        ).value,
        dependencies: [],
      );
}
