import 'package:ebty/Model/rules_model.dart';
import 'package:flutter/material.dart';

class RulesList extends StatefulWidget {
  final List<FlatRuleItem> items;
  final String imageLocation = "assets/images/Grammar/";

  const RulesList({super.key, this.items = const []});

  @override
  State<RulesList> createState() => _RulesListState();
}

class _RulesListState extends State<RulesList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
        itemCount: widget.items.length,
        itemBuilder: (BuildContext ctx, int index) {
          FlatRuleItem item = widget.items[index];
          if (item.type == RuleTypes.rule) {
            return item.shouldScale == true
                ? renderSmallItem(item.item as Rule)
                : renderItem(item.item as Rule);
          }
          if (item.type == RuleTypes.example) {
            return renderExample(item.item as Example);
          }
          if (item.type == RuleTypes.level) {
            return renderLevel(item.item as RulesLevel, index == 0);
          }

          return const SizedBox();
        });
  }

  Widget renderExample(Example example) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Material(
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            child: OutlinedButton(
              style: ButtonStyle(
                  padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16))),
              onPressed: null,
              child: Image.asset(
                widget.imageLocation + example.example,
                fit: BoxFit.fill,
              ),
            )),
      ),
    );
  }

  Widget renderSmallItem(Rule item) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Material(
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            child: OutlinedButton(
              style: ButtonStyle(
                  padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16))),
              onPressed: null,
              child: Image.asset(
                widget.imageLocation + item.rule,
                fit: BoxFit.fill,
              ),
            )),
      ),
    );
  }

  Widget renderItem(Rule item) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Material(
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            child: OutlinedButton(
              onPressed: null,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(16),
                child: Image.asset(
                  widget.imageLocation + item.rule,
                  fit: BoxFit.fill,
                ),
              ),
            )),
      ),
    );
  }

  Widget renderLevel(RulesLevel level, bool isFirst) {
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
