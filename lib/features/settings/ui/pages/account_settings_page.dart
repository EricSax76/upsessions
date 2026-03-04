import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/core/locator/locator.dart';
import 'package:upsessions/core/services/cloud_functions_service.dart';
import 'package:upsessions/core/services/cookie_consent_service.dart';
import 'package:upsessions/core/widgets/app_card.dart';
import 'package:upsessions/features/legal/legal_policy_registry.dart';
import 'package:upsessions/modules/auth/cubits/auth_cubit.dart';
import 'package:upsessions/modules/groups/models/group_membership_entity.dart';
import 'package:upsessions/modules/groups/repositories/groups_repository.dart';
import 'package:upsessions/modules/profile/models/account_settings_card.dart';

import '../../cubits/account_preferences_cubit.dart';

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AccountPreferencesCubit(),
      child: const _AccountSettingsPageView(),
    );
  }
}

class _AccountSettingsPageView extends StatefulWidget {
  const _AccountSettingsPageView();

  @override
  State<_AccountSettingsPageView> createState() => _AccountSettingsPageViewState();
}

class _AccountSettingsPageViewState extends State<_AccountSettingsPageView> {
  late final GroupsRepository _groupsRepository;
  late final Stream<List<GroupMembershipEntity>> _myGroupsStream;
  late final CloudFunctionsService _cloudFunctionsService;
  late final CookieConsentService _cookieConsentService;
  Stream<DocumentSnapshot<Map<String, dynamic>>>? _userComplianceStream;
  final Set<String> _deletingGroupIds = <String>{};
  bool _isUpdatingMarketingConsent = false;
  bool _isRequestingDataExport = false;
  bool _isRequestingAccountDeletion = false;

  @override
  void initState() {
    super.initState();
    _groupsRepository = context.read<GroupsRepository>();
    _myGroupsStream = _groupsRepository.watchMyGroups();
    _cloudFunctionsService = locate<CloudFunctionsService>();
    _cookieConsentService = locate<CookieConsentService>();
    _cookieConsentService.addListener(_onCookieConsentChanged);

    final uid = context.read<AuthCubit>().state.user?.id;
    if (uid != null && uid.isNotEmpty && Firebase.apps.isNotEmpty) {
      _userComplianceStream = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots();
    }
  }

  @override
  void dispose() {
    _cookieConsentService.removeListener(_onCookieConsentChanged);
    super.dispose();
  }

  void _onCookieConsentChanged() {
    if (!mounted) return;
    setState(() {});
  }

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

  Future<void> _updateCookieConsent({
    bool? analytics,
    bool? preferences,
    bool? marketing,
  }) async {
    final current = _cookieConsentService.preferences;
    await _cookieConsentService.saveSelection(
      analytics: analytics ?? current.analytics,
      preferences: preferences ?? current.preferences,
      marketing: marketing ?? current.marketing,
    );
  }

