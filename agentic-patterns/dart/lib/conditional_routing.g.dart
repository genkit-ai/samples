// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conditional_routing.dart';

// **************************************************************************
// SchemaGenerator
// **************************************************************************

base class RouterInput {
  factory RouterInput.fromJson(Map<String, dynamic> json) =>
      $schema.parse(json);

  RouterInput._(this._json);

  RouterInput({required String query}) {
    _json = {'query': query};
  }

  late final Map<String, dynamic> _json;

  static const SchemanticType<RouterInput> $schema = _RouterInputTypeFactory();

  String get query {
    return _json['query'] as String;
  }

  set query(String value) {
    _json['query'] = value;
  }

  @override
  String toString() {
    return _json.toString();
  }

  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _RouterInputTypeFactory extends SchemanticType<RouterInput> {
  const _RouterInputTypeFactory();

  @override
  RouterInput parse(Object? json) {
    return RouterInput._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'RouterInput',
    definition: $Schema
        .object(
          properties: {
            'query': $Schema.fromMap({
              'default': 'How do I bake a cake?',
              'type': 'string',
            }),
          },
          required: ['query'],
        )
        .value,
    dependencies: [],
  );
}

base class IntentClassification {
  factory IntentClassification.fromJson(Map<String, dynamic> json) =>
      $schema.parse(json);

  IntentClassification._(this._json);

  IntentClassification({required String intent}) {
    _json = {'intent': intent};
  }

  late final Map<String, dynamic> _json;

  static const SchemanticType<IntentClassification> $schema =
      _IntentClassificationTypeFactory();

  String get intent {
    return _json['intent'] as String;
  }

  set intent(String value) {
    _json['intent'] = value;
  }

  @override
  String toString() {
    return _json.toString();
  }

  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _IntentClassificationTypeFactory
    extends SchemanticType<IntentClassification> {
  const _IntentClassificationTypeFactory();

  @override
  IntentClassification parse(Object? json) {
    return IntentClassification._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'IntentClassification',
    definition: $Schema
        .object(properties: {'intent': $Schema.string()}, required: ['intent'])
        .value,
    dependencies: [],
  );
}
