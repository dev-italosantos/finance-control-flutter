import 'package:flutter/material.dart';
import 'package:flutter_investment_control/services/asset_provider.dart';
import 'package:provider/provider.dart';
import 'core/app_widget.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AssetProvider(),
      child: const AppWidget(),
    ),
  );
}