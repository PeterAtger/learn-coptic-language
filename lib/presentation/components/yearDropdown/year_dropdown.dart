import 'package:ebty/presentation/blocs/year/year_cubit.dart';
import 'package:ebty/presentation/blocs/year/year_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const Map<Years, String> yearDisplayMap = {
  Years.kg: 'حضانة',
  Years.primary_1: 'اولى وتانية',
  Years.primary_3: 'تالتة و رابعة',
  Years.primary_5: 'خامسة و سادسة',
  Years.preparatory: 'اعدادي',
  Years.secondary: 'ثانوي',
  Years.college: 'جامعة وخريجين',
  Years.servants: 'خدام واعداد خدام'
};

final List<String> list = yearDisplayMap.values.toList();

class YearDropdown extends StatefulWidget {
  const YearDropdown({super.key});

  @override
  State<YearDropdown> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<YearDropdown> {
  String dropdownValue = list.first;

  String getYearFromState({required Years theme}) {
    return yearDisplayMap[theme].toString();
  }

  Years getStateFromYear({required String year}) {
    Years result =
        yearDisplayMap.keys.firstWhere((key) => yearDisplayMap[key] == year);

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10)),
        child: BlocBuilder<YearCubit, YearState>(
          builder: (context, state) {
            final String data = getYearFromState(theme: state.year);
            return DropdownButton<String>(
              value: data,
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              dropdownColor: Colors.white,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              style: const TextStyle(color: Colors.black, fontSize: 16),
              underline: const SizedBox(),
              onChanged: (String? value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  context
                      .read<YearCubit>()
                      .changeYear(getStateFromYear(year: value));
                });
              },
              items: list.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
