import 'package:flutter/material.dart';
import 'package:flutter_investment_control/pages/splash/splash_page.dart';
import 'package:google_fonts/google_fonts.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black12,
        canvasColor: Colors.black26,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
            .apply(bodyColor: Colors.white)
            .copyWith(
          bodyLarge: const TextStyle(color: Colors.blueAccent),
          bodyMedium: const TextStyle(color: Colors.blueAccent),
        ),
      ),
      debugShowCheckedModeBanner: false,
      title: 'Moedas Base',
      home: const SplashPage(),
    );
  }
}
