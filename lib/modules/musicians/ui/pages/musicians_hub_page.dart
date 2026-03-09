import 'package:flutter/material.dart';

import 'musician_search_page.dart';

class MusiciansHubPage extends StatelessWidget {
  const MusiciansHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MusicianSearchPage(showAppBar: false);
  }
}