  Future<void> _updateMarketingConsent(bool nextValue) async {
    if (_isUpdatingMarketingConsent) return;
    setState(() {
      _isUpdatingMarketingConsent = true;
    });

    try {
      await _cloudFunctionsService.acceptLegalDocs(
        policyType: 'marketing',
        version: LegalPolicyRegistry.marketingVersion,
        policyHash: LegalPolicyRegistry.marketingPolicyHash,
        action: nextValue ? 'accept' : 'revoke',
        source: _source,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nextValue
                ? 'Consentimiento comercial activado.'
                : 'Consentimiento comercial retirado.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No pudimos actualizar tu consentimiento: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingMarketingConsent = false;
        });
      }
    }
  }

  Future<void> _requestDataExport() async {
    if (_isRequestingDataExport) return;
    setState(() {
      _isRequestingDataExport = true;
    });
    try {
      final requestId = await _cloudFunctionsService.requestDataExport(
        source: _source,
        reason: 'Solicitud iniciada por el usuario desde ajustes.',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            requestId.isEmpty
                ? 'Solicitud de exportación registrada.'
                : 'Solicitud de exportación registrada: $requestId',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No pudimos registrar la solicitud: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRequestingDataExport = false;
        });
      }
    }
  }

  Future<void> _requestAccountDeletion() async {
    if (_isRequestingAccountDeletion) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Solicitar eliminación de cuenta'),
        content: const Text(
          'Registraremos una solicitud formal de eliminación. '
          'Nuestro equipo revisará la petición y te contactará si necesita validaciones adicionales.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Solicitar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isRequestingAccountDeletion = true;
    });
    try {
      final requestId = await _cloudFunctionsService.requestAccountDeletion(
        source: _source,
        reason: 'Solicitud iniciada por el usuario desde ajustes.',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            requestId.isEmpty
                ? 'Solicitud de eliminación registrada.'
                : 'Solicitud de eliminación registrada: $requestId',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No pudimos registrar la solicitud: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRequestingAccountDeletion = false;
        });
      }
    }
  }

  Future<void> _contactDpo() async {
    final uri = Uri(
      scheme: 'mailto',
      path: LegalPolicyRegistry.dpoEmail,
      queryParameters: const {
        'subject': 'Solicitud de privacidad - UPSESSIONS',
      },
    );
    final launched = await launchUrl(uri);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No pudimos abrir tu cliente de correo.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(
      context,
    ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Ajustes de la cuenta', style: titleStyle),
            const SizedBox(height: 8),
            Text(
              'Configura tus preferencias de seguridad y comunicaciones.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Expanded(
              child:
                  BlocBuilder<AccountPreferencesCubit, AccountPreferencesState>(
                    builder: (context, state) {
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AccountSettingsCard(
                              twoFactor: state.twoFactorEnabled,
                              newsletter: state.newsletterEnabled,
                              onTwoFactorChanged: context
                                  .read<AccountPreferencesCubit>()
                                  .toggleTwoFactor,
                              onNewsletterChanged: context
                                  .read<AccountPreferencesCubit>()
                                  .toggleNewsletter,
                            ),
                            const SizedBox(height: 24),
                            const _CenteredSectionTitle(
                              text: 'Privacidad y consentimiento',
                            ),
                            const SizedBox(height: 12),
                            _buildPrivacyCenter(context),
                            const SizedBox(height: 24),
                            const _CenteredSectionTitle(text: 'Acciones'),
                            const SizedBox(height: 12),
                            StreamBuilder<List<GroupMembershipEntity>>(
                              stream: _myGroupsStream,
                              builder: _buildOwnerGroupActions,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerGroupActions(
    BuildContext context,
    AsyncSnapshot<List<GroupMembershipEntity>> snapshot,
  ) {
    if (snapshot.hasError) {
      return AppCard(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(0),
        child: const ListTile(
          leading: Icon(Icons.error_outline),
          title: Text('No se pudieron cargar tus grupos.'),
        ),
      );
    }

    if (!snapshot.hasData) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final ownerGroups = snapshot.data!
        .where((group) => group.role == 'owner')
        .toList()
      ..sort((a, b) => a.groupName.compareTo(b.groupName));

    if (ownerGroups.isEmpty) {
      return AppCard(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(0),
        child: const ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('No tienes grupos para administrar.'),
        ),
      );
    }

    final theme = Theme.of(context);
    final errorColor = theme.colorScheme.error;

    return Column(
      children: ownerGroups.map((group) {
        final isDeleting = _deletingGroupIds.contains(group.groupId);
        return AppCard(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(0),
          child: ListTile(
            enabled: !isDeleting,
            leading: isDeleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.delete_outline, color: errorColor),
            title: Text(
              group.groupName,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: errorColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text('Eliminar grupo (acción irreversible).'),
            onTap: isDeleting ? null : () => _confirmDeleteGroup(group),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPrivacyCenter(BuildContext context) {
    final cookiePreferences = _cookieConsentService.preferences;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.policy_outlined),
            title: const Text('Documentación legal'),
            subtitle: const Text(
              'Consulta términos, privacidad y política de cookies.',
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () => context.push(AppRoutes.legalTerms),
                  child: const Text('Términos'),
                ),
                OutlinedButton(
                  onPressed: () => context.push(AppRoutes.legalPrivacy),
                  child: const Text('Privacidad'),
                ),
                OutlinedButton(
                  onPressed: () => context.push(AppRoutes.legalCookies),
                  child: const Text('Cookies'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: const Text('Cookies analíticas'),
            subtitle: const Text('Puedes activarlas o retirarlas en cualquier momento.'),
            value: cookiePreferences.analytics,
            onChanged: (value) => _updateCookieConsent(analytics: value),
          ),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: const Text('Cookies de preferencias'),
            subtitle: const Text('Guardan personalizaciones no esenciales.'),
            value: cookiePreferences.preferences,
            onChanged: (value) => _updateCookieConsent(preferences: value),
          ),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: const Text('Cookies de marketing'),
            subtitle: const Text('Controla personalización comercial y campañas.'),
            value: cookiePreferences.marketing,
            onChanged: (value) => _updateCookieConsent(marketing: value),
          ),
          const Divider(height: 1),
          if (_userComplianceStream == null)
            const ListTile(
              leading: Icon(Icons.campaign_outlined),
              title: Text('Comunicaciones comerciales'),
              subtitle: Text('No disponible en este entorno.'),
            )
          else
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _userComplianceStream,
              builder: (context, snapshot) {
                final marketingConsent =
                    snapshot.data?.data()?['marketingConsent'] == true;
                return SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: const Text('Comunicaciones comerciales'),
                  subtitle: const Text(
                    'Recibe o revoca comunicaciones promocionales (LSSI).',
                  ),
                  value: marketingConsent,
                  onChanged: _isUpdatingMarketingConsent
                      ? null
                      : _updateMarketingConsent,
                );
              },
            ),
          const Divider(height: 1),
          ListTile(
            leading: _isRequestingDataExport
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download_outlined),
            title: const Text('Solicitar exportación de datos'),
            subtitle: const Text('Ejercicio del derecho de acceso y portabilidad.'),
            onTap: _isRequestingDataExport ? null : _requestDataExport,
          ),
          ListTile(
            leading: _isRequestingAccountDeletion
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_outline),
            title: const Text('Solicitar eliminación de cuenta'),
            subtitle: const Text('Ejercicio del derecho de supresión.'),
            onTap: _isRequestingAccountDeletion
                ? null
                : _requestAccountDeletion,
          ),
          ListTile(
            leading: const Icon(Icons.mail_outline),
            title: const Text('Contactar con privacidad (DPO)'),
            subtitle: Text(LegalPolicyRegistry.dpoEmail),
            onTap: _contactDpo,
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteGroup(GroupMembershipEntity group) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar grupo'),
        content: Text(
          'Se eliminará "${group.groupName}" y su información asociada. '
          '¿Continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _deletingGroupIds.add(group.groupId);
    });

    try {
      await _groupsRepository.deleteGroup(groupId: group.groupId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Grupo "${group.groupName}" eliminado.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar el grupo: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _deletingGroupIds.remove(group.groupId);
        });
      }
    }
  }
}

class _CenteredSectionTitle extends StatelessWidget {
  const _CenteredSectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: Theme.of(context).textTheme.headlineSmall,
        textAlign: TextAlign.center,
      ),
    );
  }
}
