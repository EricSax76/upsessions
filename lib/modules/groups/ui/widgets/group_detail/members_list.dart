import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/constants/app_routes.dart';
import '../../../../../../core/widgets/loading_indicator.dart';
import '../../../cubits/group_members_cubit.dart';
import '../../../cubits/group_members_state.dart';
import 'member_avatar_tile.dart';

class MembersList extends StatelessWidget {
  const MembersList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupMembersCubit, GroupMembersState>(
      builder: (context, state) {
        if (state is GroupMembersLoading) {
          return const SizedBox(
            height: 100,
            child: Center(child: LoadingIndicator()),
          );
        }
        if (state is GroupMembersError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        if (state is GroupMembersLoaded) {
          if (state.members.isEmpty) {
            return const Center(child: Text('No hay miembros en este grupo.'));
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final crossAxisCount = width < 440 ? 3 : width < 760 ? 4 : 6;
              const horizontalSpacing = 12.0;
              final tileWidth =
                  (width - (horizontalSpacing * (crossAxisCount - 1))) /
                      crossAxisCount;

              return Wrap(
                alignment: WrapAlignment.center,
                spacing: horizontalSpacing,
                runSpacing: 18,
                children: state.members
                    .map(
                      (member) => SizedBox(
                        width: tileWidth,
                        child: MemberAvatarTile(
                          member: member,
                          onTap: () {
                            final musicianId = member.id.trim();
                            if (musicianId.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'No se pudo abrir el perfil del músico.')),
                              );
                              return;
                            }

                            context.push(
                              AppRoutes.musicianDetailPath(
                                musicianId: musicianId,
                                musicianName: member.name,
                              ),
                            );
                          },
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
