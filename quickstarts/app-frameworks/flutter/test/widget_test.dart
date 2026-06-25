import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quickstart_flutter_web/main.dart';

void main() {
  testWidgets('renders Bargain Chef form', (WidgetTester tester) async {
    await tester.pumpWidget(const BargainChefApp());

    expect(find.text('Bargain Chef'), findsOneWidget);
    expect(find.text('Suggest a recipe'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
