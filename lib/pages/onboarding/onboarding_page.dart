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
            child: Image.asset('assets/images/brazuca_browsing.png'),
          ),
          const Text(
            "spend smarter",
            style: TextStyle(
              fontSize: 36.0,
              fontWeight: FontWeight.w700,
              color: Color(0xFF438883),
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
