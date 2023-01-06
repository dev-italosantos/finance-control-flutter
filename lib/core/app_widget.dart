import 'package:flutter/material.dart';
import 'package:flutter_investment_control/pages/home_page.dart';
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
          bodyText1: const TextStyle(color: Colors.blueAccent),
          bodyText2: const TextStyle(color: Colors.blueAccent),
        ),
      ),
      debugShowCheckedModeBanner: false,
      title: 'Portfólio Dev Italo Santos',
      home: HomePage(),
    );;
  }
}
