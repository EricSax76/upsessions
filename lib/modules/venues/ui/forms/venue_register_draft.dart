import 'package:flutter/material.dart';

class VenueRegisterDraft {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final venueNameController = TextEditingController();
  final contactPhoneController = TextEditingController();
  final cityController = TextEditingController();
  final websiteController = TextEditingController();

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    venueNameController.dispose();
    contactPhoneController.dispose();
    cityController.dispose();
    websiteController.dispose();
  }
}
