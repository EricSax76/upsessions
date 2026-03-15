import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:upsessions/l10n/app_localizations.dart';
import 'package:upsessions/modules/rehearsals/models/rehearsal_entity.dart';
import 'package:upsessions/modules/rehearsals/models/rehearsal_filter.dart';
import 'package:upsessions/modules/rehearsals/ui/widgets/rehearsal_list_card.dart';

void main() {
  RehearsalEntity rehearsal({required String id, required DateTime startsAt}) {
    return RehearsalEntity(
      id: id,
      groupId: 'group-1',
      startsAt: startsAt,
      endsAt: null,
      location: '',
      notes: '',
      createdBy: 'owner-1',
    );
  }

  Widget buildHost({
    required List<RehearsalEntity> rehearsals,
    required List<RehearsalEntity> filtered,
    required RehearsalFilter filter,
    bool showCreateButton = false,
    VoidCallback? onCreate,
  }) {
    return MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: RehearsalListCard(
          rehearsals: rehearsals,
          filtered: filtered,
          currentFilter: filter,
          onFilterChanged: (_) {},
          onRehearsalTap: (_) {},
          showCreateButton: showCreateButton,
          onCreateRehearsal: onCreate,
        ),
      ),
    );
  }

  testWidgets('shows empty rehearsals card when there are no rehearsals', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildHost(
        rehearsals: const [],
        filtered: const [],
        filter: RehearsalFilter.upcoming,
      ),
    );

    expect(find.text('Todavía no hay ensayos'), findsOneWidget);
    expect(
      find.text('Crea el primero para empezar a armar el setlist.'),
      findsOneWidget,
    );
  });

  testWidgets('shows filtered empty state when filter has no results', (
    tester,
  ) async {
    final all = [rehearsal(id: 'r1', startsAt: DateTime(2026, 1, 20, 18, 0))];

    await tester.pumpWidget(
      buildHost(
        rehearsals: all,
        filtered: const [],
        filter: RehearsalFilter.past,
      ),
    );

    expect(find.text('Sin resultados'), findsOneWidget);
    expect(find.text('Todavía no hay ensayos pasados.'), findsOneWidget);
  });

  testWidgets('shows create button and triggers callback', (tester) async {
    var created = false;
    final all = [rehearsal(id: 'r1', startsAt: DateTime(2026, 1, 20, 18, 0))];

    await tester.pumpWidget(
      buildHost(
        rehearsals: all,
        filtered: all,
        filter: RehearsalFilter.all,
        showCreateButton: true,
        onCreate: () => created = true,
      ),
    );

    await tester.tap(find.text('Nuevo Ensayo'));
    await tester.pump();

    expect(created, isTrue);
  });
}
