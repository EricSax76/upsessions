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
    required String policyHash,
    String action = 'accept',
    String? source,
  }) async {
    final callable = _functions.httpsCallable('acceptLegalDocs');
    final payload = <String, Object?>{
      'policyType': policyType,
      'version': version,
      'action': action,
      'policyHash': policyHash,
      ...?source == null ? null : <String, Object?>{'source': source},
    };
    await callable.call(payload);
  }

  Future<void> acceptLegalBundle({
    required String termsVersion,
    required String privacyVersion,
    required String marketingVersion,
    required bool marketingOptIn,
    required String termsPolicyHash,
    required String privacyPolicyHash,
    required String marketingPolicyHash,
    bool acceptTerms = true,
    bool acceptPrivacy = true,
    String? source,
  }) async {
    final callable = _functions.httpsCallable('acceptLegalBundle');
    final payload = <String, Object?>{
      'termsVersion': termsVersion,
      'privacyVersion': privacyVersion,
      'marketingVersion': marketingVersion,
      'marketingOptIn': marketingOptIn,
      'acceptTerms': acceptTerms,
      'acceptPrivacy': acceptPrivacy,
      'policyHashes': <String, Object?>{
        'terms': termsPolicyHash,
        'privacy': privacyPolicyHash,
        'marketing': marketingPolicyHash,
      },
      ...?source == null ? null : <String, Object?>{'source': source},
    };
    await callable.call(payload);
  }

  Future<String> requestDataExport({
    String? reason,
    String? source,
  }) async {
    final callable = _functions.httpsCallable('requestDataExport');
    final payload = <String, Object?>{
      ...?reason == null ? null : <String, Object?>{'reason': reason},
      ...?source == null ? null : <String, Object?>{'source': source},
    };
    final response = await callable.call(payload);
    final data = response.data;
    if (data is Map && data['requestId'] is String) {
      return data['requestId'] as String;
    }
    return '';
  }

  Future<String> requestAccountDeletion({
    String? reason,
    String? source,
  }) async {
    final callable = _functions.httpsCallable('requestAccountDeletion');
    final payload = <String, Object?>{
      ...?reason == null ? null : <String, Object?>{'reason': reason},
      ...?source == null ? null : <String, Object?>{'source': source},
    };
    final response = await callable.call(payload);
    final data = response.data;
    if (data is Map && data['requestId'] is String) {
      return data['requestId'] as String;
    }
    return '';
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
