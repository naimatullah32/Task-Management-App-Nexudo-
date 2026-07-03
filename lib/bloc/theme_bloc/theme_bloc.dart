import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/storage/local_storage.dart';
import 'package:flutter/material.dart';
import 'theme_event.dart'; // Make sure these exist
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final LocalStorage _localStorage;

  // Constructor me LocalStorage lazmi hona chahiye
  ThemeBloc(this._localStorage) : super(const ThemeState(ThemeMode.system)) {
    on<LoadThemeEvent>(_onLoadTheme);
    on<ToggleThemeEvent>(_onToggleTheme);
  }

  void _onLoadTheme(LoadThemeEvent event, Emitter<ThemeState> emit) async {
    // Local storage se theme load karne ki logic
  }

  void _onToggleTheme(ToggleThemeEvent event, Emitter<ThemeState> emit) {
    // Theme switch karne ki logic
  }
}