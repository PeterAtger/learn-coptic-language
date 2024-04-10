import 'package:ebty/presentation/blocs/year/year_state.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class YearCubit extends HydratedCubit<YearState> {
  YearCubit() : super(InitialYear());

  void changeTheme(Years theme) {
    emit(YearState(theme));
  }

  @override
  YearState fromJson(Map<String, dynamic> json) {
    Years year = Years.values.firstWhere(
      (element) => element.toString() == json['year'].toString(),
    );
    YearState initialState = YearState(year);

    return initialState;
  }

  @override
  Map<String, dynamic> toJson(YearState state) {
    return <String, String>{'year': state.year.toString()};
  }
}
