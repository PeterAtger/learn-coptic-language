import 'package:ebty/presentation/blocs/theme/theme_state.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ThemeCubit extends HydratedCubit<ThemeState> {
  ThemeCubit() : super(InitialTheme());

  void changeTheme(Themes theme) {
    emit(ThemeState(theme));
  }

  @override
  ThemeState fromJson(Map<String, dynamic> json) {
    return ThemeState(json['theme'] as Themes);
  }

  @override
  Map<String, dynamic> toJson(ThemeState state) {
    return <String, String>{'theme': state.theme.toString()};
  }
}
