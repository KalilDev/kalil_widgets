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
      final Finder gradientFinder = find.byType(ExpandedFABCounter);
      final ExpandedFABCounter expandedFAB = tester.widget(gradientFinder);
      return expandedFAB.isEnabled;
    }

    bool isBlurred() {
      final Finder gradientFinder = find.byType(ExpandedFABCounter);
      final ExpandedFABCounter expandedFAB = tester.widget(gradientFinder);
      return expandedFAB.isBlurred;
    }

    await tester.pumpWidget(MaterialApp(
        home: ExpandedFABCounter(
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
    await expectLater(find.byType(ExpandedFABCounter),
        matchesGoldenFile('000ExpandedFAB.png'));

    // Use the `findsOneWidget` matcher provided by flutter_test to verify our
    // Text Widgets appear exactly once in the Widget tree
    expect(counterFinder(), findsOneWidget);
    expect(messageFinder, findsOneWidget);
    await tester.tap(find.byType(RawMaterialButton));

    await tester.pumpWidget(MaterialApp(
        home: ExpandedFABCounter(
            counter: counter,
            isEnabled: counter > 0,
            isBlurred: false,
            onPressed: () => counter--)));
    await tester.pumpAndSettle();
    await expectLater(find.byType(ExpandedFABCounter),
        matchesGoldenFile('101ExpandedFAB.png'));

    // Check counter
    expect(counter, 1);
    expect(counterFinder(), findsOneWidget);

    // Check blur and gradient;
    expect(isBlurred(), false);
    expect(isEnabled(), true);

    await tester.tap(find.byType(RawMaterialButton));
    await tester.pumpWidget(MaterialApp(
        home: ExpandedFABCounter(
            counter: counter, isEnabled: counter > 0, isBlurred: true, onPressed: () => counter++,)));
    await tester.pumpAndSettle();
    await expectLater(find.byType(ExpandedFABCounter),
        matchesGoldenFile('010ExpandedFAB.png'));

    // Check counter
    expect(counter, 0);
    expect(counterFinder(), findsOneWidget);

    // Check blur and gradient;
    expect(isBlurred(), true);
    expect(isEnabled(), false);

    await tester.tap(find.byType(RawMaterialButton));
    await tester.pumpWidget(MaterialApp(
        home: ExpandedFABCounter(
            counter: counter, isEnabled: counter > 0, isBlurred: true)));
    await tester.pumpAndSettle();
    await expectLater(find.byType(ExpandedFABCounter),
        matchesGoldenFile('111ExpandedFAB.png'));

    // Check counter
    expect(counter, 1);
    expect(counterFinder(), findsOneWidget);

    // Check blur and gradient;
    expect(isBlurred(), true);
    expect(isEnabled(), true);
  });

  const double kElevation = 4.0;
  testWidgets('Test Light elevatedContainer', (WidgetTester tester) async {
    final BorderRadius radius = BorderRadius.circular(20.0);
    await tester.pumpWidget(MaterialApp(
        theme: ThemeData.light(),
        home: ElevatedContainer(
          elevation: kElevation,
          borderRadius: radius,
          child: const SizedBox(height: 50.0, width: 50.0),
        )));

    await expectLater(find.byType(ElevatedContainer),
        matchesGoldenFile('lightElevatedContainer.png'));
    expect(find.byType(PhysicalShape), findsOneWidget);
  });

  testWidgets('Test Dark elevatedContainer', (WidgetTester tester) async {
    final BorderRadius radius = BorderRadius.circular(20.0);
    await tester.pumpWidget(MaterialApp(
        theme: ThemeData.dark(),
        home: ElevatedContainer(
          elevation: kElevation,
          borderRadius: radius,
          child: const SizedBox(height: 50.0, width: 50.0),
        )));

    await expectLater(find.byType(ElevatedContainer),
        matchesGoldenFile('darkElevatedContainer.png'));
    expect(find.byType(PhysicalShape), findsNothing);
  });

  test('Tests the materialCompliantElevation color', () {
    expect(materialCompliantElevation(
        brightness: ThemeData.light().brightness,
        bg: ThemeData.light().backgroundColor,
        elevation: 0.0), ThemeData.light().backgroundColor);

    expect(materialCompliantElevation(
        brightness: ThemeData.light().brightness,
        bg: ThemeData.light().backgroundColor,
        elevation: kElevation), ThemeData.light().backgroundColor);

    expect(materialCompliantElevation(
        brightness: ThemeData.dark().brightness,
        bg: ThemeData.dark().backgroundColor,
        elevation: 0.0), ThemeData.dark().backgroundColor);

    expect(materialCompliantElevation(
        brightness: ThemeData.dark().brightness,
        bg: ThemeData.dark().backgroundColor,
        elevation: kElevation), Color.alphaBlend(Colors.white.withAlpha((guidelinesDarkElevation[kElevation]*2.55).round()), ThemeData.dark().backgroundColor));

    expect(materialCompliantElevation(
        brightness: ThemeData.dark().brightness,
        bg: ThemeData.dark().backgroundColor,
        elevation: kElevation) == materialCompliantElevation(
        brightness: ThemeData.dark().brightness,
        bg: ThemeData.dark().backgroundColor,
        elevation: kElevation+1.0), false);
  });
}
