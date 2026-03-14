import '../models/chat_actor_kind.dart';

class ChatContactPolicy {
  const ChatContactPolicy();

  String? denyReason({
    required ChatActorKind initiator,
    required ChatActorKind participant,
    required bool hasAcceptedRecruitment,
  }) {
    if (_isPair(
      initiator,
      participant,
      ChatActorKind.musician,
      ChatActorKind.musician,
    )) {
      return null;
    }

    if (_isPair(
      initiator,
      participant,
      ChatActorKind.studio,
      ChatActorKind.musician,
    )) {
      return null;
    }

    if (_isPair(
      initiator,
      participant,
      ChatActorKind.eventManager,
      ChatActorKind.venue,
    )) {
      return null;
    }

    if (_isPair(
      initiator,
      participant,
      ChatActorKind.eventManager,
      ChatActorKind.musician,
    )) {
      if (hasAcceptedRecruitment) {
        return null;
      }
      return 'Solo se permite chat entre event manager y músico cuando la reclutación está aceptada.';
    }

    switch (initiator) {
      case ChatActorKind.musician:
        return 'Los músicos solo pueden chatear con músicos y studios.';
      case ChatActorKind.studio:
        return 'Los studios solo pueden chatear con músicos.';
      case ChatActorKind.eventManager:
        return 'Los event managers solo pueden chatear con venues y con músicos que hayan aceptado reclutación.';
      case ChatActorKind.venue:
        return 'Los venues solo pueden chatear con event managers.';
      case ChatActorKind.unknown:
        return 'No se pudo validar tu perfil para iniciar este chat.';
    }
  }

  bool _isPair(
    ChatActorKind left,
    ChatActorKind right,
    ChatActorKind a,
    ChatActorKind b,
  ) {
    return (left == a && right == b) || (left == b && right == a);
  }
}
