import 'package:flutter_test/flutter_test.dart';
import 'package:upsessions/features/messaging/models/chat_actor_kind.dart';
import 'package:upsessions/features/messaging/repositories/chat_contact_policy.dart';

void main() {
  const policy = ChatContactPolicy();

  group('ChatContactPolicy', () {
    test('permite musician <-> musician', () {
      final denyReason = policy.denyReason(
        initiator: ChatActorKind.musician,
        participant: ChatActorKind.musician,
        hasAcceptedRecruitment: false,
      );

      expect(denyReason, isNull);
    });

    test('permite studio <-> musician', () {
      final denyReason = policy.denyReason(
        initiator: ChatActorKind.studio,
        participant: ChatActorKind.musician,
        hasAcceptedRecruitment: false,
      );

      expect(denyReason, isNull);
    });

    test('bloquea studio <-> studio', () {
      final denyReason = policy.denyReason(
        initiator: ChatActorKind.studio,
        participant: ChatActorKind.studio,
        hasAcceptedRecruitment: false,
      );

      expect(denyReason, isNotNull);
    });

    test('permite eventManager <-> venue', () {
      final denyReason = policy.denyReason(
        initiator: ChatActorKind.eventManager,
        participant: ChatActorKind.venue,
        hasAcceptedRecruitment: false,
      );

      expect(denyReason, isNull);
    });

    test('bloquea eventManager <-> musician sin reclutacion aceptada', () {
      final denyReason = policy.denyReason(
        initiator: ChatActorKind.eventManager,
        participant: ChatActorKind.musician,
        hasAcceptedRecruitment: false,
      );

      expect(denyReason, isNotNull);
    });

    test('permite eventManager <-> musician con reclutacion aceptada', () {
      final denyReason = policy.denyReason(
        initiator: ChatActorKind.eventManager,
        participant: ChatActorKind.musician,
        hasAcceptedRecruitment: true,
      );

      expect(denyReason, isNull);
    });

    test('bloquea venue <-> musician', () {
      final denyReason = policy.denyReason(
        initiator: ChatActorKind.venue,
        participant: ChatActorKind.musician,
        hasAcceptedRecruitment: false,
      );

      expect(denyReason, isNotNull);
    });
  });
}
