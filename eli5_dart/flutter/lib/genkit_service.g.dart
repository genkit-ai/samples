// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'genkit_service.dart';

// **************************************************************************
// SchemaGenerator
// **************************************************************************

base class Page {
  factory Page.fromJson(Map<String, dynamic> json) => $schema.parse(json);

  Page._(this._json);

  Page({required String text, required String illustration}) {
    _json = {'text': text, 'illustration': illustration};
  }

  late final Map<String, dynamic> _json;

  static const SchemanticType<Page> $schema = _PageTypeFactory();

  String get text {
    return _json['text'] as String;
  }

  set text(String value) {
    _json['text'] = value;
  }

  String get illustration {
    return _json['illustration'] as String;
  }

  set illustration(String value) {
    _json['illustration'] = value;
  }

  @override
  String toString() {
    return _json.toString();
  }

  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _PageTypeFactory extends SchemanticType<Page> {
  const _PageTypeFactory();

  @override
  Page parse(Object? json) {
    return Page._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'Page',
    definition: $Schema
        .object(
          properties: {
            'text': $Schema.string(
              description: '1-2 paragraphs of text explaining a key concept',
            ),
            'illustration': $Schema.string(
              description: 'a detailed description of the image',
            ),
          },
          required: ['text', 'illustration'],
        )
        .value,
    dependencies: [],
  );
}

base class Storybook {
  factory Storybook.fromJson(Map<String, dynamic> json) => $schema.parse(json);

  Storybook._(this._json);

  Storybook({
    required String status,
    required String bookTitle,
    required List<Page> pages,
  }) {
    _json = {
      'status': status,
      'bookTitle': bookTitle,
      'pages': pages.map((e) => e.toJson()).toList(),
    };
  }

  late final Map<String, dynamic> _json;

  static const SchemanticType<Storybook> $schema = _StorybookTypeFactory();

  String get status {
    return _json['status'] as String;
  }

  set status(String value) {
    _json['status'] = value;
  }

  String get bookTitle {
    return _json['bookTitle'] as String;
  }

  set bookTitle(String value) {
    _json['bookTitle'] = value;
  }

  List<Page> get pages {
    return (_json['pages'] as List)
        .map((e) => Page.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  set pages(List<Page> value) {
    _json['pages'] = value.toList();
  }

  @override
  String toString() {
    return _json.toString();
  }

  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _StorybookTypeFactory extends SchemanticType<Storybook> {
  const _StorybookTypeFactory();

  @override
  Storybook parse(Object? json) {
    return Storybook._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'Storybook',
    definition: $Schema
        .object(
          properties: {
            'status': $Schema.fromMap({'default': '', 'type': 'string'}),
            'bookTitle': $Schema.fromMap({'default': '', 'type': 'string'}),
            'pages': $Schema.fromMap({
              'default': [],
              'items': $Schema.fromMap({'\$ref': r'#/$defs/Page'}),
              'type': 'array',
            }),
          },
          required: ['status', 'bookTitle', 'pages'],
        )
        .value,
    dependencies: [Page.$schema],
  );
}
