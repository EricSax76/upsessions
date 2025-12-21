import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../modules/auth/data/auth_repository.dart';
import '../../../modules/auth/domain/user_entity.dart';
import '../data/contacts_repository.dart';
import '../domain/liked_musician.dart';

class LikedMusiciansController extends ChangeNotifier {
  LikedMusiciansController({
    ContactsRepository? contactsRepository,
    AuthRepository? authRepository,
  }) : _contactsRepository = contactsRepository ?? ContactsRepository(),
       _authRepository = authRepository ?? AuthRepository() {
    _authSubscription = _authRepository.authStateChanges.listen(_handleAuth);
    _handleAuth(_authRepository.currentUser);
  }

  final ContactsRepository _contactsRepository;
  final AuthRepository _authRepository;

  final Map<String, LikedMusician> _contacts = {};
  StreamSubscription<List<LikedMusician>>? _contactsSubscription;
  StreamSubscription<UserEntity?>? _authSubscription;
  String? _currentOwnerId;

  List<LikedMusician> get contacts {
    final items = _contacts.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return List.unmodifiable(items);
  }

  bool isLiked(String id) => _contacts.containsKey(id);

  int get total => _contacts.length;

  Future<void> toggleLike(LikedMusician musician) async {
    final ownerId = _currentOwnerId;
    if (ownerId == null) {
      debugPrint(
        '[LikedMusiciansController] toggleLike skipped because there is no authenticated user.',
      );
      return;
    }

    if (isLiked(musician.id)) {
      final previous = _contacts.remove(musician.id);
      notifyListeners();
      try {
        await _contactsRepository.deleteContact(
          ownerId: ownerId,
          contactId: musician.id,
        );
      } catch (error, stackTrace) {
        debugPrint(
          '[LikedMusiciansController] Failed to delete contact ${musician.id}: $error',
        );
        if (kDebugMode) {
          debugPrintStack(stackTrace: stackTrace);
        }
        if (previous != null) {
          _contacts[musician.id] = previous;
          notifyListeners();
        }
      }
      return;
    }

    _contacts[musician.id] = musician;
    notifyListeners();
    try {
      await _contactsRepository.saveContact(
        ownerId: ownerId,
        contact: musician,
      );
    } catch (error, stackTrace) {
      debugPrint(
        '[LikedMusiciansController] Failed to save contact ${musician.id}: $error',
      );
      if (kDebugMode) {
        debugPrintStack(stackTrace: stackTrace);
      }
      _contacts.remove(musician.id);
      notifyListeners();
    }
  }

  Future<void> remove(String musicianId) async {
    final ownerId = _currentOwnerId;
    if (ownerId == null) {
      return;
    }
    final removed = _contacts.remove(musicianId);
    if (removed == null) {
      return;
    }
    notifyListeners();
    try {
      await _contactsRepository.deleteContact(
        ownerId: ownerId,
        contactId: musicianId,
      );
    } catch (error, stackTrace) {
      debugPrint(
        '[LikedMusiciansController] Failed to remove contact $musicianId: $error',
      );
      if (kDebugMode) {
        debugPrintStack(stackTrace: stackTrace);
      }
      _contacts[musicianId] = removed;
      notifyListeners();
    }
  }

  void sync(LikedMusician musician) {
    if (!isLiked(musician.id)) {
      return;
    }
    _contacts[musician.id] = musician;
    notifyListeners();
    final ownerId = _currentOwnerId;
    if (ownerId == null) {
      return;
    }
    unawaited(
      _contactsRepository.saveContact(ownerId: ownerId, contact: musician),
    );
  }

  void _handleAuth(UserEntity? user) {
    _currentOwnerId = user?.id;
    _contactsSubscription?.cancel();
    _contactsSubscription = null;
    _contacts.clear();
    notifyListeners();

    if (user == null) {
      return;
    }

    _contactsSubscription = _contactsRepository
        .watchContacts(user.id)
        .listen(
          _handleContactsUpdate,
          onError: (error, stackTrace) {
            debugPrint(
              '[LikedMusiciansController] Contacts stream error: $error',
            );
            if (kDebugMode) {
              debugPrintStack(stackTrace: stackTrace);
            }
          },
        );
  }

  void _handleContactsUpdate(List<LikedMusician> items) {
    _contacts
      ..clear()
      ..addEntries(items.map((item) => MapEntry(item.id, item)));
    notifyListeners();
  }

  @override
  void dispose() {
    _contactsSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}
