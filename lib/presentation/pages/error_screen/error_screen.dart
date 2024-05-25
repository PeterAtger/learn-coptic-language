import 'package:ebty/presentation/theme/theme.dart';
import 'package:flutter/material.dart';

class ErorrScreen extends StatelessWidget {
  const ErorrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.errorColor,
      body: Center(
        child: SizedBox(
          width: size.width * 0.8,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error,
                size: 72,
              ),
              SizedBox(
                height: 36,
              ),
              Text('فيه حاجة غلط حصلت مش متأكد هى ايه')
            ],
          ),
        ),
      ),
    );
  }
}
