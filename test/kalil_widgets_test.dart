import 'package:flutter_test/flutter_test.dart';
import 'package:kalil_widgets/kalil_widgets.dart';
import 'package:kalil_widgets/constants.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Tests if ExpandedFABCounter works properly',
      (WidgetTester tester) async {
    int counter = 0;
    Finder counterFinder() => find.text(counter.toString());

    bool isEnabled() {
      final Finder gradientFinder = find.byType(AnimatedGradientContainer);
      final AnimatedGradientContainer gradient = tester.widget(gradientFinder);
      return gradient.isEnabled;
    }

    bool isBlurred() {
      final Finder blurFinder = find.byType(BlurOverlay);
      final BlurOverlay blur = tester.widget(blurFinder);
      return blur.enabled;
    }
    
    await tester.pumpWidget(MaterialApp(home: ExpandedFABCounter(
        counter: counter,
        isEnabled: counter > 0,
        isBlurred: false,
        onPressed: () => counter++)));
    await tester.pumpAndSettle();

    // Find the favorites text
    final Finder messageFinder = find.text(textFavs);

    // Check blur and gradient;
    expect(isBlurred(), false);
    expect(isEnabled(), false);

    // Use the `findsOneWidget` matcher provided by flutter_test to verify our
    // Text Widgets appear exactly once in the Widget tree
    expect(counterFinder(), findsOneWidget);
    expect(messageFinder, findsOneWidget);
    await tester.tap(find.byType(RaisedButton));

    await tester.pumpWidget(MaterialApp(home: ExpandedFABCounter(
        counter: counter,
        isEnabled: counter > 0,
        isBlurred: false,
        onPressed: () => counter--)));
    await tester.pumpAndSettle();

    // Check counter
    expect(counter, 1);
    expect(counterFinder(), findsOneWidget);

    // Check blur and gradient;
    expect(isBlurred(), false);
    expect(isEnabled(), true);

    await tester.tap(find.byType(RaisedButton));
    await tester.pumpWidget(MaterialApp(home: ExpandedFABCounter(
        counter: counter,
        isEnabled: counter > 0,
        isBlurred: true)));
    await tester.pumpAndSettle();

    // Check counter
    expect(counter, 0);
    expect(counterFinder(), findsOneWidget);

    // Check blur and gradient;
    expect(isBlurred(), true);
    expect(isEnabled(), false);

  });
}
