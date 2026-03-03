import 'package:cloud_functions/cloud_functions.dart';

class CloudFunctionsService {
  CloudFunctionsService({required FirebaseFunctions functions})
    : _functions = functions;

  final FirebaseFunctions _functions;

  Future<void> syncUserSession({String? locale}) async {
    try {
      final callable = _functions.httpsCallable('syncUserSession');
      final normalizedLocale = locale?.trim();
      final payload = <String, Object?>{
        ...?normalizedLocale == null || normalizedLocale.isEmpty
            ? null
            : <String, Object?>{'locale': normalizedLocale},
      };
      await callable.call(payload);
    } catch (_) {
      // Local envs may not have this function deployed yet.
    }
  }

  Future<void> updateUserComplianceProfile({
    String? locale,
    String? phoneNumber,
  }) async {
    final callable = _functions.httpsCallable('updateUserComplianceProfile');
    final payload = <String, Object?>{
      ...?locale == null ? null : <String, Object?>{'locale': locale},
      ...?phoneNumber == null
          ? null
          : <String, Object?>{'phoneNumber': phoneNumber},
    };
    await callable.call(payload);
  }

  Future<void> acceptLegalDocs({
    required String policyType,
    required String version,
    String action = 'accept',
    String? source,
    String? policyHash,
  }) async {
    final callable = _functions.httpsCallable('acceptLegalDocs');
    final payload = <String, Object?>{
      'policyType': policyType,
      'version': version,
      'action': action,
      ...?source == null ? null : <String, Object?>{'source': source},
      ...?policyHash == null
          ? null
          : <String, Object?>{'policyHash': policyHash},
    };
    await callable.call(payload);
  }

  Future<void> acceptLegalBundle({
    required String termsVersion,
    required String privacyVersion,
    required String marketingVersion,
    required bool marketingOptIn,
    bool acceptTerms = true,
    bool acceptPrivacy = true,
    String? source,
    String? termsPolicyHash,
    String? privacyPolicyHash,
    String? marketingPolicyHash,
  }) async {
    final callable = _functions.httpsCallable('acceptLegalBundle');
    final payload = <String, Object?>{
      'termsVersion': termsVersion,
      'privacyVersion': privacyVersion,
      'marketingVersion': marketingVersion,
      'marketingOptIn': marketingOptIn,
      'acceptTerms': acceptTerms,
      'acceptPrivacy': acceptPrivacy,
      ...?source == null ? null : <String, Object?>{'source': source},
      ...?termsPolicyHash == null &&
              privacyPolicyHash == null &&
              marketingPolicyHash == null
          ? null
          : <String, Object?>{
              'policyHashes': <String, Object?>{
                ...?termsPolicyHash == null
                    ? null
                    : <String, Object?>{'terms': termsPolicyHash},
                ...?privacyPolicyHash == null
                    ? null
                    : <String, Object?>{'privacy': privacyPolicyHash},
                ...?marketingPolicyHash == null
                    ? null
                    : <String, Object?>{'marketing': marketingPolicyHash},
              },
            },
    };
    await callable.call(payload);
  }

  Future<void> notifyChatMessage({
    required String threadId,
    required String sender,
    required String body,
  }) async {
    try {
      final callable = _functions.httpsCallable('sendChatNotification');
      await callable.call({
        'threadId': threadId,
        'sender': sender,
        'body': body,
      });
    } catch (_) {
      // Los entornos locales pueden no tener la función desplegada aún; ignoramos errores suaves.
    }
  }
}
