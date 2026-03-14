import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/core/services/cloud_functions_service.dart';
import 'package:upsessions/core/services/cookie_consent_service.dart';
import 'package:upsessions/core/services/cookie_consent_storage.dart';
import 'package:upsessions/features/settings/cubits/account_privacy_actions_cubit.dart';
import 'package:upsessions/features/settings/cubits/account_privacy_actions_state.dart';

class _MockCloudFunctionsService extends Mock
    implements CloudFunctionsService {}

class _InMemoryCookieConsentStorage implements CookieConsentStorage {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String value) async {
    this.value = value;
  }
}

void main() {
  late _MockCloudFunctionsService cloudFunctionsService;
  late CookieConsentService cookieConsentService;

  setUp(() {
    cloudFunctionsService = _MockCloudFunctionsService();
    cookieConsentService = CookieConsentService(
      storage: _InMemoryCookieConsentStorage(),
    );
  });

  AccountPrivacyActionsCubit buildCubit() {
    return AccountPrivacyActionsCubit(
      cloudFunctionsService: cloudFunctionsService,
      cookieConsentService: cookieConsentService,
    );
  }

  test('initial state is correct', () {
    final cubit = buildCubit();
    expect(cubit.state.isUpdatingMarketingConsent, false);
    expect(cubit.state.isRequestingDataExport, false);
    expect(cubit.state.isRequestingAccountDeletion, false);
    expect(cubit.state.requestingPrivacyRightType, isNull);
    expect(cubit.state.feedbackMessage, isNull);
    cubit.close();
  });

  blocTest<AccountPrivacyActionsCubit, AccountPrivacyActionsState>(
    'requestPrivacyRight emits loading + feedback + completed',
    build: () {
      when(
        () => cloudFunctionsService.requestPrivacyRight(
          requestType: 'access',
          source: any(named: 'source'),
          reason: any(named: 'reason'),
        ),
      ).thenAnswer((_) async => 'REQ-123');
      return buildCubit();
    },
    act: (cubit) => cubit.requestPrivacyRight(
      requestType: 'access',
      reason: 'Solicitud de prueba',
    ),
    expect: () => [
      isA<AccountPrivacyActionsState>().having(
        (s) => s.requestingPrivacyRightType,
        'requesting type',
        'access',
      ),
      isA<AccountPrivacyActionsState>()
          .having(
            (s) => s.requestingPrivacyRightType,
            'still loading',
            'access',
          )
          .having((s) => s.feedbackMessage, 'feedback', contains('REQ-123')),
      isA<AccountPrivacyActionsState>()
          .having((s) => s.requestingPrivacyRightType, 'completed', isNull)
          .having(
            (s) => s.feedbackMessage,
            'feedback preserved',
            contains('REQ-123'),
          ),
    ],
  );

  blocTest<AccountPrivacyActionsCubit, AccountPrivacyActionsState>(
    'requestPrivacyRight with unsupported type emits feedback and skips call',
    build: () => buildCubit(),
    act: (cubit) => cubit.requestPrivacyRight(requestType: 'unsupported'),
    expect: () => [
      isA<AccountPrivacyActionsState>().having(
        (s) => s.feedbackMessage,
        'feedback',
        contains('no soportado'),
      ),
    ],
    verify: (_) {
      verifyNever(
        () => cloudFunctionsService.requestPrivacyRight(
          requestType: 'unsupported',
          reason: any(named: 'reason'),
          source: any(named: 'source'),
        ),
      );
    },
  );
}
