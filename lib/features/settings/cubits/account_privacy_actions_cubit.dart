import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upsessions/core/services/cloud_functions_service.dart';
import 'package:upsessions/core/services/cookie_consent_service.dart';
import 'package:upsessions/features/legal/legal_policy_registry.dart';

import 'account_privacy_actions_state.dart';

class AccountPrivacyActionsCubit extends Cubit<AccountPrivacyActionsState> {
  AccountPrivacyActionsCubit({
    required CloudFunctionsService cloudFunctionsService,
    required CookieConsentService cookieConsentService,
  }) : _cloudFunctionsService = cloudFunctionsService,
       _cookieConsentService = cookieConsentService,
       super(
         AccountPrivacyActionsState(
           cookiePreferences: cookieConsentService.preferences,
         ),
       ) {
    _cookieConsentService.addListener(_onCookiePreferencesChanged);
  }

  final CloudFunctionsService _cloudFunctionsService;
  final CookieConsentService _cookieConsentService;
  static const Set<String> _supportedPrivacyRightTypes = <String>{
    'access',
    'rectification',
    'erasure',
    'restriction',
    'portability',
    'objection',
  };

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

  Future<void> updateMarketingConsent(bool nextValue) async {
    if (state.isUpdatingMarketingConsent) return;
    emit(state.copyWith(isUpdatingMarketingConsent: true));
    try {
      await _cloudFunctionsService.acceptLegalDocs(
        policyType: 'marketing',
        version: LegalPolicyRegistry.marketingVersion,
        policyHash: LegalPolicyRegistry.marketingPolicyHash,
        action: nextValue ? 'accept' : 'revoke',
        source: _source,
      );
      _emitFeedback(
        nextValue
            ? 'Consentimiento comercial activado.'
            : 'Consentimiento comercial retirado.',
      );
    } catch (error) {
      _emitFeedback('No pudimos actualizar tu consentimiento: $error');
    } finally {
      if (!isClosed) {
        emit(state.copyWith(isUpdatingMarketingConsent: false));
      }
    }
  }

  Future<void> requestDataExport() async {
    if (state.isRequestingDataExport ||
        state.isRequestingAccountDeletion ||
        state.requestingPrivacyRightType != null) {
      return;
    }
    emit(state.copyWith(isRequestingDataExport: true));
    try {
      final requestId = await _cloudFunctionsService.requestDataExport(
        source: _source,
        reason: 'Solicitud iniciada por el usuario desde ajustes.',
      );
      _emitFeedback(
        requestId.isEmpty
            ? 'Solicitud de exportación registrada.'
            : 'Solicitud de exportación registrada: $requestId',
      );
    } catch (error) {
      _emitFeedback('No pudimos registrar la solicitud: $error');
    } finally {
      if (!isClosed) {
        emit(state.copyWith(isRequestingDataExport: false));
      }
    }
  }

  Future<void> requestAccountDeletion() async {
    if (state.isRequestingAccountDeletion ||
        state.isRequestingDataExport ||
        state.requestingPrivacyRightType != null) {
      return;
    }
    emit(state.copyWith(isRequestingAccountDeletion: true));
    try {
      final requestId = await _cloudFunctionsService.requestAccountDeletion(
        source: _source,
        reason: 'Solicitud iniciada por el usuario desde ajustes.',
      );
      _emitFeedback(
        requestId.isEmpty
            ? 'Solicitud de eliminación registrada.'
            : 'Solicitud de eliminación registrada: $requestId',
      );
    } catch (error) {
      _emitFeedback('No pudimos registrar la solicitud: $error');
    } finally {
      if (!isClosed) {
        emit(state.copyWith(isRequestingAccountDeletion: false));
      }
    }
  }

  Future<void> requestPrivacyRight({
    required String requestType,
    String? reason,
  }) async {
    final normalizedType = requestType.trim().toLowerCase();
    if (!_supportedPrivacyRightTypes.contains(normalizedType)) {
      _emitFeedback('Tipo de solicitud no soportado: $requestType');
      return;
    }
    if (state.isRequestingDataExport ||
        state.isRequestingAccountDeletion ||
        state.requestingPrivacyRightType != null) {
      return;
    }

    emit(state.copyWith(requestingPrivacyRightType: normalizedType));
    try {
      final requestId = await _cloudFunctionsService.requestPrivacyRight(
        requestType: normalizedType,
        source: _source,
        reason: reason ?? 'Solicitud iniciada por el usuario desde ajustes.',
      );
      final label = _privacyRightLabel(normalizedType);
      _emitFeedback(
        requestId.isEmpty
            ? 'Solicitud de $label registrada.'
            : 'Solicitud de $label registrada: $requestId',
      );
    } catch (error) {
      _emitFeedback('No pudimos registrar la solicitud: $error');
    } finally {
      if (!isClosed) {
        emit(state.copyWith(requestingPrivacyRightType: null));
      }
    }
  }

  Future<void> updateCookieConsent({
    bool? analytics,
    bool? preferences,
    bool? marketing,
  }) async {
    final current = state.cookiePreferences;
    try {
      await _cookieConsentService.saveSelection(
        analytics: analytics ?? current.analytics,
        preferences: preferences ?? current.preferences,
        marketing: marketing ?? current.marketing,
      );
    } catch (error) {
      _emitFeedback(
        'No pudimos actualizar tus preferencias de cookies: $error',
      );
    }
  }

  void _onCookiePreferencesChanged() {
    if (isClosed) return;
    emit(state.copyWith(cookiePreferences: _cookieConsentService.preferences));
  }

  void _emitFeedback(String message) {
    if (isClosed) return;
    emit(
      state.copyWith(
        feedbackMessage: message,
        feedbackVersion: state.feedbackVersion + 1,
      ),
    );
  }

  String _privacyRightLabel(String requestType) {
    switch (requestType) {
      case 'access':
        return 'acceso';
      case 'rectification':
        return 'rectificación';
      case 'erasure':
        return 'supresión';
      case 'restriction':
        return 'limitación';
      case 'portability':
        return 'portabilidad';
      case 'objection':
        return 'oposición';
      default:
        return requestType;
    }
  }

  @override
  Future<void> close() {
    _cookieConsentService.removeListener(_onCookiePreferencesChanged);
    return super.close();
  }
}
