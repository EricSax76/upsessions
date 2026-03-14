import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/core/services/cloud_functions_service.dart';
import 'package:upsessions/features/settings/cubits/privacy_backoffice_cubit.dart';
import 'package:upsessions/features/settings/cubits/privacy_backoffice_state.dart';
import 'package:upsessions/features/settings/models/privacy_backoffice_request.dart';

class _MockCloudFunctionsService extends Mock
    implements CloudFunctionsService {}

void main() {
  late _MockCloudFunctionsService cloudFunctionsService;

  setUp(() {
    cloudFunctionsService = _MockCloudFunctionsService();
  });

  PrivacyBackofficeCubit buildCubit() {
    return PrivacyBackofficeCubit(cloudFunctionsService: cloudFunctionsService);
  }

  test('initial state is correct', () {
    final cubit = buildCubit();
    expect(cubit.state.isLoading, false);
    expect(cubit.state.requests, isEmpty);
    expect(cubit.state.selectedStatus, isNull);
    expect(cubit.state.activeRequestKey, isNull);
    expect(cubit.state.errorMessage, isNull);
    cubit.close();
  });

  blocTest<PrivacyBackofficeCubit, PrivacyBackofficeState>(
    'loadRequests emits loading + data',
    build: () {
      when(
        () => cloudFunctionsService.listPrivacyRequestsBackoffice(status: null),
      ).thenAnswer(
        (_) async => <Map<String, Object?>>[
          <String, Object?>{
            'userId': 'user-1',
            'requestId': 'req-1',
            'requestType': 'access',
            'status': 'pending',
            'source': 'web',
            'createdAt': '2026-03-14T09:00:00.000Z',
          },
        ],
      );
      return buildCubit();
    },
    act: (cubit) => cubit.loadRequests(),
    expect: () => [
      isA<PrivacyBackofficeState>().having(
        (s) => s.isLoading,
        'isLoading',
        true,
      ),
      isA<PrivacyBackofficeState>()
          .having((s) => s.isLoading, 'isLoading', false)
          .having((s) => s.requests.length, 'items', 1)
          .having(
            (s) => s.requests.first.status,
            'status',
            PrivacyRequestStatus.pending,
          ),
    ],
  );

  blocTest<PrivacyBackofficeCubit, PrivacyBackofficeState>(
    'updateRequestStatus with invalid transition emits feedback and skips call',
    build: () => buildCubit(),
    act: (cubit) => cubit.updateRequestStatus(
      request: const PrivacyBackofficeRequest(
        userId: 'user-2',
        requestId: 'req-2',
        requestType: 'access',
        rawStatus: 'completed',
        source: 'web',
      ),
      nextStatus: PrivacyRequestStatus.pending,
    ),
    expect: () => [
      isA<PrivacyBackofficeState>().having(
        (s) => s.feedbackMessage,
        'feedback',
        contains('no está permitida'),
      ),
    ],
    verify: (_) {
      verifyNever(
        () => cloudFunctionsService.updatePrivacyRequestStatusBackoffice(
          userId: any(named: 'userId'),
          requestId: any(named: 'requestId'),
          nextStatus: any(named: 'nextStatus'),
          statusReason: any(named: 'statusReason'),
          source: any(named: 'source'),
        ),
      );
    },
  );

  blocTest<PrivacyBackofficeCubit, PrivacyBackofficeState>(
    'updateRequestStatus updates backend and refreshes list',
    build: () {
      when(
        () => cloudFunctionsService.updatePrivacyRequestStatusBackoffice(
          userId: 'user-1',
          requestId: 'req-1',
          nextStatus: 'in_progress',
          statusReason: 'Identidad verificada',
          source: any(named: 'source'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => cloudFunctionsService.listPrivacyRequestsBackoffice(status: null),
      ).thenAnswer(
        (_) async => <Map<String, Object?>>[
          <String, Object?>{
            'userId': 'user-1',
            'requestId': 'req-1',
            'requestType': 'access',
            'status': 'in_progress',
            'source': 'web',
          },
        ],
      );
      return buildCubit();
    },
    act: (cubit) => cubit.updateRequestStatus(
      request: const PrivacyBackofficeRequest(
        userId: 'user-1',
        requestId: 'req-1',
        requestType: 'access',
        rawStatus: 'pending',
        source: 'web',
      ),
      nextStatus: PrivacyRequestStatus.inProgress,
      statusReason: 'Identidad verificada',
    ),
    expect: () => [
      isA<PrivacyBackofficeState>().having(
        (s) => s.activeRequestKey,
        'active request',
        'user-1/req-1',
      ),
      isA<PrivacyBackofficeState>()
          .having((s) => s.feedbackVersion, 'feedbackVersion', 1)
          .having((s) => s.activeRequestKey, 'active request', 'user-1/req-1'),
      isA<PrivacyBackofficeState>()
          .having((s) => s.requests.length, 'requests', 1)
          .having((s) => s.activeRequestKey, 'active request', 'user-1/req-1'),
      isA<PrivacyBackofficeState>()
          .having((s) => s.activeRequestKey, 'active request', isNull)
          .having((s) => s.requests.first.rawStatus, 'status', 'in_progress'),
    ],
  );
}
