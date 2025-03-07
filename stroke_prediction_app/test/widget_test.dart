import 'package:flutter_test/flutter_test.dart';

import 'package:stroke_prediction_app/main.dart';

void main() {
  testWidgets('Stroke Prediction App loads correctly', (
    WidgetTester tester,
  ) async {
    // Build the widget tree.
    await tester.pumpWidget(const StrokeApp());

    // Check if the app title exists (Update the text based on your app's actual UI)
    expect(find.text('Stroke Prediction'), findsOneWidget);
  });
}
