import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../cubits/gig_offers_cubit.dart';
import '../../cubits/gig_offers_state.dart';
import '../../models/gig_offer_entity.dart';

class GigOffersPage extends StatefulWidget {
  const GigOffersPage({super.key});

  @override
  State<GigOffersPage> createState() => _GigOffersPageState();
}

class _GigOffersPageState extends State<GigOffersPage> {
  @override
  void initState() {
    super.initState();
    context.read<GigOffersCubit>().loadOffers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.eventManagerGigOfferForm),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Oferta'),
      ),
      body: BlocBuilder<GigOffersCubit, GigOffersState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }

          final offers = state.offers;

          if (offers.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.work_outline, size: 64, color: Theme.of(context).colorScheme.outline),
                  const SizedBox(height: 16),
                  Text('No tienes ofertas publicadas.', style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: offers.length + 1,
            separatorBuilder: (context, index) {
              if (index == 0) return const SizedBox.shrink();
              return const Divider();
            },
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Text(
                    'Mis Ofertas (Casting)',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                );
              }
              final offer = offers[index - 1];
              return ListTile(
                title: Text(offer.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${offer.location} • ${_formatDate(offer.date)}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: offer.status == GigOfferStatus.open
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    offer.status.name.toUpperCase(),
                    style: TextStyle(
                      color: offer.status == GigOfferStatus.open ? Colors.green[800] : Colors.red[800],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onTap: () {},
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Por definir';
    return '${date.day}/${date.month}/${date.year}';
  }
}
