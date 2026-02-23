import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/core/locator/locator.dart';
import '../../../../core/ui/shell/auth_shell.dart';

import '../../../auth/cubits/auth_cubit.dart';

import '../../cubits/my_studio_cubit.dart';
import '../../cubits/studios_state.dart';
import '../../repositories/studios_repository.dart';
import 'studio_register_form_controller.dart';
import 'studio_register_stepper.dart';
import 'studio_registration_coordinator.dart';

enum _RegistrationFlow { idle, registeringAccount, creatingStudio }

class StudioRegisterPage extends StatefulWidget {
  const StudioRegisterPage({super.key});

  @override
  State<StudioRegisterPage> createState() => _StudioRegisterPageState();
}

class _StudioRegisterPageState extends State<StudioRegisterPage> {
  final _form = StudioRegisterFormController();
  final StudioRegistrationCoordinator _registrationCoordinator =
      StudioRegistrationCoordinator();

  int _currentStep = 0;
  _RegistrationFlow _flow = _RegistrationFlow.idle;

  bool get _isSubmitting => _flow != _RegistrationFlow.idle;

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MyStudioCubit(repository: locate<StudiosRepository>()),
      child: MultiBlocListener(
        listeners: [
          BlocListener<AuthCubit, AuthState>(listener: _onAuthStateChanged),
          BlocListener<MyStudioCubit, StudiosState>(
            listener: _onStudiosStateChanged,
          ),
        ],
        child: AuthShell(
          showAppBar: true,
          title: 'Registro de Estudio',
          onBackPressed: () => context.pop(),
          child: StudioRegisterStepper(
            currentStep: _currentStep,
            isSubmitting: _isSubmitting,
            form: _form,
            onStepContinue: _onStepContinue,
            onStepCancel: _onStepCancel,
          ),
        ),
      ),
    );
  }

  void _onAuthStateChanged(BuildContext context, AuthState authState) {
    if (_flow != _RegistrationFlow.registeringAccount) {
      return;
    }
    if (authState.errorMessage != null) {
      _stopFlowWithError(authState.errorMessage!);
      return;
    }
    if (authState.status == AuthStatus.authenticated &&
        authState.user != null) {
      setState(() => _flow = _RegistrationFlow.creatingStudio);
      _registrationCoordinator.createStudio(
        myStudioCubit: context.read<MyStudioCubit>(),
        ownerId: authState.user!.id,
        draft: _form.buildDraft(),
      );
    }
  }

  void _onStudiosStateChanged(BuildContext context, StudiosState studioState) {
    if (_flow != _RegistrationFlow.creatingStudio) {
      return;
    }
    if (studioState.status == StudiosStatus.success) {
      setState(() => _flow = _RegistrationFlow.idle);
      context.go(AppRoutes.studiosDashboard);
      return;
    }
    if (studioState.status == StudiosStatus.failure) {
      _stopFlowWithError(
        studioState.errorMessage ?? 'No se pudo crear el estudio.',
      );
    }
  }

  void _onStepContinue() {
    if (_isSubmitting) {
      return;
    }
    if (_currentStep == 0) {
      if (_form.validateAccountStep()) {
        setState(() => _currentStep = 1);
      }
      return;
    }
    if (_form.validateStudioStep()) {
      _submitRegistration();
    }
  }

  void _onStepCancel() {
    if (_isSubmitting) {
      return;
    }
    if (_currentStep > 0) {
      setState(() => _currentStep = 0);
      return;
    }
    context.pop();
  }

  void _submitRegistration() {
    final authState = context.read<AuthCubit>().state;
    if (authState.status == AuthStatus.authenticated &&
        authState.user != null) {
      setState(() => _flow = _RegistrationFlow.creatingStudio);
      _registrationCoordinator.createStudio(
        myStudioCubit: context.read<MyStudioCubit>(),
        ownerId: authState.user!.id,
        draft: _form.buildDraft(),
      );
      return;
    }

    setState(() => _flow = _RegistrationFlow.registeringAccount);
    _registrationCoordinator.submitRegistration(
      authCubit: context.read<AuthCubit>(),
      draft: _form.buildDraft(),
    );
  }

  void _stopFlowWithError(String message) {
    if (!mounted) {
      return;
    }
    setState(() => _flow = _RegistrationFlow.idle);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
