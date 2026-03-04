import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/core/services/cloud_functions_service.dart';

class _MockFirebaseFunctions extends Mock implements FirebaseFunctions {}

class _MockHttpsCallable extends Mock implements HttpsCallable {}

class _MockHttpsCallableResult extends Mock
    implements HttpsCallableResult<dynamic> {}

void main() {
  group('CloudFunctionsService legal payloads', () {
    late _MockFirebaseFunctions functions;
    late _MockHttpsCallable callable;
    late _MockHttpsCallableResult result;
    late CloudFunctionsService service;

    setUp(() {
      functions = _MockFirebaseFunctions();
      callable = _MockHttpsCallable();
      result = _MockHttpsCallableResult();

      when(() => functions.httpsCallable(any())).thenReturn(callable);
      when(() => callable.call(any())).thenAnswer((_) async => result);
      when(() => result.data).thenReturn(const <String, Object?>{});

      service = CloudFunctionsService(functions: functions);
    });

    test(
      'acceptLegalBundle sends versions and policy hashes for audit evidence',
      () async {
        await service.acceptLegalBundle(
          termsVersion: '2026-03-02',
          privacyVersion: '2026-03-02',
          marketingVersion: '2026-03-02',
          marketingOptIn: true,
          termsPolicyHash:
              'a8fbdfd065115fd69d5c98313e3d7d0360da011cd457dba6e3883c5048890ee7',
          privacyPolicyHash:
              '114e26a209a299d1773d426a0970c380c530de7b7247e159dd77aca303f981a1',
          marketingPolicyHash:
              '5670f91ae147dbc2061c0f1eb77320366cebae583d8b936658fb59561d7e8854',
          source: 'web',
        );

        verify(() => functions.httpsCallable('acceptLegalBundle')).called(1);
        final payload = Map<String, dynamic>.from(
          verify(() => callable.call(captureAny())).captured.single
              as Map<dynamic, dynamic>,
        );
        final hashes = Map<String, dynamic>.from(
          payload['policyHashes'] as Map<dynamic, dynamic>,
        );

        expect(payload['termsVersion'], '2026-03-02');
        expect(payload['privacyVersion'], '2026-03-02');
        expect(payload['marketingVersion'], '2026-03-02');
        expect(payload['marketingOptIn'], isTrue);
        expect(
          hashes['terms'],
          'a8fbdfd065115fd69d5c98313e3d7d0360da011cd457dba6e3883c5048890ee7',
        );
        expect(
          hashes['privacy'],
          '114e26a209a299d1773d426a0970c380c530de7b7247e159dd77aca303f981a1',
        );
        expect(
          hashes['marketing'],
          '5670f91ae147dbc2061c0f1eb77320366cebae583d8b936658fb59561d7e8854',
        );
        expect(payload['source'], 'web');
      },
    );

    test(
      'acceptLegalDocs sends explicit revocation action and policy hash',
      () async {
        await service.acceptLegalDocs(
          policyType: 'marketing',
          version: '2026-03-02',
          policyHash:
              '5670f91ae147dbc2061c0f1eb77320366cebae583d8b936658fb59561d7e8854',
          action: 'revoke',
          source: 'web',
        );

        verify(() => functions.httpsCallable('acceptLegalDocs')).called(1);
        final payload = Map<String, dynamic>.from(
          verify(() => callable.call(captureAny())).captured.single
              as Map<dynamic, dynamic>,
        );

        expect(payload['policyType'], 'marketing');
        expect(payload['version'], '2026-03-02');
        expect(payload['action'], 'revoke');
        expect(
          payload['policyHash'],
          '5670f91ae147dbc2061c0f1eb77320366cebae583d8b936658fb59561d7e8854',
        );
        expect(payload['source'], 'web');
      },
    );

    test(
      'requestDataExport returns requestId from callable response',
      () async {
        when(
          () => result.data,
        ).thenReturn(const <String, Object?>{'requestId': 'req_123'});

        final requestId = await service.requestDataExport(
          source: 'web',
          reason: 'test',
        );

        expect(requestId, 'req_123');
      },
    );
  });
}
