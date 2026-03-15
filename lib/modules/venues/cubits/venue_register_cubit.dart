import 'package:bloc/bloc.dart';

import '../../auth/repositories/auth_repository.dart';
import '../../event_manager/models/event_manager_entity.dart';
import '../../event_manager/repositories/event_manager_repository.dart';
import '../ui/forms/venue_register_draft.dart';
import 'venue_register_state.dart';

class VenueRegisterCubit extends Cubit<VenueRegisterState> {
  VenueRegisterCubit({
    required AuthRepository authRepository,
    required EventManagerRepository managerRepository,
    VenueRegisterDraft? draft,
  }) : _authRepository = authRepository,
       _managerRepository = managerRepository,
       draft = draft ?? VenueRegisterDraft(),
       super(const VenueRegisterState());

  final AuthRepository _authRepository;
  final EventManagerRepository _managerRepository;
  final VenueRegisterDraft draft;

  void togglePasswordVisibility() {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  Future<void> register() async {
    if (state.status == VenueRegisterStatus.submitting) return;

    final email = draft.emailController.text.trim();
    final password = draft.passwordController.text;
    final venueName = draft.venueNameController.text.trim();
    final contactPhone = draft.contactPhoneController.text.trim();
    final city = draft.cityController.text.trim();
    final website = _trimToNull(draft.websiteController.text);

    emit(
      state.copyWith(
        status: VenueRegisterStatus.submitting,
        errorMessage: null,
      ),
    );

    try {
      final user = await _authRepository.register(
        email: email,
        password: password,
        displayName: venueName,
      );

      final manager = EventManagerEntity(
        id: user.id,
        ownerId: user.id,
        name: venueName,
        contactEmail: email,
        contactPhone: contactPhone,
        city: city,
        website: website,
        specialties: const ['venues'],
      );

      await _managerRepository.create(manager);
      emit(
        state.copyWith(status: VenueRegisterStatus.success, errorMessage: null),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: VenueRegisterStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void clearError() {
    if (state.errorMessage == null &&
        state.status != VenueRegisterStatus.failure) {
      return;
    }
    emit(
      state.copyWith(status: VenueRegisterStatus.initial, errorMessage: null),
    );
  }

  @override
  Future<void> close() {
    draft.dispose();
    return super.close();
  }

  String? _trimToNull(String raw) {
    final value = raw.trim();
    return value.isEmpty ? null : value;
  }
}
