import 'package:flutter/material.dart';

import '../../../../home/ui/pages/user_shell_page.dart';
import '../widgets/group_detail/group_page_view.dart';
import '../../controllers/group_page_controller.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key, required this.groupId, this.controller});

  final String groupId;
  final GroupPageController? controller;

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  late final GroupPageController _controller =
      widget.controller ?? GroupPageController();

  @override
  Widget build(BuildContext context) {
    return UserShellPage(
      child: DefaultTabController(
        length: 2,
        child: GroupPageView(groupId: widget.groupId, controller: _controller),
      ),
    );
  }
}
