import 'package:flutter/material.dart';
import '../../models/studio_entity.dart';

class StudioProfileForm extends StatefulWidget {
  const StudioProfileForm({
    super.key,
    required this.studio,
    required this.onSave,
  });

  final StudioEntity studio;
  final ValueChanged<StudioEntity> onSave;

  @override
  State<StudioProfileForm> createState() => _StudioProfileFormState();
}

class _StudioProfileFormState extends State<StudioProfileForm> {
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

    _syncControllers(widget.studio);
  }

  @override
  void didUpdateWidget(covariant StudioProfileForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.studio != oldWidget.studio) {
      _syncControllers(widget.studio);
    }
  }

  void _syncControllers(StudioEntity studio) {
    if (_studioId == studio.id) return;
    _studioId = studio.id;
    
    // Only update if text is different to avoid cursor jumps if we were typing 
    // (though usually studio updates come from server save triggers)
    if (_nameController.text != studio.name) _nameController.text = studio.name;
    if (_descriptionController.text != studio.description) {
      _descriptionController.text = studio.description;
    }
    if (_addressController.text != studio.address) {
      _addressController.text = studio.address;
    }
    if (_phoneController.text != studio.contactPhone) {
      _phoneController.text = studio.contactPhone;
    }
    if (_emailController.text != studio.contactEmail) {
      _emailController.text = studio.contactEmail;
    }
    if (_businessNameController.text != studio.businessName) {
      _businessNameController.text = studio.businessName;
    }
    if (_cifController.text != studio.cif) _cifController.text = studio.cif;
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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final updatedStudio = widget.studio.copyWith(
        name: _nameController.text,
        description: _descriptionController.text,
        address: _addressController.text,
        contactPhone: _phoneController.text,
        contactEmail: _emailController.text,
        businessName: _businessNameController.text,
        cif: _cifController.text,
      );
      widget.onSave(updatedStudio);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
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
            validator: (v) => v?.isNotEmpty == true ? null : 'Required',
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
              onPressed: _submit,
              child: const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }
}
