// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agentic_rag.dart';

// **************************************************************************
// SchemaGenerator
// **************************************************************************

base class AgenticRagRequest {
  factory AgenticRagRequest.fromJson(Map<String, dynamic> json) =>
      $schema.parse(json);

  AgenticRagRequest._(this._json);

  AgenticRagRequest({required String question}) {
    _json = {'question': question};
  }

  late final Map<String, dynamic> _json;

  static const SchemanticType<AgenticRagRequest> $schema =
      _AgenticRagRequestTypeFactory();

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

base class _AgenticRagRequestTypeFactory
    extends SchemanticType<AgenticRagRequest> {
  const _AgenticRagRequestTypeFactory();

  @override
  AgenticRagRequest parse(Object? json) {
    return AgenticRagRequest._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'AgenticRagRequest',
    definition: $Schema
        .object(
          properties: {
            'question': $Schema.fromMap({
              'default': 'What kind of burgers do you have?',
              'type': 'string',
            }),
          },
          required: ['question'],
        )
        .value,
    dependencies: [],
  );
}

base class MenuRagToolRequest {
  factory MenuRagToolRequest.fromJson(Map<String, dynamic> json) =>
      $schema.parse(json);

  MenuRagToolRequest._(this._json);

  MenuRagToolRequest({required String query}) {
    _json = {'query': query};
  }

  late final Map<String, dynamic> _json;

  static const SchemanticType<MenuRagToolRequest> $schema =
      _MenuRagToolRequestTypeFactory();

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

base class _MenuRagToolRequestTypeFactory
    extends SchemanticType<MenuRagToolRequest> {
  const _MenuRagToolRequestTypeFactory();

  @override
  MenuRagToolRequest parse(Object? json) {
    return MenuRagToolRequest._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'MenuRagToolRequest',
    definition: $Schema
        .object(
          properties: {
            'query': $Schema.string(
              description:
                  'Basic keyword search query that does simple word matching. Allows multiple space separated words, e.g.: burger milkshake',
            ),
          },
          required: ['query'],
        )
        .value,
    dependencies: [],
  );
}
