import 'package:equatable/equatable.dart';

enum PrivacyRequestStatus { pending, inProgress, completed, rejected }

const List<PrivacyRequestStatus> privacyBackofficeFilterStatuses =
    <PrivacyRequestStatus>[
      PrivacyRequestStatus.pending,
      PrivacyRequestStatus.inProgress,
      PrivacyRequestStatus.completed,
      PrivacyRequestStatus.rejected,
    ];

PrivacyRequestStatus? privacyRequestStatusFromRaw(String value) {
  switch (value.trim().toLowerCase()) {
    case 'pending':
      return PrivacyRequestStatus.pending;
    case 'in_progress':
      return PrivacyRequestStatus.inProgress;
    case 'completed':
      return PrivacyRequestStatus.completed;
    case 'rejected':
      return PrivacyRequestStatus.rejected;
    default:
      return null;
  }
}

extension PrivacyRequestStatusX on PrivacyRequestStatus {
  String get rawValue {
    switch (this) {
      case PrivacyRequestStatus.pending:
        return 'pending';
      case PrivacyRequestStatus.inProgress:
        return 'in_progress';
      case PrivacyRequestStatus.completed:
        return 'completed';
      case PrivacyRequestStatus.rejected:
        return 'rejected';
    }
  }

  String get label {
    switch (this) {
      case PrivacyRequestStatus.pending:
        return 'Pendiente';
      case PrivacyRequestStatus.inProgress:
        return 'En curso';
      case PrivacyRequestStatus.completed:
        return 'Completada';
      case PrivacyRequestStatus.rejected:
        return 'Rechazada';
    }
  }

  List<PrivacyRequestStatus> get allowedNextStatuses {
    switch (this) {
      case PrivacyRequestStatus.pending:
        return const <PrivacyRequestStatus>[
          PrivacyRequestStatus.inProgress,
          PrivacyRequestStatus.completed,
          PrivacyRequestStatus.rejected,
        ];
      case PrivacyRequestStatus.inProgress:
        return const <PrivacyRequestStatus>[
          PrivacyRequestStatus.pending,
          PrivacyRequestStatus.completed,
          PrivacyRequestStatus.rejected,
        ];
      case PrivacyRequestStatus.completed:
        return const <PrivacyRequestStatus>[];
      case PrivacyRequestStatus.rejected:
        return const <PrivacyRequestStatus>[
          PrivacyRequestStatus.pending,
          PrivacyRequestStatus.inProgress,
        ];
    }
  }
}

class PrivacyBackofficeRequest extends Equatable {
  const PrivacyBackofficeRequest({
    required this.userId,
    required this.requestId,
    required this.requestType,
    required this.rawStatus,
    required this.source,
    this.reason,
    this.createdAt,
    this.updatedAt,
    this.statusUpdatedAt,
    this.statusUpdatedBy,
    this.statusReason,
  });

  factory PrivacyBackofficeRequest.fromMap(Map<String, Object?> map) {
    final requestId = _stringOrEmpty(map['requestId']);
    return PrivacyBackofficeRequest(
      userId: _stringOrEmpty(map['userId']),
      requestId: requestId,
      requestType: _stringOrEmpty(map['requestType']),
      rawStatus: _stringOrEmpty(map['status']),
      reason: _optionalString(map['reason']),
      source: _stringOrEmpty(map['source']),
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
      statusUpdatedAt: _parseDate(map['statusUpdatedAt']),
      statusUpdatedBy: _optionalString(map['statusUpdatedBy']),
      statusReason: _optionalString(map['statusReason']),
    );
  }

  final String userId;
  final String requestId;
  final String requestType;
  final String rawStatus;
  final String source;
  final String? reason;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? statusUpdatedAt;
  final String? statusUpdatedBy;
  final String? statusReason;

  PrivacyRequestStatus? get status => privacyRequestStatusFromRaw(rawStatus);
  String get statusLabel => status?.label ?? rawStatus;
  String get requestTypeLabel => _requestTypeLabel(requestType);
  List<PrivacyRequestStatus> get allowedNextStatuses =>
      status?.allowedNextStatuses ?? const <PrivacyRequestStatus>[];
  bool canTransitionTo(PrivacyRequestStatus nextStatus) =>
      allowedNextStatuses.contains(nextStatus);
  String get key => '$userId/$requestId';

  PrivacyBackofficeRequest copyWith({
    String? rawStatus,
    DateTime? statusUpdatedAt,
    String? statusUpdatedBy,
    Object? statusReason = _unset,
  }) {
    return PrivacyBackofficeRequest(
      userId: userId,
      requestId: requestId,
      requestType: requestType,
      rawStatus: rawStatus ?? this.rawStatus,
      reason: reason,
      source: source,
      createdAt: createdAt,
      updatedAt: updatedAt,
      statusUpdatedAt: statusUpdatedAt ?? this.statusUpdatedAt,
      statusUpdatedBy: statusUpdatedBy ?? this.statusUpdatedBy,
      statusReason: identical(statusReason, _unset)
          ? this.statusReason
          : statusReason as String?,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    userId,
    requestId,
    requestType,
    rawStatus,
    reason,
    source,
    createdAt,
    updatedAt,
    statusUpdatedAt,
    statusUpdatedBy,
    statusReason,
  ];
}

const Object _unset = Object();

String _requestTypeLabel(String rawType) {
  switch (rawType.trim().toLowerCase()) {
    case 'data_export':
      return 'Exportación de datos';
    case 'account_deletion':
      return 'Eliminación de cuenta';
    case 'access':
      return 'Acceso';
    case 'rectification':
      return 'Rectificación';
    case 'erasure':
      return 'Supresión';
    case 'restriction':
      return 'Limitación';
    case 'portability':
      return 'Portabilidad';
    case 'objection':
      return 'Oposición';
    default:
      return rawType.isEmpty ? 'Sin tipo' : rawType;
  }
}

String _stringOrEmpty(Object? value) => value is String ? value : '';

String? _optionalString(Object? value) {
  if (value is! String) return null;
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

DateTime? _parseDate(Object? value) {
  if (value is! String) return null;
  return DateTime.tryParse(value);
}
