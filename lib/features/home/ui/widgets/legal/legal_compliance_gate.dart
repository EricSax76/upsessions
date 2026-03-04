import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/core/locator/locator.dart';
import 'package:upsessions/core/services/cloud_functions_service.dart';
import 'package:upsessions/features/legal/legal_policy_registry.dart';
import 'package:upsessions/modules/auth/cubits/auth_cubit.dart';

class LegalComplianceGate extends StatefulWidget {
  const LegalComplianceGate({super.key, required this.child});

  final Widget child;

  @override
  State<LegalComplianceGate> createState() => _LegalComplianceGateState();
}

class _LegalComplianceGateState extends State<LegalComplianceGate> {
  bool _isSubmitting = false;
  bool _acceptTermsChecked = false;
  bool _acceptPrivacyChecked = false;
  bool _marketingOptIn = false;
  String? _errorMessage;

  String get _source {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      default:
        return 'api';
    }
  }

  Future<void> _acceptPending({
    required bool needsTerms,
    required bool needsPrivacy,
  }) async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final cloudFunctionsService = locate<CloudFunctionsService>();
    try {
      await cloudFunctionsService.acceptLegalBundle(
        termsVersion: LegalPolicyRegistry.termsVersion,
        privacyVersion: LegalPolicyRegistry.privacyVersion,
        marketingVersion: LegalPolicyRegistry.marketingVersion,
        acceptTerms: needsTerms,
        acceptPrivacy: needsPrivacy,
        marketingOptIn: _marketingOptIn,
        termsPolicyHash: LegalPolicyRegistry.termsPolicyHash,
        privacyPolicyHash: LegalPolicyRegistry.privacyPolicyHash,
        marketingPolicyHash: LegalPolicyRegistry.marketingPolicyHash,
        source: _source,
      );
    } on FirebaseFunctionsException catch (error) {
      setState(() {
        _errorMessage =
            error.message ?? 'No pudimos registrar tu consentimiento legal.';
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'No pudimos registrar tu consentimiento legal.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final uid = authState.user?.id;
    if (uid == null || uid.isEmpty) {
      return widget.child;
    }
    if (Firebase.apps.isEmpty) {
      return widget.child;
    }

    final userDocStream = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: userDocStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data?.data();
        final acceptedTermsAt = data?['acceptedTermsAt'];
        final acceptedPrivacyAt = data?['acceptedPrivacyAt'];
        final needsTerms = acceptedTermsAt == null;
        final needsPrivacy = acceptedPrivacyAt == null;
        final canSubmit =
            (!needsTerms || _acceptTermsChecked) &&
            (!needsPrivacy || _acceptPrivacyChecked);

        if (!needsTerms && !needsPrivacy) {
          return widget.child;
        }

        final colorScheme = Theme.of(context).colorScheme;
        return Container(
          color: colorScheme.surfaceContainerLow,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.gavel_outlined, color: colorScheme.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Aceptación legal pendiente',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Para continuar, debes aceptar los términos y la política de privacidad.',
                    ),
                    const SizedBox(height: 16),
                    if (needsTerms)
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _acceptTermsChecked,
                        title: const Text('Acepto los términos y condiciones'),
                        subtitle: TextButton(
                          onPressed: () => context.push(AppRoutes.legalTerms),
                          child: const Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Leer términos'),
                          ),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: _isSubmitting
                            ? null
                            : (value) {
                                setState(() {
                                  _acceptTermsChecked = value ?? false;
                                });
                              },
                      ),
                    if (needsPrivacy)
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _acceptPrivacyChecked,
                        title: const Text('Acepto la política de privacidad'),
                        subtitle: TextButton(
                          onPressed: () => context.push(AppRoutes.legalPrivacy),
                          child: const Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Leer política de privacidad'),
                          ),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: _isSubmitting
                            ? null
                            : (value) {
                                setState(() {
                                  _acceptPrivacyChecked = value ?? false;
                                });
                              },
                      ),
                    const Text(
                      'Puedes consultar también nuestra política de cookies.',
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () => context.push(AppRoutes.legalCookies),
                        child: const Text('Leer política de cookies'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _marketingOptIn,
                      title: const Text(
                        'Quiero recibir comunicaciones comerciales',
                      ),
                      subtitle: const Text(
                        'Opcional. Puedes cambiarlo después.',
                      ),
                      onChanged: _isSubmitting
                          ? null
                          : (value) {
                              setState(() {
                                _marketingOptIn = value;
                              });
                            },
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ],
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final compact = constraints.maxWidth < 360;
                        final acceptButton = ElevatedButton(
                          onPressed: _isSubmitting || !canSubmit
                              ? null
                              : () => _acceptPending(
                                  needsTerms: needsTerms,
                                  needsPrivacy: needsPrivacy,
                                ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Aceptar y continuar'),
                        );
                        final signOutButton = OutlinedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () => context.read<AuthCubit>().signOut(),
                          child: const Text('Cerrar sesión'),
                        );

                        if (compact) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              acceptButton,
                              const SizedBox(height: 8),
                              signOutButton,
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(child: acceptButton),
                            const SizedBox(width: 10),
                            signOutButton,
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
