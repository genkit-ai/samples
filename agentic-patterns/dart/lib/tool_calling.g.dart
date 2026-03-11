// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tool_calling.dart';

// **************************************************************************
// SchemaGenerator
// **************************************************************************

base class ToolCallingInput {
  factory ToolCallingInput.fromJson(Map<String, dynamic> json) =>
      $schema.parse(json);

  ToolCallingInput._(this._json);

  ToolCallingInput({required String prompt}) {
    _json = {'prompt': prompt};
  }

  late final Map<String, dynamic> _json;

  static const SchemanticType<ToolCallingInput> $schema =
      _ToolCallingInputTypeFactory();

  String get prompt {
    return _json['prompt'] as String;
  }

  set prompt(String value) {
    _json['prompt'] = value;
  }

  @override
  String toString() {
    return _json.toString();
  }

  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _ToolCallingInputTypeFactory
    extends SchemanticType<ToolCallingInput> {
  const _ToolCallingInputTypeFactory();

  @override
  ToolCallingInput parse(Object? json) {
    return ToolCallingInput._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'ToolCallingInput',
    definition: $Schema
        .object(
          properties: {
            'prompt': $Schema.fromMap({
              'default': 'What is the weather in New York?',
              'type': 'string',
            }),
          },
          required: ['prompt'],
        )
        .value,
    dependencies: [],
  );
}

base class ToolCallingWeatherInput {
  factory ToolCallingWeatherInput.fromJson(Map<String, dynamic> json) =>
      $schema.parse(json);

  ToolCallingWeatherInput._(this._json);

  ToolCallingWeatherInput({required String location}) {
    _json = {'location': location};
  }

  late final Map<String, dynamic> _json;

  static const SchemanticType<ToolCallingWeatherInput> $schema =
      _ToolCallingWeatherInputTypeFactory();

  String get location {
    return _json['location'] as String;
  }

  set location(String value) {
    _json['location'] = value;
  }

  @override
  String toString() {
    return _json.toString();
  }

  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _ToolCallingWeatherInputTypeFactory
    extends SchemanticType<ToolCallingWeatherInput> {
  const _ToolCallingWeatherInputTypeFactory();

  @override
  ToolCallingWeatherInput parse(Object? json) {
    return ToolCallingWeatherInput._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'ToolCallingWeatherInput',
    definition: $Schema
        .object(
          properties: {'location': $Schema.string()},
          required: ['location'],
        )
        .value,
    dependencies: [],
  );
}
