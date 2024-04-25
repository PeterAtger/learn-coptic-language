import 'package:ebty/Model/mahfozat_model.dart';
import 'package:ebty/Model/words_model.dart';
import 'package:ebty/presentation/blocs/year/year_state.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class YearCubit extends HydratedCubit<YearState> {
  YearCubit() : super(InitialYear());

  void changeYear(Years year) {
    emit(YearState(year: year, loading: true));
    loadData();
  }

  void loadData() async {
    final Years year = state.year;
    final Words words = Words(year: year);
    final Mahfozat mahfozat = Mahfozat(year: year);
    await words.getWordsList();
    await mahfozat.getMahfozatList();

    emit(YearState(
      year: year,
      words: words,
      mahfozat: mahfozat,
      loading: false,
    ));
  }

  @override
  YearState fromJson(Map<String, dynamic> json) {
    Years year = Years.values.firstWhere(
      (element) => element.toString() == json['year'].toString(),
    );
    YearState initialState = YearState(year: year, loading: true);

    return initialState;
  }

  @override
  Map<String, dynamic> toJson(YearState state) {
    return <String, String>{'year': state.year.toString()};
  }
}
