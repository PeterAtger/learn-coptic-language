import 'package:flutter/material.dart';

class ShenoudaText extends StatelessWidget {
  const ShenoudaText({super.key, this.text = ""});
  final String text;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Text(
      text,
      style: const TextStyle(fontFamily: 'Avva_Shenouda'),
    );
  }
}
