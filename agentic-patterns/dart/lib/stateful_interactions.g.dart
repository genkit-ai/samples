// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stateful_interactions.dart';

// **************************************************************************
// SchemaGenerator
// **************************************************************************

base class ChatInput {
  factory ChatInput.fromJson(Map<String, dynamic> json) => $schema.parse(json);

  ChatInput._(this._json);

  ChatInput({required String sessionId, required String message}) {
    _json = {'sessionId': sessionId, 'message': message};
  }

  late final Map<String, dynamic> _json;

  static const SchemanticType<ChatInput> $schema = _ChatInputTypeFactory();

  String get sessionId {
    return _json['sessionId'] as String;
  }

  set sessionId(String value) {
    _json['sessionId'] = value;
  }

  String get message {
    return _json['message'] as String;
  }

  set message(String value) {
    _json['message'] = value;
  }

  @override
  String toString() {
    return _json.toString();
  }

  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _ChatInputTypeFactory extends SchemanticType<ChatInput> {
  const _ChatInputTypeFactory();

  @override
  ChatInput parse(Object? json) {
    return ChatInput._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'ChatInput',
    definition: $Schema
        .object(
          properties: {
            'sessionId': $Schema.fromMap({
              'default': 'session123',
              'type': 'string',
            }),
            'message': $Schema.fromMap({'default': 'Hello!', 'type': 'string'}),
          },
          required: ['sessionId', 'message'],
        )
        .value,
    dependencies: [],
  );
}
