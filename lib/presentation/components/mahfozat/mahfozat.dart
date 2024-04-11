import 'package:ebty/Model/mahfozat_model.dart';
import 'package:flutter/material.dart';

class MahfozatList extends StatefulWidget {
  final List<FlatMahfozatItem> items;

  const MahfozatList({super.key, this.items = const []});

  @override
  State<MahfozatList> createState() => _MahfozatListState();
}

class _MahfozatListState extends State<MahfozatList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
        itemCount: widget.items.length,
        itemBuilder: (BuildContext ctx, int index) {
          if (widget.items[index].type == MahfozatTypes.item) {
            return renderItem(widget.items[index].item as MahfozatItem);
          }
          if (widget.items[index].type == MahfozatTypes.group) {
            return renderGroup(widget.items[index].item as MahfozatGroup);
          }
          if (widget.items[index].type == MahfozatTypes.level) {
            return renderLevel(
                widget.items[index].item as MahfozatLevel, index == 0);
          }

          return const SizedBox();
        });
  }

  Widget renderGroup(MahfozatGroup group) {
    return Container(
      padding: const EdgeInsets.all(5),
      child: Center(
        child: Text(
          group.name,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget renderItem(MahfozatItem item) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(minWidth: 200, maxWidth: 800),
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Material(
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            child: OutlinedButton(
              onPressed: () => {},
              child: Container(
                  alignment: Alignment.center,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Column(children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        item.coptic,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                          fontFamily: 'Avva_Shenouda',
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        item.arabic,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black),
                      ),
                    ),
                  ])),
            )),
      ),
    );
  }

  Widget renderLevel(MahfozatLevel level, bool isFirst) {
    return Column(
      children: [
        !isFirst
            ? Container(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: const Divider(
                      color: Colors.black,
                      thickness: 2,
                      indent: 16,
                      endIndent: 16,
                    ),
                  ),
                ),
              )
            : const SizedBox(),
        Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 200),
            padding: const EdgeInsets.symmetric(vertical: 8),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
                color: Theme.of(context).dialogBackgroundColor,
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    spreadRadius: 0.0,
                    offset: Offset(2.0, 2.0), // shadow direction: bottom right
                  )
                ]),
            child: Center(
              child: Text(level.level,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  )),
            ),
          ),
        ),
      ],
    );
  }
}
