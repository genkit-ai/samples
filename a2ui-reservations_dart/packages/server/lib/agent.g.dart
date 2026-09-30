// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent.dart';

// **************************************************************************
// SchemaGenerator
// **************************************************************************

base class CheckAvailabilityInput {
  /// Creates a [CheckAvailabilityInput] from a JSON map.
  factory CheckAvailabilityInput.fromJson(Map<String, dynamic> json) =>
      $schema.parse(json);

  CheckAvailabilityInput._(this._json);

  CheckAvailabilityInput({
    required String restaurant,
    required String date,
    required int partySize,
  }) {
    _json = {'restaurant': restaurant, 'date': date, 'partySize': partySize};
  }

  late final Map<String, dynamic> _json;

  /// The JSON schema and type descriptor for [CheckAvailabilityInput].
  static const SchemanticType<CheckAvailabilityInput> $schema =
      _CheckAvailabilityInputTypeFactory();

  String get restaurant {
    return _json['restaurant'] as String;
  }

  set restaurant(String value) {
    _json['restaurant'] = value;
  }

  String get date {
    return _json['date'] as String;
  }

  set date(String value) {
    _json['date'] = value;
  }

  int get partySize {
    return _json['partySize'] as int;
  }

  set partySize(int value) {
    _json['partySize'] = value;
  }

  @override
  String toString() {
    return _json.toString();
  }

  /// Serializes this [CheckAvailabilityInput] to a JSON map.
  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _CheckAvailabilityInputTypeFactory
    extends SchemanticType<CheckAvailabilityInput> {
  const _CheckAvailabilityInputTypeFactory();

  @override
  CheckAvailabilityInput parse(Object? json) {
    return CheckAvailabilityInput._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'CheckAvailabilityInput',
    definition: $Schema
        .object(
          properties: {
            'restaurant': $Schema.string(
              description: 'The restaurant name, e.g. Cymbal Bistro.',
            ),
            'date': $Schema.string(
              description:
                  'The date for the reservation, e.g. tonight, tomorrow, or YYYY-MM-DD.',
            ),
            'partySize': $Schema.integer(description: 'Number of guests.'),
          },
          required: ['restaurant', 'date', 'partySize'],
        )
        .value,
    dependencies: [],
  );
}

base class CheckAvailabilityOutput {
  /// Creates a [CheckAvailabilityOutput] from a JSON map.
  factory CheckAvailabilityOutput.fromJson(Map<String, dynamic> json) =>
      $schema.parse(json);

  CheckAvailabilityOutput._(this._json);

  CheckAvailabilityOutput({
    required String restaurant,
    required String date,
    required int partySize,
    required bool available,
    required List<String> availableSlots,
    required List<String> seatingAreas,
  }) {
    _json = {
      'restaurant': restaurant,
      'date': date,
      'partySize': partySize,
      'available': available,
      'availableSlots': availableSlots,
      'seatingAreas': seatingAreas,
    };
  }

  late final Map<String, dynamic> _json;

  /// The JSON schema and type descriptor for [CheckAvailabilityOutput].
  static const SchemanticType<CheckAvailabilityOutput> $schema =
      _CheckAvailabilityOutputTypeFactory();

  String get restaurant {
    return _json['restaurant'] as String;
  }

  set restaurant(String value) {
    _json['restaurant'] = value;
  }

  String get date {
    return _json['date'] as String;
  }

  set date(String value) {
    _json['date'] = value;
  }

  int get partySize {
    return _json['partySize'] as int;
  }

  set partySize(int value) {
    _json['partySize'] = value;
  }

  bool get available {
    return _json['available'] as bool;
  }

  set available(bool value) {
    _json['available'] = value;
  }

  List<String> get availableSlots {
    return (_json['availableSlots'] as List).cast<String>();
  }

  set availableSlots(List<String> value) {
    _json['availableSlots'] = value;
  }

  List<String> get seatingAreas {
    return (_json['seatingAreas'] as List).cast<String>();
  }

  set seatingAreas(List<String> value) {
    _json['seatingAreas'] = value;
  }

  @override
  String toString() {
    return _json.toString();
  }

  /// Serializes this [CheckAvailabilityOutput] to a JSON map.
  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _CheckAvailabilityOutputTypeFactory
    extends SchemanticType<CheckAvailabilityOutput> {
  const _CheckAvailabilityOutputTypeFactory();

  @override
  CheckAvailabilityOutput parse(Object? json) {
    return CheckAvailabilityOutput._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'CheckAvailabilityOutput',
    definition: $Schema
        .object(
          properties: {
            'restaurant': $Schema.string(),
            'date': $Schema.string(
              description: 'Resolved reservation date in YYYY-MM-DD format.',
            ),
            'partySize': $Schema.integer(),
            'available': $Schema.boolean(),
            'availableSlots': $Schema.list(items: $Schema.string()),
            'seatingAreas': $Schema.list(items: $Schema.string()),
          },
          required: [
            'restaurant',
            'date',
            'partySize',
            'available',
            'availableSlots',
            'seatingAreas',
          ],
        )
        .value,
    dependencies: [],
  );
}

base class ConfirmReservationInput {
  /// Creates a [ConfirmReservationInput] from a JSON map.
  factory ConfirmReservationInput.fromJson(Map<String, dynamic> json) =>
      $schema.parse(json);

  ConfirmReservationInput._(this._json);

  ConfirmReservationInput({
    required String restaurant,
    required String date,
    required String time,
    required int partySize,
    String? seatingArea,
    String? specialRequests,
  }) {
    _json = {
      'restaurant': restaurant,
      'date': date,
      'time': time,
      'partySize': partySize,
      'seatingArea': ?seatingArea,
      'specialRequests': ?specialRequests,
    };
  }

  late final Map<String, dynamic> _json;

  /// The JSON schema and type descriptor for [ConfirmReservationInput].
  static const SchemanticType<ConfirmReservationInput> $schema =
      _ConfirmReservationInputTypeFactory();

  String get restaurant {
    return _json['restaurant'] as String;
  }

  set restaurant(String value) {
    _json['restaurant'] = value;
  }

  String get date {
    return _json['date'] as String;
  }

  set date(String value) {
    _json['date'] = value;
  }

  String get time {
    return _json['time'] as String;
  }

  set time(String value) {
    _json['time'] = value;
  }

  int get partySize {
    return _json['partySize'] as int;
  }

  set partySize(int value) {
    _json['partySize'] = value;
  }

  String? get seatingArea {
    return _json['seatingArea'] as String?;
  }

  set seatingArea(String? value) {
    if (value == null) {
      _json.remove('seatingArea');
    } else {
      _json['seatingArea'] = value;
    }
  }

  String? get specialRequests {
    return _json['specialRequests'] as String?;
  }

  set specialRequests(String? value) {
    if (value == null) {
      _json.remove('specialRequests');
    } else {
      _json['specialRequests'] = value;
    }
  }

  @override
  String toString() {
    return _json.toString();
  }

  /// Serializes this [ConfirmReservationInput] to a JSON map.
  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _ConfirmReservationInputTypeFactory
    extends SchemanticType<ConfirmReservationInput> {
  const _ConfirmReservationInputTypeFactory();

  @override
  ConfirmReservationInput parse(Object? json) {
    return ConfirmReservationInput._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'ConfirmReservationInput',
    definition: $Schema
        .object(
          properties: {
            'restaurant': $Schema.string(
              description: 'The restaurant name, e.g. Cymbal Bistro.',
            ),
            'date': $Schema.string(
              description: 'Reservation date in YYYY-MM-DD format.',
            ),
            'time': $Schema.string(
              description: 'Selected time slot, e.g. 7:00 PM.',
            ),
            'partySize': $Schema.integer(description: 'Number of guests.'),
            'seatingArea': $Schema.string(
              description:
                  'Selected seating area, e.g. Indoor Dining, Heated Patio, or Chef\'s Counter.',
            ),
            'specialRequests': $Schema.string(
              description: 'Special requests or dietary notes.',
            ),
          },
          required: ['restaurant', 'date', 'time', 'partySize'],
        )
        .value,
    dependencies: [],
  );
}

base class ConfirmReservationOutput {
  /// Creates a [ConfirmReservationOutput] from a JSON map.
  factory ConfirmReservationOutput.fromJson(Map<String, dynamic> json) =>
      $schema.parse(json);

  ConfirmReservationOutput._(this._json);

  ConfirmReservationOutput({
    required String confirmationCode,
    required String restaurant,
    required String date,
    required String time,
    required int partySize,
    required String seatingArea,
    required String specialRequests,
    required String status,
  }) {
    _json = {
      'confirmationCode': confirmationCode,
      'restaurant': restaurant,
      'date': date,
      'time': time,
      'partySize': partySize,
      'seatingArea': seatingArea,
      'specialRequests': specialRequests,
      'status': status,
    };
  }

  late final Map<String, dynamic> _json;

  /// The JSON schema and type descriptor for [ConfirmReservationOutput].
  static const SchemanticType<ConfirmReservationOutput> $schema =
      _ConfirmReservationOutputTypeFactory();

  String get confirmationCode {
    return _json['confirmationCode'] as String;
  }

  set confirmationCode(String value) {
    _json['confirmationCode'] = value;
  }

  String get restaurant {
    return _json['restaurant'] as String;
  }

  set restaurant(String value) {
    _json['restaurant'] = value;
  }

  String get date {
    return _json['date'] as String;
  }

  set date(String value) {
    _json['date'] = value;
  }

  String get time {
    return _json['time'] as String;
  }

  set time(String value) {
    _json['time'] = value;
  }

  int get partySize {
    return _json['partySize'] as int;
  }

  set partySize(int value) {
    _json['partySize'] = value;
  }

  String get seatingArea {
    return _json['seatingArea'] as String;
  }

  set seatingArea(String value) {
    _json['seatingArea'] = value;
  }

  String get specialRequests {
    return _json['specialRequests'] as String;
  }

  set specialRequests(String value) {
    _json['specialRequests'] = value;
  }

  String get status {
    return _json['status'] as String;
  }

  set status(String value) {
    _json['status'] = value;
  }

  @override
  String toString() {
    return _json.toString();
  }

  /// Serializes this [ConfirmReservationOutput] to a JSON map.
  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _ConfirmReservationOutputTypeFactory
    extends SchemanticType<ConfirmReservationOutput> {
  const _ConfirmReservationOutputTypeFactory();

  @override
  ConfirmReservationOutput parse(Object? json) {
    return ConfirmReservationOutput._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'ConfirmReservationOutput',
    definition: $Schema
        .object(
          properties: {
            'confirmationCode': $Schema.string(),
            'restaurant': $Schema.string(),
            'date': $Schema.string(),
            'time': $Schema.string(),
            'partySize': $Schema.integer(),
            'seatingArea': $Schema.string(),
            'specialRequests': $Schema.string(),
            'status': $Schema.string(),
          },
          required: [
            'confirmationCode',
            'restaurant',
            'date',
            'time',
            'partySize',
            'seatingArea',
            'specialRequests',
            'status',
          ],
        )
        .value,
    dependencies: [],
  );
}
