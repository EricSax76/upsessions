import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/hiring/musician_request_dialog.dart';
import '../../cubits/musician_requests_cubit.dart';
import '../../cubits/hire_musicians_cubit.dart';
import '../../cubits/hire_musicians_state.dart';

class HireMusiciansPage extends StatefulWidget {
  const HireMusiciansPage({super.key});

  @override
  State<HireMusiciansPage> createState() => _HireMusiciansPageState();
}

class _HireMusiciansPageState extends State<HireMusiciansPage> {
  @override
  void initState() {
    super.initState();
    context.read<HireMusiciansCubit>().loadMusicians();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Músicos'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => context.read<HireMusiciansCubit>().search(value),
              decoration: InputDecoration(
                hintText: 'Buscar por instrumento, ciudad...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<HireMusiciansCubit, HireMusiciansState>(
        builder: (context, state) {
          if (state.isLoading && state.musicians.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null && state.musicians.isEmpty) {
            return Center(child: Text('Error: ${state.error}'));
          }
          if (state.musicians.isEmpty) {
            return const Center(child: Text('No se encontraron músicos disponibles.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: state.musicians.length,
            itemBuilder: (context, index) {
              final mus = state.musicians[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  isThreeLine: true,
                  leading: CircleAvatar(
                    backgroundImage: mus.photoUrl != null && mus.photoUrl!.isNotEmpty
                        ? NetworkImage(mus.photoUrl!)
                        : null,
                    child: mus.photoUrl == null || mus.photoUrl!.isEmpty
                        ? Text(mus.name.isNotEmpty ? mus.name[0].toUpperCase() : '?')
                        : null,
                  ),
                  title: Text(mus.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    '${mus.instrument} • ${mus.city}\nEstilos: ${mus.styles.join(", ")}'
                  ),
                  trailing: FilledButton.tonal(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => BlocProvider.value(
                          value: context.read<MusicianRequestsCubit>(),
                          child: MusicianRequestDialog(
                            musicianId: mus.id,
                            musicianName: mus.name,
                          ),
                        ),
                      );
                    },
                    child: const Text('Invitar'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
