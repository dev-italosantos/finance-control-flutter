import 'package:flutter/material.dart';
import 'package:flutter_investment_control/repositories/active_repository.dart';
import 'package:flutter_investment_control/widgets/graph_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

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
    final tabela = ActiveRepository.tabela;
    NumberFormat real = NumberFormat.currency(locale: 'pt-br', name: 'R\$');
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        notchMargin: 8.0,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _bottomAction(FontAwesomeIcons.clockRotateLeft),
            _bottomAction(FontAwesomeIcons.chartPie),
            const SizedBox(width: 48.0),
            _bottomAction(FontAwesomeIcons.wallet),
            _bottomAction(Icons.settings),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(150, 150, 150, 1.0),
        child: const Icon(Icons.add),
        onPressed: () {},
      ),
      body: ListView.separated(
        itemBuilder: (BuildContext context, int active) {
          return ListTile(
            leading: SizedBox(
              width: 40.0,
              child: Image.asset(tabela[active].icon),
            ),
            title: Text(
              tabela[active].name,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 17.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Text(real.format(tabela[active].price)),
          );
        },
        padding: const EdgeInsets.all(16.0),
        separatorBuilder: (_, __) => const Divider(),
        itemCount: tabela.length,
      ),
    );
  }

  Widget _body() {
    return SafeArea(
      child: Column(
        children: [
          _selector(),
          _expenses(),
          // _graph(),
          // _list(),
        ],
      ),
    );
  }

  Widget _selector() {
    return Container();
  }

  Widget _graph() {
    return const SizedBox(
      height: 250.0,
      child: GraphWidget(),
    );
  }

  // Widget _list() {
  //   final tabela = ActiveRepository.tabela;
  //   return ListView.separated(
  //     itemBuilder: (BuildContext context, int active) {
  //       return ListTile(
  //         leading: Image.asset(tabela[active].icon),
  //         title: Text(tabela[active].name),
  //         trailing: Text(tabela[active].price.toString()),
  //       );
  //     },
  //     padding: const EdgeInsets.all(16.0),
  //     separatorBuilder: (_, __) => const Divider(),
  //     itemCount: tabela.length,
  //   );
  // }

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
