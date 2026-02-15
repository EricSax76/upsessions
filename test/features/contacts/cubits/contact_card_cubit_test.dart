import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/features/contacts/cubits/contact_card_cubit.dart';
import 'package:upsessions/features/contacts/cubits/contact_card_state.dart';
import 'package:upsessions/features/contacts/models/liked_musician.dart';
import 'package:upsessions/features/messaging/repositories/chat_repository.dart';

class MockChatRepository extends Mock implements ChatRepository {}

class FakeThread {
  final String id;
  const FakeThread({required this.id});
}

void main() {
  late MockChatRepository chatRepository;

  const musician = LikedMusician(
    id: 'musician-1',
    ownerId: 'owner-1',
    name: 'John Doe',
    instrument: 'Guitar',
    city: 'Valencia',
    styles: ['Rock'],
  );

  setUp(() {
    chatRepository = MockChatRepository();
  });

  group('ContactCardCubit', () {
    test('initial state is idle', () {
      final cubit = ContactCardCubit(chatRepository: chatRepository);
      expect(cubit.state.status, ContactCardStatus.idle);
      expect(cubit.state.isContacting, false);
      cubit.close();
    });

    test('toMusicianEntity converts LikedMusician correctly', () {
      final cubit = ContactCardCubit(chatRepository: chatRepository);
      final entity = cubit.toMusicianEntity(musician);
      expect(entity.id, 'musician-1');
      expect(entity.name, 'John Doe');
      expect(entity.instrument, 'Guitar');
      cubit.close();
    });
  });
}
