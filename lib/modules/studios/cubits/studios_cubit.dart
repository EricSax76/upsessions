import 'my_studio_cubit.dart';

/// Legacy alias kept for temporary compatibility while migrating to
/// role-specific cubits.
@Deprecated(
  'Use MyStudioCubit, StudiosListCubit, BookingsCubit or StudioMediaCubit.',
)
typedef StudiosCubit = MyStudioCubit;
