// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sequential_processing.dart';

// **************************************************************************
// SchemaGenerator
// **************************************************************************

base class StoryInput {
  factory StoryInput.fromJson(Map<String, dynamic> json) => $schema.parse(json);

  StoryInput._(this._json);

  StoryInput({required String topic}) {
    _json = {'topic': topic};
  }

  late final Map<String, dynamic> _json;

  static const SchemanticType<StoryInput> $schema = _StoryInputTypeFactory();

  String get topic {
    return _json['topic'] as String;
  }

  set topic(String value) {
    _json['topic'] = value;
  }

  @override
  String toString() {
    return _json.toString();
  }

  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _StoryInputTypeFactory extends SchemanticType<StoryInput> {
  const _StoryInputTypeFactory();

  @override
  StoryInput parse(Object? json) {
    return StoryInput._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'StoryInput',
    definition: $Schema
        .object(
          properties: {
            'topic': $Schema.fromMap({
              'default': 'dinosaurs',
              'type': 'string',
            }),
          },
          required: ['topic'],
        )
        .value,
    dependencies: [],
  );
}

base class StoryIdea {
  factory StoryIdea.fromJson(Map<String, dynamic> json) => $schema.parse(json);

  StoryIdea._(this._json);

  StoryIdea({required String idea}) {
    _json = {'idea': idea};
  }

  late final Map<String, dynamic> _json;

  static const SchemanticType<StoryIdea> $schema = _StoryIdeaTypeFactory();

  String get idea {
    return _json['idea'] as String;
  }

  set idea(String value) {
    _json['idea'] = value;
  }

  @override
  String toString() {
    return _json.toString();
  }

  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _StoryIdeaTypeFactory extends SchemanticType<StoryIdea> {
  const _StoryIdeaTypeFactory();

  @override
  StoryIdea parse(Object? json) {
    return StoryIdea._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'StoryIdea',
    definition: $Schema
        .object(properties: {'idea': $Schema.string()}, required: ['idea'])
        .value,
    dependencies: [],
  );
}

base class ImageGeneratorInput {
  factory ImageGeneratorInput.fromJson(Map<String, dynamic> json) =>
      $schema.parse(json);

  ImageGeneratorInput._(this._json);

  ImageGeneratorInput({required String concept}) {
    _json = {'concept': concept};
  }

  late final Map<String, dynamic> _json;

  static const SchemanticType<ImageGeneratorInput> $schema =
      _ImageGeneratorInputTypeFactory();

  String get concept {
    return _json['concept'] as String;
  }

  set concept(String value) {
    _json['concept'] = value;
  }

  @override
  String toString() {
    return _json.toString();
  }

  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _ImageGeneratorInputTypeFactory
    extends SchemanticType<ImageGeneratorInput> {
  const _ImageGeneratorInputTypeFactory();

  @override
  ImageGeneratorInput parse(Object? json) {
    return ImageGeneratorInput._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'ImageGeneratorInput',
    definition: $Schema
        .object(
          properties: {
            'concept': $Schema.fromMap({
              'default': 'a futuristic city',
              'type': 'string',
            }),
          },
          required: ['concept'],
        )
        .value,
    dependencies: [],
  );
}
