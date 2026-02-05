import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../auth/repositories/auth_repository.dart';
import 'package:upsessions/core/locator/locator.dart';
import '../../cubits/studios_cubit.dart';
import '../../cubits/studios_state.dart';
import '../../models/studio_entity.dart';

class CreateStudioPage extends StatefulWidget {
  const CreateStudioPage({super.key});

  @override
  State<CreateStudioPage> createState() => _CreateStudioPageState();
}

class _CreateStudioPageState extends State<CreateStudioPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _cifController = TextEditingController();
  final _businessNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Studio')),
      body: BlocProvider(
        create: (context) => StudiosCubit(),
        child: BlocConsumer<StudiosCubit, StudiosState>(
          listener: (context, state) {
            if (state.status == StudiosStatus.success) {
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Studio created successfully!')),
              );
              // Navigate to dashboard or previous screen
              context.pop(); 
            }
          },
          builder: (context, state) {
            if (state.status == StudiosStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Studio Name'),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _businessNameController,
                      decoration: const InputDecoration(labelText: 'Business Name (Razón Social)'),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cifController,
                      decoration: const InputDecoration(labelText: 'CIF'),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Address'),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Contact Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Contact Phone'),
                      keyboardType: TextInputType.phone,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          final authRepo = locate<AuthRepository>();
                          final currentUser = authRepo.currentUser;
                          
                          // Mocking user ID if not logged in for development
                          final ownerId = currentUser?.id ?? 'mock_user_id';

                          final studio = StudioEntity(
                            id: const Uuid().v4(),
                            ownerId: ownerId,
                            name: _nameController.text,
                            businessName: _businessNameController.text,
                            cif: _cifController.text,
                            description: _descriptionController.text,
                            address: _addressController.text,
                            contactEmail: _emailController.text,
                            contactPhone: _phoneController.text,
                          );

                          context.read<StudiosCubit>().createStudio(studio);
                          // In a real app, this would also update the UserEntity to have a 'provider' role or link
                        }
                      },
                      child: const Text('Create Studio'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
