import 'package:ebty/Model/rules_model.dart';
import 'package:ebty/presentation/blocs/year/year_cubit.dart';
import 'package:ebty/presentation/blocs/year/year_state.dart';
import 'package:ebty/presentation/components/rules/rules_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RulesPage extends StatefulWidget {
  const RulesPage({super.key});

  @override
  State<RulesPage> createState() => _RulesPageState();
}

class _RulesPageState extends State<RulesPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<YearCubit, YearState>(
      builder: (context, state) {
        if (state.loading) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return renderData(state.rules);
        }
      },
    );
  }

  Widget renderData(Rules? data) {
    if (data == null) {
      return const SizedBox(
        child: Text('No data'),
      );
    }

    List<FlatRuleItem> flatItems = Rules.toFlatList(data);

    return RulesList(
      items: flatItems,
    );
  }
}
