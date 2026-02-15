import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/locator/locator.dart';
import '../../../../home/ui/pages/user_shell_page.dart';
import '../../cubits/group_cubit.dart';
import '../../repositories/groups_repository.dart';
import '../widgets/group_detail/group_page_view.dart';

class GroupPage extends StatelessWidget {
  const GroupPage({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    return UserShellPage(
      child: BlocProvider(
        create:
            (context) => GroupCubit(
              groupId: groupId,
              groupsRepository: locate<GroupsRepository>(),
              imagePicker: ImagePicker(),
            ),
        child: DefaultTabController(
          length: 2,
          child: GroupPageView(groupId: groupId),
        ),
      ),
    );
  }
}
