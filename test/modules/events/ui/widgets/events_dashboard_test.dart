import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:upsessions/modules/events/ui/widgets/events_dashboard.dart';
import 'package:upsessions/l10n/app_localizations.dart';

void main() {
  testWidgets('renders empty state message when no events are available', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: EventsDashboard(
          events: const [],
          loading: false,
          eventsCount: 0,
          thisWeekCount: 0,
          totalCapacity: 0,
          ownerId: null,
          onRefresh: () async {},
          onSelectForPreview: (_) {},
          onViewDetails: (_) {},
          onCreateEvent: () {},
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.event_busy_outlined), findsOneWidget);
    expect(
      find.text(
        'Aún no hay eventos publicados. Sé el primero en crear uno desde la sección Eventos.',
      ),
      findsOneWidget,
    );
  });
}
