import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upsessions/l10n/app_localizations.dart';
import '../../cubits/my_studio_cubit.dart';
import '../../cubits/studios_state.dart';
import '../../cubits/studios_status.dart';
import '../../models/room_entity.dart';
import '../../repositories/studios_repository.dart';
import '../../../../core/locator/locator.dart';
import 'widgets/room_form_body.dart';

/// Orquestador de la pantalla de creación / edición de sala.
///
/// Responsabilidad única: provisión del [MyStudioCubit] y reacción
/// a los cambios de estado globales (navegación, snackbar de error).
class EditRoomPage extends StatefulWidget {
  const EditRoomPage({super.key, required this.studioId, this.room});

  final String studioId;
  final RoomEntity? room;

  @override
  State<EditRoomPage> createState() => _EditRoomPageState();
}

class _EditRoomPageState extends State<EditRoomPage> {
  late final MyStudioCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = MyStudioCubit(repository: locate<StudiosRepository>());
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<MyStudioCubit, StudiosState>(
        listener: (context, state) {
          final loc = AppLocalizations.of(context);
          if (state.status == StudiosStatus.success) {
            Navigator.of(context).pop();
          } else if (state.status == StudiosStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? loc.roomFormSaveError),
              ),
            );
          }
        },
        child: RoomFormBody(studioId: widget.studioId, room: widget.room),
      ),
    );
  }
}
