import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upsessions/core/services/cloud_functions_service.dart';
import 'package:upsessions/features/settings/models/privacy_backoffice_request.dart';

import 'privacy_backoffice_state.dart';

class PrivacyBackofficeCubit extends Cubit<PrivacyBackofficeState> {
  PrivacyBackofficeCubit({required CloudFunctionsService cloudFunctionsService})
    : _cloudFunctionsService = cloudFunctionsService,
      super(const PrivacyBackofficeState());

  final CloudFunctionsService _cloudFunctionsService;

  String get _source {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      default:
        return 'api';
    }
  }

  Future<void> loadRequests() async {
    await _loadRequests(showLoading: true);
  }

  Future<void> setFilter(PrivacyRequestStatus? status) async {
    if (state.selectedStatus == status) {
      return;
    }
    emit(state.copyWith(selectedStatus: status));
    await _loadRequests(showLoading: true);
  }

  Future<void> refresh() async {
    await _loadRequests(showLoading: true);
  }

  Future<void> updateRequestStatus({
    required PrivacyBackofficeRequest request,
    required PrivacyRequestStatus nextStatus,
    String? statusReason,
  }) async {
    if (state.isUpdatingStatus) {
      return;
    }

    if (!request.canTransitionTo(nextStatus)) {
      _emitFeedback(
        'La transición ${request.statusLabel} -> ${nextStatus.label} no está permitida.',
      );
      return;
    }

    emit(state.copyWith(activeRequestKey: request.key, errorMessage: null));

    try {
      final normalizedReason = statusReason?.trim();
      await _cloudFunctionsService.updatePrivacyRequestStatusBackoffice(
        userId: request.userId,
        requestId: request.requestId,
        nextStatus: nextStatus.rawValue,
        statusReason: normalizedReason == null || normalizedReason.isEmpty
            ? null
            : normalizedReason,
        source: _source,
      );

      _emitFeedback(
        'Estado actualizado a ${nextStatus.label} (${request.requestTypeLabel}).',
      );
      await _loadRequests(showLoading: false);
    } catch (error) {
      if (!isClosed) {
        emit(
          state.copyWith(
            errorMessage: 'No pudimos actualizar el estado: $error',
          ),
        );
      }
    } finally {
      if (!isClosed) {
        emit(state.copyWith(activeRequestKey: null));
      }
    }
  }

  Future<void> _loadRequests({required bool showLoading}) async {
    if (showLoading) {
      emit(state.copyWith(isLoading: true, errorMessage: null));
    } else {
      emit(state.copyWith(errorMessage: null));
    }

    try {
      final response = await _cloudFunctionsService
          .listPrivacyRequestsBackoffice(
            status: state.selectedStatus?.rawValue,
          );

      final requests = response
          .map(PrivacyBackofficeRequest.fromMap)
          .where(
            (entry) => entry.userId.isNotEmpty && entry.requestId.isNotEmpty,
          )
          .toList(growable: false);

      if (!isClosed) {
        emit(
          state.copyWith(
            isLoading: false,
            requests: requests,
            errorMessage: null,
          ),
        );
      }
    } catch (error) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'No pudimos cargar las solicitudes: $error',
          ),
        );
      }
    }
  }

  void _emitFeedback(String message) {
    if (isClosed) return;
    emit(
      state.copyWith(
        feedbackMessage: message,
        feedbackVersion: state.feedbackVersion + 1,
      ),
    );
  }
}
