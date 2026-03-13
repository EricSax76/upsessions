import 'package:flutter_test/flutter_test.dart';
import 'package:upsessions/modules/event_manager/cubits/gig_offer_form_state.dart';
import 'package:upsessions/modules/event_manager/cubits/gig_offers_state.dart';
import 'package:upsessions/modules/event_manager/cubits/hire_musicians_state.dart';
import 'package:upsessions/modules/event_manager/cubits/manager_agenda_state.dart';
import 'package:upsessions/modules/event_manager/cubits/manager_dashboard_state.dart';
import 'package:upsessions/modules/event_manager/cubits/manager_event_form_state.dart';
import 'package:upsessions/modules/event_manager/cubits/manager_events_state.dart';
import 'package:upsessions/modules/event_manager/cubits/musician_requests_state.dart';

void main() {
  group('EventManager states copyWith', () {
    test('ManagerDashboardState permite limpiar errorMessage', () {
      final stateWithError = ManagerDashboardState(errorMessage: 'error');
      final next = stateWithError.copyWith(errorMessage: null);
      expect(next.errorMessage, isNull);
    });

    test('ManagerEventsState permite limpiar errorMessage', () {
      final stateWithError = ManagerEventsState(errorMessage: 'error');
      final next = stateWithError.copyWith(errorMessage: null);
      expect(next.errorMessage, isNull);
    });

    test('ManagerEventFormState permite limpiar errorMessage', () {
      final stateWithError = ManagerEventFormState(errorMessage: 'error');
      final next = stateWithError.copyWith(errorMessage: null);
      expect(next.errorMessage, isNull);
    });

    test('ManagerAgendaState permite limpiar errorMessage', () {
      final stateWithError = ManagerAgendaState(errorMessage: 'error');
      final next = stateWithError.copyWith(errorMessage: null);
      expect(next.errorMessage, isNull);
    });

    test('GigOffersState permite limpiar errorMessage', () {
      final stateWithError = GigOffersState(errorMessage: 'error');
      final next = stateWithError.copyWith(errorMessage: null);
      expect(next.errorMessage, isNull);
    });

    test('MusicianRequestsState permite limpiar errorMessage', () {
      final stateWithError = MusicianRequestsState(errorMessage: 'error');
      final next = stateWithError.copyWith(errorMessage: null);
      expect(next.errorMessage, isNull);
    });

    test('GigOfferFormState permite limpiar errorMessage', () {
      final stateWithError = GigOfferFormState(errorMessage: 'error');
      final next = stateWithError.copyWith(errorMessage: null);
      expect(next.errorMessage, isNull);
    });

    test('HireMusiciansState preserva error si no se pasa error', () {
      const stateWithError = HireMusiciansState(error: 'error');
      final next = stateWithError.copyWith(isLoading: true);
      expect(next.error, 'error');
    });

    test('HireMusiciansState permite limpiar error', () {
      const stateWithError = HireMusiciansState(error: 'error');
      final next = stateWithError.copyWith(error: null);
      expect(next.error, isNull);
    });
  });
}
