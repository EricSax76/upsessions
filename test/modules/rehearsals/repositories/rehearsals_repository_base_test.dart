import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/modules/auth/models/user_entity.dart';
import 'package:upsessions/modules/auth/repositories/auth_repository.dart';
import 'package:upsessions/modules/rehearsals/repositories/rehearsals_repository_base.dart';

class _MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class _MockAuthRepository extends Mock implements AuthRepository {}

// ignore: subtype_of_sealed_class
class _MockMusiciansCollection extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

// ignore: subtype_of_sealed_class
class _MockMusicianDoc extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

// ignore: subtype_of_sealed_class
class _MockMusicianSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class _TestRehearsalsRepositoryBase extends RehearsalsRepositoryBase {
  _TestRehearsalsRepositoryBase({
    required super.firestore,
    required super.authRepository,
  });
}

void main() {
  late _MockFirebaseFirestore firestore;
  late _MockAuthRepository authRepository;
  late _TestRehearsalsRepositoryBase repository;

  UserEntity user(String id) {
    return UserEntity(
      id: id,
      email: '$id@test.com',
      displayName: id,
      createdAt: DateTime(2026, 1, 1),
    );
  }

  setUp(() {
    firestore = _MockFirebaseFirestore();
    authRepository = _MockAuthRepository();
    repository = _TestRehearsalsRepositoryBase(
      firestore: firestore,
      authRepository: authRepository,
    );
  });

  test('requireUid returns current user id when session exists', () {
    when(() => authRepository.currentUser).thenReturn(user('u1'));

    final uid = repository.requireUid();

    expect(uid, 'u1');
  });

  test('requireUid throws when there is no authenticated session', () {
    when(() => authRepository.currentUser).thenReturn(null);

    expect(
      () => repository.requireUid(),
      throwsA(
        isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Debes iniciar sesión.'),
        ),
      ),
    );
  });

  test(
    'requireMusicianUid returns uid when musician profile is complete',
    () async {
      final musicians = _MockMusiciansCollection();
      final musicianDoc = _MockMusicianDoc();
      final snapshot = _MockMusicianSnapshot();

      when(() => authRepository.currentUser).thenReturn(user('u2'));
      when(() => firestore.collection('musicians')).thenReturn(musicians);
      when(() => musicians.doc('u2')).thenReturn(musicianDoc);
      when(() => musicianDoc.get()).thenAnswer((_) async => snapshot);
      when(() => snapshot.exists).thenReturn(true);
      when(
        () => snapshot.data(),
      ).thenReturn({'name': 'Ana', 'instrument': 'Bajo'});

      final uid = await repository.requireMusicianUid();

      expect(uid, 'u2');
      verify(() => firestore.collection('musicians')).called(1);
      verify(() => musicians.doc('u2')).called(1);
      verify(() => musicianDoc.get()).called(1);
    },
  );

  test(
    'requireMusicianUid throws when profile is missing required fields',
    () async {
      final musicians = _MockMusiciansCollection();
      final musicianDoc = _MockMusicianDoc();
      final snapshot = _MockMusicianSnapshot();

      when(() => authRepository.currentUser).thenReturn(user('u3'));
      when(() => firestore.collection('musicians')).thenReturn(musicians);
      when(() => musicians.doc('u3')).thenReturn(musicianDoc);
      when(() => musicianDoc.get()).thenAnswer((_) async => snapshot);
      when(() => snapshot.exists).thenReturn(true);
      when(
        () => snapshot.data(),
      ).thenReturn({'name': '   ', 'instrument': 'Batería'});

      expect(
        repository.requireMusicianUid(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Debes completar tu perfil de músico antes de continuar.'),
          ),
        ),
      );
    },
  );
}
