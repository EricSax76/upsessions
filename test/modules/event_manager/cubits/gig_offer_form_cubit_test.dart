import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/modules/event_manager/cubits/gig_offer_form_cubit.dart';
import 'package:upsessions/modules/event_manager/cubits/gig_offer_form_state.dart';
import 'package:upsessions/modules/event_manager/models/gig_offer_entity.dart';
import 'package:upsessions/modules/event_manager/repositories/gig_offers_repository.dart';

class _MockGigOffersRepository extends Mock implements GigOffersRepository {}

void main() {
  late _MockGigOffersRepository repository;

  final offer = GigOfferEntity(
    id: '',
    managerId: 'manager-1',
    title: 'Bajista para bolo',
    description: 'Necesitamos bajista',
    instrumentRequirements: const ['Bajo'],
    date: DateTime(2026, 5, 15),
    time: '22:00',
    location: 'Sevilla',
    status: GigOfferStatus.open,
    applicants: const [],
    createdAt: DateTime(2026, 3, 1),
  );

  setUpAll(() {
    registerFallbackValue(offer);
  });

  setUp(() {
    repository = _MockGigOffersRepository();
  });

  GigOfferFormCubit buildCubit() {
    return GigOfferFormCubit(repository: repository);
  }

  group('GigOfferFormCubit', () {
    test('estado inicial tiene isSaving false y success false', () {
      final cubit = buildCubit();
      expect(cubit.state.isSaving, false);
      expect(cubit.state.success, false);
      expect(cubit.state.errorMessage, isNull);
      cubit.close();
    });

    blocTest<GigOfferFormCubit, GigOfferFormState>(
      'saveOffer emite saving y success cuando se guarda correctamente',
      build: () {
        when(() => repository.saveOffer(any()))
            .thenAnswer((_) async => offer.copyWith(id: 'g-new'));
        return buildCubit();
      },
      act: (cubit) => cubit.saveOffer(offer),
      expect: () => [
        isA<GigOfferFormState>()
            .having((s) => s.isSaving, 'saving', true)
            .having((s) => s.success, 'success', false),
        isA<GigOfferFormState>()
            .having((s) => s.isSaving, 'idle', false)
            .having((s) => s.success, 'success', true),
      ],
    );

    blocTest<GigOfferFormCubit, GigOfferFormState>(
      'saveOffer emite error cuando falla el guardado',
      build: () {
        when(() => repository.saveOffer(any()))
            .thenThrow(Exception('save error'));
        return buildCubit();
      },
      act: (cubit) => cubit.saveOffer(offer),
      expect: () => [
        isA<GigOfferFormState>()
            .having((s) => s.isSaving, 'saving', true),
        isA<GigOfferFormState>()
            .having((s) => s.isSaving, 'idle', false)
            .having((s) => s.errorMessage, 'err', contains('save error')),
      ],
    );
  });
}
