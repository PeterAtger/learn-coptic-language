import 'package:ebty/Model/audio_model.dart';
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
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<YearCubit, YearState>(
      builder: (context, state) {
        if (state.loading) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return renderData(state.mahfozat);
        }
      },
    );
  }

  Widget renderData(Mahfozat? data) {
    Years year = context.read<YearCubit>().state.year;

    if (data == null) {
      return const SizedBox(
        child: Text('No data'),
      );
    }

    List<FlatMahfozatItem> flatItems = Mahfozat.toFlatList(data);

    return MahfozatList(
      items: flatItems,
      audioFolder: audioFolderMap[year] ?? "",
    );
  }
}
