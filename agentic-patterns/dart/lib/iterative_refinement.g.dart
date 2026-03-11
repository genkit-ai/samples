// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'iterative_refinement.dart';

// **************************************************************************
// SchemaGenerator
// **************************************************************************

base class IterativeRefinementInput {
  factory IterativeRefinementInput.fromJson(Map<String, dynamic> json) =>
      $schema.parse(json);

  IterativeRefinementInput._(this._json);

  IterativeRefinementInput({required String topic}) {
    _json = {'topic': topic};
  }

  late final Map<String, dynamic> _json;

  static const SchemanticType<IterativeRefinementInput> $schema =
      _IterativeRefinementInputTypeFactory();

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

base class _IterativeRefinementInputTypeFactory
    extends SchemanticType<IterativeRefinementInput> {
  const _IterativeRefinementInputTypeFactory();

  @override
  IterativeRefinementInput parse(Object? json) {
    return IterativeRefinementInput._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'IterativeRefinementInput',
    definition: $Schema
        .object(
          properties: {
            'topic': $Schema.fromMap({
              'default': 'the benefits of agentic AI',
              'type': 'string',
            }),
          },
          required: ['topic'],
        )
        .value,
    dependencies: [],
  );
}

base class ReviewResult {
  factory ReviewResult.fromJson(Map<String, dynamic> json) =>
      $schema.parse(json);

  ReviewResult._(this._json);

  ReviewResult({required String feedback, required bool isApproved}) {
    _json = {'feedback': feedback, 'isApproved': isApproved};
  }

  late final Map<String, dynamic> _json;

  static const SchemanticType<ReviewResult> $schema =
      _ReviewResultTypeFactory();

  String get feedback {
    return _json['feedback'] as String;
  }

  set feedback(String value) {
    _json['feedback'] = value;
  }

  bool get isApproved {
    return _json['isApproved'] as bool;
  }

  set isApproved(bool value) {
    _json['isApproved'] = value;
  }

  @override
  String toString() {
    return _json.toString();
  }

  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _ReviewResultTypeFactory extends SchemanticType<ReviewResult> {
  const _ReviewResultTypeFactory();

  @override
  ReviewResult parse(Object? json) {
    return ReviewResult._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'ReviewResult',
    definition: $Schema
        .object(
          properties: {
            'feedback': $Schema.string(),
            'isApproved': $Schema.boolean(),
          },
          required: ['feedback', 'isApproved'],
        )
        .value,
    dependencies: [],
  );
}
