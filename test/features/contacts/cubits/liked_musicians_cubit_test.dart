import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/features/contacts/cubits/liked_musicians_cubit.dart';
import 'package:upsessions/features/contacts/cubits/liked_musicians_state.dart';
import 'package:upsessions/features/contacts/models/liked_musician.dart';
import 'package:upsessions/features/contacts/repositories/contacts_repository.dart';
import 'package:upsessions/modules/auth/models/user_entity.dart';
import 'package:upsessions/modules/auth/repositories/auth_repository.dart';

class MockContactsRepository extends Mock implements ContactsRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(const LikedMusician(
      id: '',
      ownerId: '',
      name: '',
      instrument: '',
      city: '',
      styles: [],
    ));
  });

  late MockContactsRepository contactsRepository;
  late MockAuthRepository authRepository;
  late StreamController<UserEntity?> authStreamController;
  late StreamController<List<LikedMusician>> contactsStreamController;

  const mockMusician = LikedMusician(
    id: 'musician-1',
    ownerId: 'owner-1',
    name: 'John Doe',
    instrument: 'Guitar',
    city: 'Valencia',
    styles: ['Rock'],
  );

  const mockMusician2 = LikedMusician(
    id: 'musician-2',
    ownerId: 'owner-2',
    name: 'Jane Smith',
    instrument: 'Drums',
    city: 'Madrid',
    styles: ['Jazz'],
  );

  final mockUser = UserEntity(id: 'user-1', email: 'test@test.com', displayName: 'Test User');

  setUp(() {
    contactsRepository = MockContactsRepository();
    authRepository = MockAuthRepository();
    authStreamController = StreamController<UserEntity?>.broadcast();
    contactsStreamController =
        StreamController<List<LikedMusician>>.broadcast();

    when(
      () => authRepository.authStateChanges,
    ).thenAnswer((_) => authStreamController.stream);
    when(() => authRepository.currentUser).thenReturn(null);
    when(
      () => contactsRepository.watchContacts(any()),
    ).thenAnswer((_) => contactsStreamController.stream);
  });

  tearDown(() {
    authStreamController.close();
    contactsStreamController.close();
  });

  LikedMusiciansCubit buildCubit() {
    return LikedMusiciansCubit(
      contactsRepository: contactsRepository,
      authRepository: authRepository,
    );
  }

  group('LikedMusiciansCubit', () {
    test('initial state is correct', () {
      final cubit = buildCubit();
      expect(cubit.state.status, LikedMusiciansStatus.initial);
      expect(cubit.state.contacts, isEmpty);
      cubit.close();
    });

    test('emits loading then loaded when user authenticates', () async {
      when(() => authRepository.currentUser).thenReturn(null);
      final cubit = buildCubit();

      authStreamController.add(mockUser);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.status, LikedMusiciansStatus.loading);

      contactsStreamController.add([mockMusician, mockMusician2]);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.status, LikedMusiciansStatus.loaded);
      expect(cubit.state.contacts.length, 2);
      expect(cubit.state.isLiked('musician-1'), true);
      expect(cubit.state.isLiked('musician-2'), true);

      await cubit.close();
    });

    test('clears contacts on logout', () async {
      when(() => authRepository.currentUser).thenReturn(mockUser);
      final cubit = buildCubit();

      contactsStreamController.add([mockMusician]);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.contacts.length, 1);

      authStreamController.add(null);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.contacts, isEmpty);
      expect(cubit.state.status, LikedMusiciansStatus.initial);

      await cubit.close();
    });

    test('toggleLike optimistically adds contact', () async {
      when(() => authRepository.currentUser).thenReturn(mockUser);
      when(
        () => contactsRepository.saveContact(
          ownerId: any(named: 'ownerId'),
          contact: any(named: 'contact'),
        ),
      ).thenAnswer((_) async {});

      final cubit = buildCubit();
      contactsStreamController.add([]);
      await Future<void>.delayed(Duration.zero);

      await cubit.toggleLike(mockMusician);
      expect(cubit.state.isLiked('musician-1'), true);

      await cubit.close();
    });

    test('toggleLike optimistically removes contact', () async {
      when(() => authRepository.currentUser).thenReturn(mockUser);
      when(
        () => contactsRepository.deleteContact(
          ownerId: any(named: 'ownerId'),
          contactId: any(named: 'contactId'),
        ),
      ).thenAnswer((_) async {});

      final cubit = buildCubit();
      contactsStreamController.add([mockMusician]);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.isLiked('musician-1'), true);

      await cubit.toggleLike(mockMusician);
      expect(cubit.state.isLiked('musician-1'), false);

      await cubit.close();
    });

    test('sortedContacts returns alphabetically sorted list', () async {
      when(() => authRepository.currentUser).thenReturn(mockUser);
      final cubit = buildCubit();
      contactsStreamController.add([mockMusician2, mockMusician]);
      await Future<void>.delayed(Duration.zero);

      final sorted = cubit.state.sortedContacts;
      expect(sorted[0].name, 'Jane Smith');
      expect(sorted[1].name, 'John Doe');

      await cubit.close();
    });
  });
}
