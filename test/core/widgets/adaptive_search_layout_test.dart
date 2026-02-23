import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:upsessions/core/widgets/adaptive_search_layout.dart';

void main() {
  testWidgets('renders filter panel on mobile constraints', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(390, 844));

    bool? isWideValue;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveSearchLayout(
            topBar: const Text('Top Bar'),
            filterPanelBuilder: (context, isWide) {
              isWideValue = isWide;
              return const Text('Filter Panel');
            },
            results: const Text('Results'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(isWideValue, isFalse);
    expect(find.text('Top Bar'), findsOneWidget);
    expect(find.text('Filter Panel'), findsOneWidget);
    expect(find.text('Results'), findsOneWidget);
    expect(find.byType(Divider), findsOneWidget);
    expect(find.byType(VerticalDivider), findsNothing);
  });

  testWidgets('renders split layout on wide constraints', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(1366, 768));

    bool? isWideValue;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveSearchLayout(
            topBar: const Text('Top Bar'),
            filterPanelBuilder: (context, isWide) {
              isWideValue = isWide;
              return const Text('Filter Panel');
            },
            results: const Text('Results'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(isWideValue, isTrue);
    expect(find.text('Top Bar'), findsOneWidget);
    expect(find.text('Filter Panel'), findsOneWidget);
    expect(find.text('Results'), findsOneWidget);
    expect(find.byType(VerticalDivider), findsOneWidget);
  });
}
