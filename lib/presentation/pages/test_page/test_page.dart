import 'package:ebty/Model/rules_model.dart';
import 'package:ebty/presentation/blocs/year/year_cubit.dart';
import 'package:ebty/presentation/blocs/year/year_state.dart';
import 'package:ebty/presentation/components/rules/rules_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
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
