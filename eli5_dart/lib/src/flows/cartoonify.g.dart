// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cartoonify.dart';

// **************************************************************************
// SchemaGenerator
// **************************************************************************

base class CartoonifyRequest {
  factory CartoonifyRequest.fromJson(Map<String, dynamic> json) =>
      $schema.parse(json);

  CartoonifyRequest._(this._json);

  CartoonifyRequest({required String image}) {
    _json = {'image': image};
  }

  late final Map<String, dynamic> _json;

  static const SchemanticType<CartoonifyRequest> $schema =
      _CartoonifyRequestTypeFactory();

  String get image {
    return _json['image'] as String;
  }

  set image(String value) {
    _json['image'] = value;
  }

  @override
  String toString() {
    return _json.toString();
  }

  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _CartoonifyRequestTypeFactory
    extends SchemanticType<CartoonifyRequest> {
  const _CartoonifyRequestTypeFactory();

  @override
  CartoonifyRequest parse(Object? json) {
    return CartoonifyRequest._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
        name: 'CartoonifyRequest',
        definition: $Schema.object(
            properties: {'image': $Schema.string()}, required: ['image']).value,
        dependencies: [],
      );
}
