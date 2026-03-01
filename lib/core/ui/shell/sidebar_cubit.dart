import 'package:flutter_bloc/flutter_bloc.dart';

class SidebarCubit extends Cubit<bool> {
  SidebarCubit() : super(false); // false = expanded, true = collapsed

  void toggle() => emit(!state);
  void setCollapsed(bool isCollapsed) => emit(isCollapsed);
}
