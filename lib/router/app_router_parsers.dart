import 'package:go_router/go_router.dart';

import '../features/events/models/event_entity.dart';
import '../features/messaging/models/chat_thread.dart';
import '../features/messaging/ui/pages/messages_page.dart';
import '../modules/announcements/models/announcement_entity.dart';
import '../modules/musicians/models/musician_entity.dart';
import '../modules/studios/ui/consumer/studios_list_page.dart';

String? musicianIdFromState(GoRouterState state) {
  final id = _pathOrQueryParameter(state, 'musicianId');
  if (id != null) {
    return id;
  }
  final extra = state.extra;
  if (extra is MusicianEntity && extra.id.trim().isNotEmpty) {
    return extra.id.trim();
  }
  return null;
}

String? announcementIdFromState(GoRouterState state) {
  final id = _pathOrQueryParameter(state, 'announcementId');
  if (id != null) {
    return id;
  }
  final extra = state.extra;
  if (extra is AnnouncementEntity && extra.id.trim().isNotEmpty) {
    return extra.id.trim();
  }
  return null;
}

String? eventIdFromState(GoRouterState state) {
  final id = _pathOrQueryParameter(state, 'eventId');
  if (id != null) {
    return id;
  }
  final extra = state.extra;
  if (extra is EventEntity && extra.id.trim().isNotEmpty) {
    return extra.id.trim();
  }
  return null;
}

String? threadIdFromState(GoRouterState state) {
  final id = _pathOrQueryParameter(state, 'threadId');
  if (id != null) {
    return id;
  }

  final extra = state.extra;
  if (extra is MessagesPageArgs) {
    final threadId = extra.initialThreadId?.trim();
    if (threadId != null && threadId.isNotEmpty) {
      return threadId;
    }
  }

  if (extra is ChatThread && extra.id.trim().isNotEmpty) {
    return extra.id.trim();
  }

  if (extra is String && extra.trim().isNotEmpty) {
    return extra.trim();
  }

  return null;
}

String? inviteGroupIdFromState(GoRouterState state) {
  return _pathOrQueryParameter(state, 'groupId');
}

String? inviteIdFromState(GoRouterState state) {
  return _pathOrQueryParameter(state, 'inviteId');
}

RehearsalBookingContext? rehearsalContextFromState(GoRouterState state) {
  final extra = state.extra;
  if (extra is RehearsalBookingContext) {
    return extra;
  }

  final groupId = state.uri.queryParameters['groupId']?.trim() ?? '';
  final rehearsalId = state.uri.queryParameters['rehearsalId']?.trim() ?? '';
  final suggestedDateRaw = state.uri.queryParameters['suggestedDate']?.trim();
  if (groupId.isEmpty || rehearsalId.isEmpty || suggestedDateRaw == null) {
    return null;
  }

  final suggestedDate = DateTime.tryParse(suggestedDateRaw);
  if (suggestedDate == null) {
    return null;
  }

  final suggestedEndDateRaw = state.uri.queryParameters['suggestedEndDate']
      ?.trim();
  final suggestedEndDate =
      suggestedEndDateRaw == null || suggestedEndDateRaw.isEmpty
      ? null
      : DateTime.tryParse(suggestedEndDateRaw);

  return RehearsalBookingContext(
    groupId: groupId,
    rehearsalId: rehearsalId,
    suggestedDate: suggestedDate,
    suggestedEndDate: suggestedEndDate,
  );
}

String? _pathOrQueryParameter(GoRouterState state, String parameterName) {
  final pathValue = state.pathParameters[parameterName]?.trim();
  if (pathValue != null && pathValue.isNotEmpty) {
    return pathValue;
  }

  final queryValue = state.uri.queryParameters[parameterName]?.trim();
  if (queryValue != null && queryValue.isNotEmpty) {
    return queryValue;
  }

  return null;
}
