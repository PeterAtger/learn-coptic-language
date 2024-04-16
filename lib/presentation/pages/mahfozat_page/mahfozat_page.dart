import 'package:ebty/presentation/blocs/year/year_cubit.dart';
import 'package:ebty/presentation/blocs/year/year_state.dart';
import 'package:ebty/presentation/components/mahfozat/mahfozat.dart';
import 'package:flutter/material.dart';
import 'package:ebty/Model/mahfozat_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MahfozatPage extends StatefulWidget {
  const MahfozatPage({super.key});

  @override
  State<MahfozatPage> createState() => _MahfozatPageState();
}

class _MahfozatPageState extends State<MahfozatPage> {
  late Future<Mahfozat> items;
  late Map<Years, Mahfozat> memo = {};

  Future<Mahfozat> getMahfozat(Years year) async {
    if (memo.containsKey(year)) {
      return memo[year]!;
    }

    Mahfozat mahfozat = Mahfozat(year: year);
    await mahfozat.getMahfozatList();

    memo[year] = mahfozat;

    return mahfozat;
  }

  @override
  void initState() {
    Years year = context.read<YearCubit>().state.year;
    items = getMahfozat(year);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: items,
        builder: (BuildContext context, AsyncSnapshot<Mahfozat> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return renderData(snapshot.data);
        });
  }

  Widget renderData(Mahfozat? data) {
    if (data == null) {
      return const SizedBox(
        child: Text('No data'),
      );
    }

    List<FlatMahfozatItem> flatItems = Mahfozat.toFlatList(data);

    return MahfozatList(items: flatItems);
  }
}
