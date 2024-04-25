import 'package:ebty/Model/mahfozat_model.dart';
import 'package:ebty/Model/words_model.dart';

enum Years { kg, primary_1, primary_3, primary_5, preparatory, secondary }

class YearState {
  final Years year;
  final bool loading;
  final Words? words;
  final Mahfozat? mahfozat;

  YearState(
      {required this.year, this.words, this.mahfozat, required this.loading});
}

class InitialYear extends YearState {
  InitialYear() : super(year: Years.kg, loading: true);
}
