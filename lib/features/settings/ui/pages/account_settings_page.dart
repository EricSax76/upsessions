import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:upsessions/core/locator/locator.dart';
import 'package:upsessions/core/services/cloud_functions_service.dart';
import 'package:upsessions/core/services/cookie_consent_service.dart';
import 'package:upsessions/features/legal/legal_policy_registry.dart';
import 'package:upsessions/features/settings/cubits/account_privacy_actions_cubit.dart';
import 'package:upsessions/features/settings/cubits/account_privacy_actions_state.dart';
import 'package:upsessions/features/settings/cubits/privacy_backoffice_cubit.dart';
import 'package:upsessions/features/settings/cubits/privacy_backoffice_state.dart';
import 'package:upsessions/features/settings/models/privacy_backoffice_request.dart';
import 'package:upsessions/features/settings/ui/widgets/account_settings/account_privacy_center_card.dart';
import 'package:upsessions/features/settings/ui/widgets/account_settings/account_settings_dialogs.dart';
import 'package:upsessions/features/settings/ui/widgets/account_settings/owner_group_actions_section.dart';
import 'package:upsessions/features/settings/ui/widgets/account_settings/privacy_backoffice_section.dart';
import 'package:upsessions/features/settings/ui/widgets/account_settings/settings_section_title.dart';
import 'package:upsessions/modules/auth/cubits/auth_cubit.dart';
import 'package:upsessions/modules/auth/models/user_entity.dart';
import 'package:upsessions/modules/groups/models/group_membership_entity.dart';
import 'package:upsessions/modules/groups/repositories/groups_repository.dart';
import 'package:upsessions/modules/notifications/cubits/notification_preferences_cubit.dart';
import 'package:upsessions/modules/notifications/models/notification_scenario.dart';
import 'package:upsessions/modules/notifications/repositories/notification_preferences_repository.dart';
import 'package:upsessions/modules/notifications/ui/widgets/notification_preferences_section.dart';
import 'package:upsessions/modules/profile/models/account_settings_card.dart';

import '../../cubits/account_preferences_cubit.dart';

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AccountPreferencesCubit()),
        BlocProvider(
          create: (_) => NotificationPreferencesCubit(
            repository: locate<NotificationPreferencesRepository>(),
          ),
        ),
        BlocProvider(
          create: (_) => AccountPrivacyActionsCubit(
            cloudFunctionsService: locate<CloudFunctionsService>(),
            cookieConsentService: locate<CookieConsentService>(),
          ),
        ),
        BlocProvider(
          create: (context) {
            final cubit = PrivacyBackofficeCubit(
              cloudFunctionsService: locate<CloudFunctionsService>(),
            );
            final isAdmin =
                context.read<AuthCubit>().state.user?.role == UserRole.admin;
            if (isAdmin) {
              unawaited(cubit.loadRequests());
            }
            return cubit;
          },
        ),
      ],
      child: const _AccountSettingsPageView(),
    );
  }
}

class _AccountSettingsPageView extends StatefulWidget {
  const _AccountSettingsPageView();

  @override
  State<_AccountSettingsPageView> createState() =>
      _AccountSettingsPageViewState();
}

class _AccountSettingsPageViewState extends State<_AccountSettingsPageView> {
  late final GroupsRepository _groupsRepository;
  late final Stream<List<GroupMembershipEntity>> _myGroupsStream;
  Stream<DocumentSnapshot<Map<String, dynamic>>>? _userComplianceStream;
  final Set<String> _deletingGroupIds = <String>{};

