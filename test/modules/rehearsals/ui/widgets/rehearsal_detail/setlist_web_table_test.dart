import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:upsessions/l10n/app_localizations.dart';
import 'package:upsessions/modules/rehearsals/models/setlist_item_entity.dart';
import 'package:upsessions/modules/rehearsals/ui/widgets/rehearsal_detail/rehearsal_detail_web_table.dart';

void main() {
  SetlistItemEntity buildItem({
    required String id,
    required int order,
    required String title,
    String notes = '',
  }) {
    return SetlistItemEntity(
      id: id,
      order: order,
      songId: null,
      songTitle: title,
      keySignature: '',
      tempoBpm: null,
      notes: notes,
      linkUrl: '',
      sheetUrl: '',
      sheetPath: '',
    );
  }

  Widget buildHost(List<SetlistItemEntity> setlist) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SizedBox(
          height: 320,
          child: SetlistWebTable(
            setlist: setlist,
            onEditSong: (_) {},
            onDeleteSong: (_) {},
            onReorderSetlist: (_) async {},
          ),
        ),
      ),
    );
  }

  testWidgets(
    'updates visible row content when item data changes with same id/order',
    (tester) async {
      await tester.pumpWidget(
        buildHost([
          buildItem(id: 'song-1', order: 0, title: 'Song A', notes: 'First'),
        ]),
      );

      expect(find.text('Song A'), findsOneWidget);
      expect(find.text('First'), findsOneWidget);

      await tester.pumpWidget(
        buildHost([
          buildItem(id: 'song-1', order: 0, title: 'Song B', notes: 'Updated'),
        ]),
      );
      await tester.pump();

      expect(find.text('Song B'), findsOneWidget);
      expect(find.text('Updated'), findsOneWidget);
      expect(find.text('Song A'), findsNothing);
    },
  );
}
