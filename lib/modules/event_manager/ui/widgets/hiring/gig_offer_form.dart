import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/widgets/app_card.dart';
import '../../../models/gig_offer_entity.dart';
import '../../../cubits/gig_offer_form_cubit.dart';
import '../../../cubits/gig_offer_form_state.dart';
import '../../../cubits/event_manager_auth_cubit.dart';

class GigOfferForm extends StatefulWidget {
  const GigOfferForm({super.key});

  @override
  State<GigOfferForm> createState() => _GigOfferFormState();
}

class _GigOfferFormState extends State<GigOfferForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _budgetController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _saveOffer() {
    if (_formKey.currentState!.validate()) {
      final managerId = context.read<EventManagerAuthCubit>().state.manager?.id ?? '';
      final offer = GigOfferEntity(
        id: '',
        managerId: managerId,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        instrumentRequirements: const ['Batería', 'Bajo'], // Mock for now
        date: DateTime.now().add(const Duration(days: 14)),
        time: '21:00',
        location: _locationController.text.trim(),
        budget: _budgetController.text.trim(),
        status: GigOfferStatus.open,
        applicants: const [],
        createdAt: DateTime.now(),
      );

      context.read<GigOfferFormCubit>().saveOffer(offer);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GigOfferFormCubit, GigOfferFormState>(
      listenWhen: (prev, curr) => prev.success != curr.success,
      listener: (context, state) {
        if (state.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Oferta publicada exitosamente')),
          );
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Nueva Oferta (Casting)')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: AppCard(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Título de la oferta'),
                    validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: 'Descripción / Requisitos'),
                    maxLines: 3,
                    validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: 'Lugar / Ciudad'),
                    validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _budgetController,
                    decoration: const InputDecoration(labelText: 'Presupuesto (Opcional)'),
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: _saveOffer,
                    child: const Text('Publicar Oferta'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