  @override
  void initState() {
    super.initState();
    _groupsRepository = context.read<GroupsRepository>();
    _myGroupsStream = _groupsRepository.watchMyGroups();

    final uid = context.read<AuthCubit>().state.user?.id;
    if (uid != null && uid.isNotEmpty && Firebase.apps.isNotEmpty) {
      _userComplianceStream = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots();
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _requestAccountDeletion() async {
    final actionsCubit = context.read<AccountPrivacyActionsCubit>();
    if (actionsCubit.state.isRequestingAccountDeletion) return;

    final confirmed = await showRequestAccountDeletionDialog(context);
    if (!confirmed || !mounted) return;
    if (actionsCubit.state.isRequestingAccountDeletion) return;
    await actionsCubit.requestAccountDeletion();
  }

  Future<void> _requestPrivacyRight(String requestType, String title) async {
    final actionsCubit = context.read<AccountPrivacyActionsCubit>();
    if (actionsCubit.state.requestingPrivacyRightType != null) return;

    final confirmed = await showRequestPrivacyRightDialog(
      context,
      rightTitle: title,
    );
    if (!confirmed || !mounted) return;
    if (actionsCubit.state.requestingPrivacyRightType != null) return;

    await actionsCubit.requestPrivacyRight(
      requestType: requestType,
      reason: 'Solicitud iniciada por el usuario desde ajustes ($requestType).',
    );
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
    if (!launched) {
      _showSnackBar('No pudimos abrir tu cliente de correo.');
    }
  }

  Future<void> _setBackofficeFilter(PrivacyRequestStatus? status) async {
    await context.read<PrivacyBackofficeCubit>().setFilter(status);
  }

  Future<void> _refreshBackofficeRequests() async {
    await context.read<PrivacyBackofficeCubit>().refresh();
  }

  Future<void> _updateBackofficeRequestStatus(
    PrivacyBackofficeRequest request,
    PrivacyRequestStatus nextStatus,
  ) async {
    final backofficeCubit = context.read<PrivacyBackofficeCubit>();
    if (backofficeCubit.state.isUpdatingStatus) return;

    final reason = await showUpdatePrivacyRequestStatusDialog(
      context,
      requestTypeLabel: request.requestTypeLabel,
      currentStatusLabel: request.statusLabel,
      nextStatusLabel: nextStatus.label,
    );
    if (!mounted || reason == null) return;

    await backofficeCubit.updateRequestStatus(
      request: request,
      nextStatus: nextStatus,
      statusReason: reason.isEmpty ? null : reason,
    );
  }

  NotificationAudience? _notificationAudienceForRole(UserRole? role) {
    switch (role) {
      case UserRole.musician:
        return NotificationAudience.musician;
      case UserRole.studio:
        return NotificationAudience.studio;
      case UserRole.manager:
        return NotificationAudience.eventManager;
      case UserRole.admin:
      case null:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userRole = context.read<AuthCubit>().state.user?.role;
    final isAdmin = userRole == UserRole.admin;
    final notificationsAudience = _notificationAudienceForRole(userRole);
    final titleStyle = Theme.of(
      context,
    ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold);

    return MultiBlocListener(
      listeners: [
        BlocListener<AccountPrivacyActionsCubit, AccountPrivacyActionsState>(
          listenWhen: (previous, current) =>
              previous.feedbackVersion != current.feedbackVersion &&
              current.feedbackMessage != null,
          listener: (context, state) {
            _showSnackBar(state.feedbackMessage!);
          },
        ),
        BlocListener<PrivacyBackofficeCubit, PrivacyBackofficeState>(
          listenWhen: (previous, current) =>
              previous.feedbackVersion != current.feedbackVersion &&
              current.feedbackMessage != null,
          listener: (context, state) {
            _showSnackBar(state.feedbackMessage!);
          },
        ),
      ],
      child: SafeArea(
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
                    BlocBuilder<
                      AccountPreferencesCubit,
                      AccountPreferencesState
                    >(
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
                              const SettingsSectionTitle(
                                text: 'Notificaciones',
                              ),
                              const SizedBox(height: 12),
                              NotificationPreferencesSection(
                                audience: notificationsAudience,
                              ),
                              const SizedBox(height: 24),
                              const SettingsSectionTitle(
                                text: 'Privacidad y consentimiento',
                              ),
                              const SizedBox(height: 12),
                              BlocBuilder<
                                AccountPrivacyActionsCubit,
                                AccountPrivacyActionsState
                              >(
                                builder: (context, privacyState) {
                                  final actionsCubit = context
                                      .read<AccountPrivacyActionsCubit>();
                                  return AccountPrivacyCenterCard(
                                    cookiePreferences:
                                        privacyState.cookiePreferences,
                                    onAnalyticsCookiesChanged: (value) =>
                                        actionsCubit.updateCookieConsent(
                                          analytics: value,
                                        ),
                                    onPreferencesCookiesChanged: (value) =>
                                        actionsCubit.updateCookieConsent(
                                          preferences: value,
                                        ),
                                    onMarketingCookiesChanged: (value) =>
                                        actionsCubit.updateCookieConsent(
                                          marketing: value,
                                        ),
                                    userComplianceStream: _userComplianceStream,
                                    isUpdatingMarketingConsent:
                                        privacyState.isUpdatingMarketingConsent,
                                    onMarketingConsentChanged:
                                        actionsCubit.updateMarketingConsent,
                                    isRequestingDataExport:
                                        privacyState.isRequestingDataExport,
                                    onRequestDataExport:
                                        actionsCubit.requestDataExport,
                                    isRequestingAccountDeletion: privacyState
                                        .isRequestingAccountDeletion,
                                    onRequestAccountDeletion:
                                        _requestAccountDeletion,
                                    requestingPrivacyRightType:
                                        privacyState.requestingPrivacyRightType,
                                    onRequestPrivacyRight: _requestPrivacyRight,
                                    onContactDpo: _contactDpo,
                                  );
                                },
                              ),
                              if (isAdmin) ...[
                                const SizedBox(height: 24),
                                const SettingsSectionTitle(
                                  text: 'Backoffice privacidad',
                                ),
                                const SizedBox(height: 12),
                                BlocBuilder<
                                  PrivacyBackofficeCubit,
                                  PrivacyBackofficeState
                                >(
                                  builder: (context, backofficeState) {
                                    return PrivacyBackofficeSection(
                                      state: backofficeState,
                                      onFilterSelected: _setBackofficeFilter,
                                      onRefresh: _refreshBackofficeRequests,
                                      onStatusUpdateRequested:
                                          _updateBackofficeRequestStatus,
                                    );
                                  },
                                ),
                              ],
                              const SizedBox(height: 24),
                              const SettingsSectionTitle(text: 'Acciones'),
                              const SizedBox(height: 12),
                              StreamBuilder<List<GroupMembershipEntity>>(
                                stream: _myGroupsStream,
                                builder: (context, snapshot) {
                                  return OwnerGroupActionsSection(
                                    snapshot: snapshot,
                                    deletingGroupIds: _deletingGroupIds,
                                    onDeleteGroupRequested: _confirmDeleteGroup,
                                  );
                                },
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
      ),
    );
  }

  Future<void> _confirmDeleteGroup(GroupMembershipEntity group) async {
    final confirmed = await showDeleteGroupDialog(
      context,
      groupName: group.groupName,
    );
    if (!confirmed || !mounted) return;

    setState(() {
      _deletingGroupIds.add(group.groupId);
    });

    try {
      await _groupsRepository.deleteGroup(groupId: group.groupId);
      _showSnackBar('Grupo "${group.groupName}" eliminado.');
    } catch (error) {
      _showSnackBar('No se pudo eliminar el grupo: $error');
    } finally {
      if (mounted) {
        setState(() {
          _deletingGroupIds.remove(group.groupId);
        });
      }
    }
  }
}
