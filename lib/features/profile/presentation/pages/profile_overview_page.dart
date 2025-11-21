import 'package:flutter/material.dart';

import '../../../../core/services/service_locator.dart';
import '../../data/profile_repository.dart';
import '../../domain/profile_entity.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats_row.dart';

class ProfileOverviewPage extends StatefulWidget {
  const ProfileOverviewPage({super.key});

  @override
  State<ProfileOverviewPage> createState() => _ProfileOverviewPageState();
}

  final ProfileRepository _repository = getIt();
  ProfileEntity? _profile;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final dto = await _repository.fetchProfile();
    setState(() => _profile = dto.toEntity());
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileHeader(profile: profile),
            const SizedBox(height: 16),
            Text(profile.bio),
            const SizedBox(height: 16),
            ProfileStatsRow(profile: profile),
          ],
        ),
      ),
    );
  }
}
