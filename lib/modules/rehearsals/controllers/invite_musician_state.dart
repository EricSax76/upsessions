import 'package:flutter/foundation.dart';
import 'package:upsessions/core/constants/app_link_scheme.dart';
import 'package:upsessions/core/constants/app_routes.dart';

import '../../musicians/models/musician_entity.dart';

@immutable
class InviteMusicianDialogState {
  const InviteMusicianDialogState({
    required this.query,
    required this.isLoading,
    required this.results,
  });

  const InviteMusicianDialogState.initial()
      : query = '',
        isLoading = false,
        results = const [];

  final String query;
  final bool isLoading;
  final List<MusicianEntity> results;

  bool get hasQuery => query.trim().isNotEmpty;
  bool get hasResults => results.isNotEmpty;

  InviteMusicianDialogState copyWith({
    String? query,
    bool? isLoading,
    List<MusicianEntity>? results,
  }) {
    return InviteMusicianDialogState(
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      results: results ?? this.results,
    );
  }
}

@immutable
class InviteLinkData {
  const InviteLinkData({required this.groupId, required this.inviteId});

  final String groupId;
  final String inviteId;

  String get url => '$appLinkScheme://${AppRoutes.invitePath(groupId: groupId, inviteId: inviteId)}';
}
