import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/modules/event_manager/cubits/gig_offers_cubit.dart';
import 'package:upsessions/modules/event_manager/cubits/gig_offers_state.dart';
import 'package:upsessions/modules/event_manager/ui/pages/gig_offers_page.dart';

class _MockGigOffersCubit extends MockCubit<GigOffersState>
    implements GigOffersCubit {}

void main() {
  late _MockGigOffersCubit cubit;

  setUp(() {
    cubit = _MockGigOffersCubit();
    const initialState = GigOffersState(isLoading: false, offers: []);
    when(() => cubit.state).thenReturn(initialState);
    whenListen(
      cubit,
      const Stream<GigOffersState>.empty(),
      initialState: initialState,
    );
    when(() => cubit.loadOffers()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await cubit.close();
  });

  testWidgets('recarga ofertas al volver del formulario', (tester) async {
    final router = GoRouter(
      initialLocation: AppRoutes.eventManagerGigOffers,
      routes: [
        GoRoute(
          path: AppRoutes.eventManagerGigOffers,
          builder: (context, state) => BlocProvider<GigOffersCubit>.value(
            value: cubit,
            child: const GigOffersPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.eventManagerGigOfferForm,
          builder: (context, state) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => context.pop(),
                child: const Text('Close Form'),
              ),
            ),
          ),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    verify(() => cubit.loadOffers()).called(1);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Close Form'), findsOneWidget);

    await tester.tap(find.text('Close Form'));
    await tester.pumpAndSettle();

    verify(() => cubit.loadOffers()).called(1);
  });
}
