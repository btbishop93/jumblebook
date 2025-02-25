import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState()) {
    on<ChangeThemeEvent>(_onChangeTheme);
  }

  void _onChangeTheme(ChangeThemeEvent event, Emitter<ThemeState> emit) {
    emit(state.copyWith(themeMode: event.themeMode));
  }
}
