import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/studios_cubit.dart';
import '../../cubits/studios_state.dart';
import '../../models/studio_entity.dart';

class StudioProfilePage extends StatefulWidget {
  const StudioProfilePage({super.key});

  @override
  State<StudioProfilePage> createState() => _StudioProfilePageState();
}

class _StudioProfilePageState extends State<StudioProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _businessNameController;
  late TextEditingController _cifController;
  String? _studioId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _businessNameController = TextEditingController();
    _cifController = TextEditingController();

    final studio = context.read<StudiosCubit>().state.myStudio;
    if (studio != null) {
      _syncControllers(studio);
    }
  }

  void _syncControllers(StudioEntity studio) {
    if (_studioId == studio.id) return;
    _studioId = studio.id;
    _nameController.text = studio.name;
    _descriptionController.text = studio.description;
    _addressController.text = studio.address;
    _phoneController.text = studio.contactPhone;
    _emailController.text = studio.contactEmail;
    _businessNameController.text = studio.businessName;
    _cifController.text = studio.cif;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _businessNameController.dispose();
    _cifController.dispose();
    super.dispose();
  }

  void _save(StudioEntity currentStudio) {
    if (_formKey.currentState!.validate()) {
      final updatedStudio = currentStudio.copyWith(
        name: _nameController.text,
        description: _descriptionController.text,
        address: _addressController.text,
        contactPhone: _phoneController.text,
        contactEmail: _emailController.text,
        businessName: _businessNameController.text,
        cif: _cifController.text,
      );
      context.read<StudiosCubit>().updateMyStudio(updatedStudio);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StudiosCubit, StudiosState>(
      listenWhen: (previous, current) =>
          previous.myStudio?.id != current.myStudio?.id,
      listener: (context, state) {
        final studio = state.myStudio;
        if (studio != null) {
          _syncControllers(studio);
        }
      },
      child: BlocBuilder<StudiosCubit, StudiosState>(
        builder: (context, state) {
          final studio = state.myStudio;
          if (studio == null) {
            return const Scaffold(body: Center(child: Text('No studio found')));
          }

          return Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200.0,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (studio.bannerUrl != null &&
                            studio.bannerUrl!.isNotEmpty)
                          Image.network(studio.bannerUrl!, fit: BoxFit.cover)
                        else
                          Container(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            child: const Icon(
                              Icons.image,
                              size: 64,
                              color: Colors.black26,
                            ),
                          ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: FloatingActionButton.small(
                            heroTag: 'banner',
                            onPressed: () => context
                                .read<StudiosCubit>()
                                .uploadMyStudioBanner(studio.id),
                            child: const Icon(Icons.camera_alt),
                          ),
                        ),
                      ],
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(
                      0,
                    ), // Just to push content down if needed, or overlap
                    child: Container(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Avatar Section
                        Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundImage:
                                    studio.logoUrl != null &&
                                        studio.logoUrl!.isNotEmpty
                                    ? NetworkImage(studio.logoUrl!)
                                    : null,
                                child:
                                    studio.logoUrl == null ||
                                        studio.logoUrl!.isEmpty
                                    ? const Icon(Icons.store, size: 50)
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Theme.of(context).primaryColor,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.camera_alt,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    onPressed: () => context
                                        .read<StudiosCubit>()
                                        .uploadMyStudioLogo(studio.id),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Basic Info',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Studio Name',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) =>
                                    v?.isNotEmpty == true ? null : 'Required',
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _descriptionController,
                                decoration: const InputDecoration(
                                  labelText: 'Description',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 3,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Contact & Location',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _addressController,
                                decoration: const InputDecoration(
                                  labelText: 'Address',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Contact Email',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _phoneController,
                                decoration: const InputDecoration(
                                  labelText: 'Phone',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Business Details',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _businessNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Business Name',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _cifController,
                                decoration: const InputDecoration(
                                  labelText: 'CIF / Value ID',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: () => _save(studio),
                                  child: const Text('Save Changes'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
