import 'package:flutter/material.dart';
import 'package:flutter_investment_control/core/app_colors.dart';

class Onboarding extends StatelessWidget {
  const Onboarding({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: const Color(0xFFEEF8F7),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
