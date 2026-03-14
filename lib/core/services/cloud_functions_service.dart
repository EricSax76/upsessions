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

  Future<String> requestDataExport({String? reason, String? source}) async {
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

  Future<String> requestPrivacyRight({
    required String requestType,
    String? reason,
    String? source,
  }) async {
    final callable = _functions.httpsCallable('requestPrivacyRight');
    final payload = <String, Object?>{
      'requestType': requestType,
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

  Future<List<Map<String, Object?>>> listPrivacyRequestsBackoffice({
    String? status,
    int limit = 50,
  }) async {
    final callable = _functions.httpsCallable('listPrivacyRequestsBackoffice');
    final payload = <String, Object?>{
      'limit': limit,
      ...?status == null ? null : <String, Object?>{'status': status},
    };
    final response = await callable.call(payload);
    final data = _asStringObjectMap(response.data);
    final items = data['items'];
    if (items is! List) {
      return const <Map<String, Object?>>[];
    }

    return items
        .map(_asStringObjectMap)
        .where((entry) => entry.isNotEmpty)
        .toList(growable: false);
  }

  Future<void> updatePrivacyRequestStatusBackoffice({
    required String userId,
    required String requestId,
    required String nextStatus,
    String? statusReason,
    String? source,
  }) async {
    final callable = _functions.httpsCallable(
      'updatePrivacyRequestStatusBackoffice',
    );
    final payload = <String, Object?>{
      'userId': userId,
      'requestId': requestId,
      'nextStatus': nextStatus,
      ...?statusReason == null
          ? null
          : <String, Object?>{'statusReason': statusReason},
      ...?source == null ? null : <String, Object?>{'source': source},
    };
    await callable.call(payload);
  }

  Map<String, Object?> _asStringObjectMap(Object? raw) {
    if (raw is! Map) {
      return const <String, Object?>{};
    }

    final normalized = <String, Object?>{};
    for (final entry in raw.entries) {
      final key = entry.key;
      if (key is String) {
        normalized[key] = entry.value;
      }
    }
    return normalized;
  }
}
