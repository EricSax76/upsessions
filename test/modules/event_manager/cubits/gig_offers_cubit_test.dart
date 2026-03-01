import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/modules/event_manager/cubits/gig_offers_cubit.dart';
import 'package:upsessions/modules/event_manager/cubits/gig_offers_state.dart';
import 'package:upsessions/modules/event_manager/models/gig_offer_entity.dart';
import 'package:upsessions/modules/event_manager/repositories/gig_offers_repository.dart';

class _MockGigOffersRepository extends Mock implements GigOffersRepository {}

void main() {
  late _MockGigOffersRepository repository;

  final offers = [
    GigOfferEntity(
      id: 'g1',
      managerId: 'manager-1',
      title: 'Guitarrista para evento',
      description: 'Buscamos guitarrista',
      instrumentRequirements: const ['Guitarra eléctrica'],
      date: DateTime(2026, 5, 1),
      time: '21:00',
      location: 'Madrid',
      status: GigOfferStatus.open,
      applicants: const [],
      createdAt: DateTime(2026, 3, 1),
    ),
    GigOfferEntity(
      id: 'g2',
      managerId: 'manager-1',
      title: 'Batería para festival',
      description: 'Se necesita batería',
      instrumentRequirements: const ['Batería'],
      date: DateTime(2026, 6, 1),
      time: '19:00',
      location: 'Barcelona',
      status: GigOfferStatus.closed,
      applicants: const ['m1'],
      createdAt: DateTime(2026, 3, 5),
    ),
  ];

  setUp(() {
    repository = _MockGigOffersRepository();
  });

  GigOffersCubit buildCubit() {
    return GigOffersCubit(repository: repository);
  }

  group('GigOffersCubit', () {
    test('estado inicial tiene isLoading true y lista vacía', () {
      final cubit = buildCubit();
      expect(cubit.state.isLoading, true);
      expect(cubit.state.offers, isEmpty);
      cubit.close();
    });

    // -- loadOffers --

    blocTest<GigOffersCubit, GigOffersState>(
      'loadOffers carga las ofertas del manager',
      build: () {
        when(() => repository.fetchManagerOffers())
            .thenAnswer((_) async => offers);
        return buildCubit();
      },
      act: (cubit) => cubit.loadOffers(),
      expect: () => [
        isA<GigOffersState>()
            .having((s) => s.isLoading, 'loading', true),
        isA<GigOffersState>()
            .having((s) => s.isLoading, 'idle', false)
            .having((s) => s.offers.length, 'count', 2),
      ],
    );

    blocTest<GigOffersCubit, GigOffersState>(
      'loadOffers emite error cuando falla el repositorio',
      build: () {
        when(() => repository.fetchManagerOffers())
            .thenThrow(Exception('load error'));
        return buildCubit();
      },
      act: (cubit) => cubit.loadOffers(),
      expect: () => [
        isA<GigOffersState>()
            .having((s) => s.isLoading, 'loading', true),
        isA<GigOffersState>()
            .having((s) => s.isLoading, 'idle', false)
            .having((s) => s.errorMessage, 'err', contains('load error')),
      ],
    );

    // -- deleteOffer --

    blocTest<GigOffersCubit, GigOffersState>(
      'deleteOffer elimina la oferta y actualiza la lista',
      build: () {
        when(() => repository.deleteOffer('g1')).thenAnswer((_) async {});
        return buildCubit();
      },
      seed: () => GigOffersState(isLoading: false, offers: offers),
      act: (cubit) => cubit.deleteOffer('g1'),
      expect: () => [
        isA<GigOffersState>()
            .having((s) => s.isLoading, 'loading', true),
        isA<GigOffersState>()
            .having((s) => s.isLoading, 'idle', false)
            .having((s) => s.offers.length, 'count', 1)
            .having((s) => s.offers.first.id, 'remaining', 'g2'),
      ],
    );

    blocTest<GigOffersCubit, GigOffersState>(
      'deleteOffer emite error cuando falla la eliminación',
      build: () {
        when(() => repository.deleteOffer('g1'))
            .thenThrow(Exception('delete error'));
        return buildCubit();
      },
      seed: () => GigOffersState(isLoading: false, offers: offers),
      act: (cubit) => cubit.deleteOffer('g1'),
      expect: () => [
        isA<GigOffersState>()
            .having((s) => s.isLoading, 'loading', true),
        isA<GigOffersState>()
            .having((s) => s.isLoading, 'idle', false)
            .having((s) => s.errorMessage, 'err', contains('delete error')),
      ],
    );
  });
}
