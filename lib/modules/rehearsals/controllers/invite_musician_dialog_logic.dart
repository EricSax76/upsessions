part of 'invite_musician_dialog.dart';

class InviteMusicianDialogController extends ChangeNotifier {
  InviteMusicianDialogController({
    required GroupRehearsalsController controller,
    required String groupId,
  }) : _controller = controller,
       _groupId = groupId;

  final GroupRehearsalsController _controller;
  final String _groupId;

  final TextEditingController searchController = TextEditingController();
  InviteMusicianDialogState _state =
      const InviteMusicianDialogState.initial();
  int _searchToken = 0;
  bool _isDisposed = false;

  InviteMusicianDialogState get state => _state;

  @override
  void dispose() {
    _isDisposed = true;
    searchController.dispose();
    super.dispose();
  }

  Future<void> onQueryChanged(String value) async {
    final trimmed = value.trim();
    final token = ++_searchToken;

    if (trimmed.isEmpty) {
      _updateState(
        _state.copyWith(
          query: '',
          isLoading: false,
          results: const [],
        ),
      );
      return;
    }

    _updateState(
      _state.copyWith(
        query: trimmed,
        isLoading: true,
        results: const [],
      ),
    );

    try {
      final results = await _controller.searchInviteCandidates(query: trimmed);
      if (_isDisposed || token != _searchToken) return;
      _updateState(_state.copyWith(isLoading: false, results: results));
    } catch (_) {
      if (_isDisposed || token != _searchToken) return;
      _updateState(_state.copyWith(isLoading: false, results: const []));
    }
  }

  Future<InviteLinkData> createInvite(MusicianEntity target) async {
    final inviteId = await _controller.createInvite(
      groupId: _groupId,
      targetUid: target.ownerId,
    );
    return InviteLinkData(groupId: _groupId, inviteId: inviteId);
  }

  void _updateState(InviteMusicianDialogState newState) {
    _state = newState;
    if (!_isDisposed) {
      notifyListeners();
    }
  }
}
