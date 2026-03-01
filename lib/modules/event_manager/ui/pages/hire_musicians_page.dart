import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/hiring/musician_request_dialog.dart';
import '../../cubits/musician_requests_cubit.dart';

class HireMusiciansPage extends StatelessWidget {
  const HireMusiciansPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder list of musicians for the demo.
    // In a real scenario, we would use a MusicianSearchCubit or MusiciansRepository.
    final mockMusicians = [
      {'id': 'm1', 'name': 'Carlos Rivera', 'instrument': 'Guitarra Eléctrica', 'city': 'Madrid'},
      {'id': 'm2', 'name': 'Laura Torres', 'instrument': 'Batería', 'city': 'Barcelona'},
      {'id': 'm3', 'name': 'Juan Pérez', 'instrument': 'Bajo', 'city': 'Sevilla'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Músicos'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
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
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: mockMusicians.length,
        itemBuilder: (context, index) {
          final mus = mockMusicians[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(mus['name']![0]),
              ),
              title: Text(mus['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${mus['instrument']} • ${mus['city']}'),
              trailing: FilledButton.tonal(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => BlocProvider.value(
                      value: context.read<MusicianRequestsCubit>(),
                      child: MusicianRequestDialog(
                        musicianId: mus['id']!,
                        musicianName: mus['name']!,
                      ),
                    ),
                  );
                },
                child: const Text('Invitar'),
              ),
            ),
          );
        },
      ),
    );
  }
}
