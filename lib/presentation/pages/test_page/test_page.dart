import 'package:ebty/presentation/components/mahfozat/mahfozat.dart';
import 'package:flutter/material.dart';
import 'package:ebty/Model/mahfozat_model.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  late Future<Mahfozat> items;

  @override
  void initState() {
    final Mahfozat mahfozat = Mahfozat();
    items = mahfozat.getMahfozatList();
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
