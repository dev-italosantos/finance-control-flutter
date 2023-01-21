import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  // Future<String> getData() async {
  //   var url = Uri.https('https://api.b3.com.br/b3api/api/v1/ativos', '');
  //   var response = await http.get(url);
  //
  //   return response.body;
  // }
  //
  // void mainTest() async {
  //   var data = await getData();
  //   print(data);
  // }

  Widget _bottomAction(IconData icon) {
    return InkWell(
      child: Icon(icon),
      onTap: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       bottomNavigationBar: BottomAppBar(
         child: Row(
           children: [
             _bottomAction()
           ],
         ),
       ),
    );
  }
}
