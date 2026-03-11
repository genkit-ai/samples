// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'autonomous_operation.dart';

// **************************************************************************
// SchemaGenerator
// **************************************************************************

base class AutonomousOperationInput {
  factory AutonomousOperationInput.fromJson(Map<String, dynamic> json) =>
      $schema.parse(json);

  AutonomousOperationInput._(this._json);

  AutonomousOperationInput({required String goal}) {
    _json = {'goal': goal};
  }

  late final Map<String, dynamic> _json;

  static const SchemanticType<AutonomousOperationInput> $schema =
      _AutonomousOperationInputTypeFactory();

  String get goal {
    return _json['goal'] as String;
  }

  set goal(String value) {
    _json['goal'] = value;
  }

  @override
  String toString() {
    return _json.toString();
  }

  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _AutonomousOperationInputTypeFactory
    extends SchemanticType<AutonomousOperationInput> {
  const _AutonomousOperationInputTypeFactory();

  @override
  AutonomousOperationInput parse(Object? json) {
    return AutonomousOperationInput._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'AutonomousOperationInput',
    definition: $Schema
        .object(
          properties: {
            'goal': $Schema.fromMap({
              'default': 'Research the current state of Genkit Dart support.',
              'type': 'string',
            }),
          },
          required: ['goal'],
        )
        .value,
    dependencies: [],
  );
}

base class AgentSearchInput {
  factory AgentSearchInput.fromJson(Map<String, dynamic> json) =>
      $schema.parse(json);

  AgentSearchInput._(this._json);

  AgentSearchInput({required String query}) {
    _json = {'query': query};
  }

  late final Map<String, dynamic> _json;

  static const SchemanticType<AgentSearchInput> $schema =
      _AgentSearchInputTypeFactory();

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

base class _AgentSearchInputTypeFactory
    extends SchemanticType<AgentSearchInput> {
  const _AgentSearchInputTypeFactory();

  @override
  AgentSearchInput parse(Object? json) {
    return AgentSearchInput._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'AgentSearchInput',
    definition: $Schema
        .object(properties: {'query': $Schema.string()}, required: ['query'])
        .value,
    dependencies: [],
  );
}

base class AgentAskUserInput {
  factory AgentAskUserInput.fromJson(Map<String, dynamic> json) =>
      $schema.parse(json);

  AgentAskUserInput._(this._json);

  AgentAskUserInput({required String question}) {
    _json = {'question': question};
  }

  late final Map<String, dynamic> _json;

  static const SchemanticType<AgentAskUserInput> $schema =
      _AgentAskUserInputTypeFactory();

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

base class _AgentAskUserInputTypeFactory
    extends SchemanticType<AgentAskUserInput> {
  const _AgentAskUserInputTypeFactory();

  @override
  AgentAskUserInput parse(Object? json) {
    return AgentAskUserInput._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'AgentAskUserInput',
    definition: $Schema
        .object(
          properties: {'question': $Schema.string()},
          required: ['question'],
        )
        .value,
    dependencies: [],
  );
}
