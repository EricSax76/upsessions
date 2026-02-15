import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../musicians/models/musician_entity.dart';
import '../../../../core/services/dialog_service.dart';
import '../../../../core/locator/locator.dart';
import '../../../groups/repositories/groups_repository.dart';
import '../../cubits/invite_musician_cubit.dart';
import '../../cubits/invite_musician_state.dart';
import '../../../musicians/repositories/musicians_repository.dart';
import '../widgets/invite_musician_dialog_widgets.dart';

class InviteMusicianDialog extends StatelessWidget {
  const InviteMusicianDialog({
    super.key,
    required this.groupId,
  });

  final String groupId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InviteMusicianCubit(
        groupId: groupId,
        musiciansRepository: locate<MusiciansRepository>(),
        groupsRepository: locate<GroupsRepository>(),
      ),
      child: const _InviteMusicianDialogBody(),
    );
  }
}

class _InviteMusicianDialogBody extends StatefulWidget {
  const _InviteMusicianDialogBody();

  @override
  State<_InviteMusicianDialogBody> createState() => _InviteMusicianDialogBodyState();
}

class _InviteMusicianDialogBodyState extends State<_InviteMusicianDialogBody> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InviteMusicianCubit, InviteMusicianState>(
      builder: (context, state) {
        return InviteMusicianDialogView(
          searchController: _searchController,
          state: state,
          onQueryChanged: (query) =>
              context.read<InviteMusicianCubit>().onQueryChanged(query),
          onInviteTap: (target) => _handleInviteTap(context, target),
        );
      },
    );
  }

  Future<void> _handleInviteTap(BuildContext context, MusicianEntity target) async {
    try {
      final link = await context
          .read<InviteMusicianCubit>()
          .invite(target.ownerId);

      if (!context.mounted) return;

      await showDialog<void>(
        context: context,
        builder: (context) => InviteCreatedDialog(link: link, target: target),
      );

      if (!context.mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      if (!context.mounted) return;
      DialogService.showError(
        context,
        'No se pudo crear la invitación: $error',
      );
    }
  }
}
