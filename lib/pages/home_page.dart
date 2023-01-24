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
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon),
      ),
      onTap: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        notchMargin: 8.0,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _bottomAction(FontAwesomeIcons.history),
            _bottomAction(FontAwesomeIcons.chartPie),
            const SizedBox(width: 48.0),
            _bottomAction(FontAwesomeIcons.wallet),
            _bottomAction(Icons.settings),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {},
      ),
      body: _body(),
    );
  }

  Widget _body() {
    return SafeArea(
      child: Column(
        children: [
          _selector(),
          _expenses(),
          _graph(),
          _list(),
        ],
      ),
    );
  }

  Widget _selector() {
    return Container();
  }

  Widget _graph() {
    return Container();
  }

  Widget _list() {
    return Container();
  }

  Widget _expenses() {
    return Column(
      children: const [
        Text(
          "\$10250,55",
          style: TextStyle(
            fontSize: 40.0,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
        Text(
          "Total expenses",
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        )
      ],
    );
  }
}
