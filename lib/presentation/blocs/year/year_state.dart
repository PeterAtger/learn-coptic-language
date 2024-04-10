enum Years { kg, primary_1, primary_3, primary_5, preparatory, secondary }

class YearState {
  final Years year;

  YearState(this.year);
}

class InitialYear extends YearState {
  InitialYear() : super(Years.kg);
}
