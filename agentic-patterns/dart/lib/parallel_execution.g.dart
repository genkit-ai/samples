// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parallel_execution.dart';

// **************************************************************************
// SchemaGenerator
// **************************************************************************

base class ProductInput {
  factory ProductInput.fromJson(Map<String, dynamic> json) =>
      $schema.parse(json);

  ProductInput._(this._json);

  ProductInput({required String product}) {
    _json = {'product': product};
  }

  late final Map<String, dynamic> _json;

  static const SchemanticType<ProductInput> $schema =
      _ProductInputTypeFactory();

  String get product {
    return _json['product'] as String;
  }

  set product(String value) {
    _json['product'] = value;
  }

  @override
  String toString() {
    return _json.toString();
  }

  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _ProductInputTypeFactory extends SchemanticType<ProductInput> {
  const _ProductInputTypeFactory();

  @override
  ProductInput parse(Object? json) {
    return ProductInput._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'ProductInput',
    definition: $Schema
        .object(
          properties: {
            'product': $Schema.fromMap({
              'default': 'a solar-powered coffee maker',
              'type': 'string',
            }),
          },
          required: ['product'],
        )
        .value,
    dependencies: [],
  );
}

base class MarketingCopy {
  factory MarketingCopy.fromJson(Map<String, dynamic> json) =>
      $schema.parse(json);

  MarketingCopy._(this._json);

  MarketingCopy({required String name, required String tagline}) {
    _json = {'name': name, 'tagline': tagline};
  }

  late final Map<String, dynamic> _json;

  static const SchemanticType<MarketingCopy> $schema =
      _MarketingCopyTypeFactory();

  String get name {
    return _json['name'] as String;
  }

  set name(String value) {
    _json['name'] = value;
  }

  String get tagline {
    return _json['tagline'] as String;
  }

  set tagline(String value) {
    _json['tagline'] = value;
  }

  @override
  String toString() {
    return _json.toString();
  }

  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _MarketingCopyTypeFactory extends SchemanticType<MarketingCopy> {
  const _MarketingCopyTypeFactory();

  @override
  MarketingCopy parse(Object? json) {
    return MarketingCopy._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'MarketingCopy',
    definition: $Schema
        .object(
          properties: {'name': $Schema.string(), 'tagline': $Schema.string()},
          required: ['name', 'tagline'],
        )
        .value,
    dependencies: [],
  );
}
