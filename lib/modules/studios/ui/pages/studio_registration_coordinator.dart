import 'package:uuid/uuid.dart';

import '../../../auth/cubits/auth_cubit.dart';
import '../../cubits/my_studio_cubit.dart';
import '../../models/studio_entity.dart';

typedef StudioIdGenerator = String Function();

class StudioRegistrationDraft {
  const StudioRegistrationDraft({
    required this.email,
    required this.password,
    required this.name,
    required this.businessName,
    required this.cif,
    required this.description,
    required this.address,
    required this.phone,
  });

  final String email;
  final String password;
  final String name;
  final String businessName;
  final String cif;
  final String description;
  final String address;
  final String phone;
}

class StudioRegistrationCoordinator {
  StudioRegistrationCoordinator({StudioIdGenerator? idGenerator})
    : _idGenerator = idGenerator ?? (() => const Uuid().v4());

  final StudioIdGenerator _idGenerator;

  void submitRegistration({
    required AuthCubit authCubit,
    required StudioRegistrationDraft draft,
  }) {
    authCubit.register(
      email: draft.email.trim(),
      password: draft.password,
      displayName: draft.name.trim(),
    );
  }

  void createStudio({
    required MyStudioCubit myStudioCubit,
    required String ownerId,
    required StudioRegistrationDraft draft,
  }) {
    myStudioCubit.createStudio(
      StudioEntity(
        id: _idGenerator(),
        ownerId: ownerId,
        name: draft.name.trim(),
        businessName: draft.businessName.trim(),
        cif: draft.cif.trim(),
        description: draft.description.trim(),
        address: draft.address.trim(),
        contactEmail: draft.email.trim(),
        contactPhone: draft.phone.trim(),
      ),
    );
  }
}
