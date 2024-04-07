import 'package:ebty/presentation/blocs/theme/theme_cubit.dart';
import 'package:ebty/presentation/blocs/theme/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const Map<Themes, String> mapTheme = {
  Themes.kg: 'حضانة',
  Themes.primary_1: 'أولى و تانية',
  Themes.primary_3: 'تالتة و رابعة',
  Themes.primary_5: 'خامسة و سادسة',
  Themes.preparatory: 'اعدادي',
  Themes.secondary: 'ثانوي'
};

final List<String> list = mapTheme.values.toList();

class YearDropdown extends StatefulWidget {
  const YearDropdown({super.key});

  @override
  State<YearDropdown> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<YearDropdown> {
  String dropdownValue = list.first;

  String getYearFromTheme({required Themes theme}) {
    return mapTheme[theme].toString();
  }

  Themes getThemeFromYear({required String year}) {
    switch (year) {
      case "حضانة":
        return Themes.kg;
      case "أولى و تانية":
        return Themes.primary_1;
      case "تالتة و رابعة":
        return Themes.primary_3;
      case "خامسة و سادسة":
        return Themes.primary_5;
      case "اعدادي":
        return Themes.preparatory;
      case "ثانوي":
        return Themes.secondary;

      default:
        return Themes.kg;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10)),
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          final String data = getYearFromTheme(theme: state.theme);

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
                    .read<ThemeCubit>()
                    .changeTheme(getThemeFromYear(year: value));
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
    );
  }
}
