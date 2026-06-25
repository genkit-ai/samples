// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_genkit_shelf.dart';

// **************************************************************************
// SchemaGenerator
// **************************************************************************

base class IngredientOnSaleInput {
  /// Creates a [IngredientOnSaleInput] from a JSON map.
  factory IngredientOnSaleInput.fromJson(Map<String, dynamic> json) =>
      $schema.parse(json);

  IngredientOnSaleInput._(this._json);

  IngredientOnSaleInput({required String dayType}) {
    _json = {'dayType': dayType};
  }

  late final Map<String, dynamic> _json;

  /// The JSON schema and type descriptor for [IngredientOnSaleInput].
  static const SchemanticType<IngredientOnSaleInput> $schema =
      _IngredientOnSaleInputTypeFactory();

  String get dayType {
    return _json['dayType'] as String;
  }

  set dayType(String value) {
    _json['dayType'] = value;
  }

  @override
  String toString() {
    return _json.toString();
  }

  /// Serializes this [IngredientOnSaleInput] to a JSON map.
  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _IngredientOnSaleInputTypeFactory
    extends SchemanticType<IngredientOnSaleInput> {
  const _IngredientOnSaleInputTypeFactory();

  @override
  IngredientOnSaleInput parse(Object? json) {
    return IngredientOnSaleInput._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'IngredientOnSaleInput',
    definition: $Schema
        .object(
          properties: {
            'dayType': $Schema.string(
              description: 'Whether to fetch weekday or weekend sale prices.',
            ),
          },
          required: ['dayType'],
        )
        .value,
    dependencies: [],
  );
}

base class SaleIngredient {
  /// Creates a [SaleIngredient] from a JSON map.
  factory SaleIngredient.fromJson(Map<String, dynamic> json) =>
      $schema.parse(json);

  SaleIngredient._(this._json);

  SaleIngredient({required String name, required String price}) {
    _json = {'name': name, 'price': price};
  }

  late final Map<String, dynamic> _json;

  /// The JSON schema and type descriptor for [SaleIngredient].
  static const SchemanticType<SaleIngredient> $schema =
      _SaleIngredientTypeFactory();

  String get name {
    return _json['name'] as String;
  }

  set name(String value) {
    _json['name'] = value;
  }

  String get price {
    return _json['price'] as String;
  }

  set price(String value) {
    _json['price'] = value;
  }

  @override
  String toString() {
    return _json.toString();
  }

  /// Serializes this [SaleIngredient] to a JSON map.
  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _SaleIngredientTypeFactory extends SchemanticType<SaleIngredient> {
  const _SaleIngredientTypeFactory();

  @override
  SaleIngredient parse(Object? json) {
    return SaleIngredient._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'SaleIngredient',
    definition: $Schema
        .object(
          properties: {'name': $Schema.string(), 'price': $Schema.string()},
          required: ['name', 'price'],
        )
        .value,
    dependencies: [],
  );
}

base class RecipeIngredient {
  /// Creates a [RecipeIngredient] from a JSON map.
  factory RecipeIngredient.fromJson(Map<String, dynamic> json) =>
      $schema.parse(json);

  RecipeIngredient._(this._json);

  RecipeIngredient({
    required String name,
    required String quantity,
    required bool onSale,
  }) {
    _json = {'name': name, 'quantity': quantity, 'onSale': onSale};
  }

  late final Map<String, dynamic> _json;

  /// The JSON schema and type descriptor for [RecipeIngredient].
  static const SchemanticType<RecipeIngredient> $schema =
      _RecipeIngredientTypeFactory();

  String get name {
    return _json['name'] as String;
  }

  set name(String value) {
    _json['name'] = value;
  }

  String get quantity {
    return _json['quantity'] as String;
  }

  set quantity(String value) {
    _json['quantity'] = value;
  }

  bool get onSale {
    return _json['onSale'] as bool;
  }

  set onSale(bool value) {
    _json['onSale'] = value;
  }

  @override
  String toString() {
    return _json.toString();
  }

  /// Serializes this [RecipeIngredient] to a JSON map.
  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _RecipeIngredientTypeFactory
    extends SchemanticType<RecipeIngredient> {
  const _RecipeIngredientTypeFactory();

  @override
  RecipeIngredient parse(Object? json) {
    return RecipeIngredient._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'RecipeIngredient',
    definition: $Schema
        .object(
          properties: {
            'name': $Schema.string(),
            'quantity': $Schema.string(),
            'onSale': $Schema.boolean(),
          },
          required: ['name', 'quantity', 'onSale'],
        )
        .value,
    dependencies: [],
  );
}

base class Recipe {
  /// Creates a [Recipe] from a JSON map.
  factory Recipe.fromJson(Map<String, dynamic> json) => $schema.parse(json);

  Recipe._(this._json);

  Recipe({
    required String title,
    required String description,
    required int servings,
    required List<RecipeIngredient> ingredients,
    required List<String> steps,
  }) {
    _json = {
      'title': title,
      'description': description,
      'servings': servings,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'steps': steps,
    };
  }

  late final Map<String, dynamic> _json;

  /// The JSON schema and type descriptor for [Recipe].
  static const SchemanticType<Recipe> $schema = _RecipeTypeFactory();

  String get title {
    return _json['title'] as String;
  }

  set title(String value) {
    _json['title'] = value;
  }

  String get description {
    return _json['description'] as String;
  }

  set description(String value) {
    _json['description'] = value;
  }

  int get servings {
    return _json['servings'] as int;
  }

  set servings(int value) {
    _json['servings'] = value;
  }

  List<RecipeIngredient> get ingredients {
    return (_json['ingredients'] as List)
        .map((e) => RecipeIngredient.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  set ingredients(List<RecipeIngredient> value) {
    _json['ingredients'] = value.toList();
  }

  List<String> get steps {
    return (_json['steps'] as List).cast<String>();
  }

  set steps(List<String> value) {
    _json['steps'] = value;
  }

  @override
  String toString() {
    return _json.toString();
  }

  /// Serializes this [Recipe] to a JSON map.
  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _RecipeTypeFactory extends SchemanticType<Recipe> {
  const _RecipeTypeFactory();

  @override
  Recipe parse(Object? json) {
    return Recipe._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'Recipe',
    definition: $Schema
        .object(
          properties: {
            'title': $Schema.string(),
            'description': $Schema.string(),
            'servings': $Schema.integer(),
            'ingredients': $Schema.list(
              items: $Schema.fromMap({'\$ref': r'#/$defs/RecipeIngredient'}),
            ),
            'steps': $Schema.list(items: $Schema.string()),
          },
          required: [
            'title',
            'description',
            'servings',
            'ingredients',
            'steps',
          ],
        )
        .value,
    dependencies: [RecipeIngredient.$schema],
  );
}

base class BargainChefInput {
  /// Creates a [BargainChefInput] from a JSON map.
  factory BargainChefInput.fromJson(Map<String, dynamic> json) =>
      $schema.parse(json);

  BargainChefInput._(this._json);

  BargainChefInput({required String craving}) {
    _json = {'craving': craving};
  }

  late final Map<String, dynamic> _json;

  /// The JSON schema and type descriptor for [BargainChefInput].
  static const SchemanticType<BargainChefInput> $schema =
      _BargainChefInputTypeFactory();

  String get craving {
    return _json['craving'] as String;
  }

  set craving(String value) {
    _json['craving'] = value;
  }

  @override
  String toString() {
    return _json.toString();
  }

  /// Serializes this [BargainChefInput] to a JSON map.
  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _BargainChefInputTypeFactory
    extends SchemanticType<BargainChefInput> {
  const _BargainChefInputTypeFactory();

  @override
  BargainChefInput parse(Object? json) {
    return BargainChefInput._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'BargainChefInput',
    definition: $Schema
        .object(
          properties: {
            'craving': $Schema.string(
              description: 'What the user feels like eating right now.',
            ),
          },
          required: ['craving'],
        )
        .value,
    dependencies: [],
  );
}
