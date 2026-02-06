import 'package:flutter/material.dart';

import 'rehearsal_entity.dart';
import 'setlist_item_entity.dart';

import '../ui/widgets/rehearsal_detail/rehearsal_detail_web.dart';

class RehearsalDetailContent extends StatelessWidget {
  const RehearsalDetailContent({
    super.key,
    required this.rehearsal,
    required this.setlist,
    required this.onEditRehearsal,
    this.onDeleteRehearsal,
    required this.onCopyFromLast,
    required this.onAddSong,
    required this.onEditSong,
    required this.onDeleteSong,
    required this.onReorderSetlist,
    this.onBookRoom,
    this.bookingRoomName,
    this.bookingAddress,
  });

  final RehearsalEntity rehearsal;
  final List<SetlistItemEntity> setlist;
  final VoidCallback onEditRehearsal;
  final VoidCallback? onDeleteRehearsal;
  final VoidCallback onCopyFromLast;
  final VoidCallback onAddSong;
  final ValueChanged<SetlistItemEntity> onEditSong;
  final ValueChanged<SetlistItemEntity> onDeleteSong;
  final ValueChanged<List<String>> onReorderSetlist;
  final VoidCallback? onBookRoom;
  final String? bookingRoomName;
  final String? bookingAddress;

  @override
  Widget build(BuildContext context) {
    return RehearsalDetailWebLayout(
      rehearsal: rehearsal,
      setlist: setlist,
      onEditRehearsal: onEditRehearsal,
      onDeleteRehearsal: onDeleteRehearsal,
      onCopyFromLast: onCopyFromLast,
      onAddSong: onAddSong,
      onEditSong: onEditSong,
      onDeleteSong: onDeleteSong,
      onReorderSetlist: onReorderSetlist,
      onBookRoom: onBookRoom,
      bookingRoomName: bookingRoomName,
      bookingAddress: bookingAddress,
    );
  }
}
