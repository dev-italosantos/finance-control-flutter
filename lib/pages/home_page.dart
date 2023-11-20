import 'package:flutter/material.dart';
import 'package:flutter_investment_control/models/active_model.dart';
import 'package:flutter_investment_control/repositories/active_repository.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Active> selecionadas = [];
  NumberFormat real = NumberFormat.currency(locale: 'pt-br', name: 'R\$');


  appBarDynamics() {
    if (selecionadas.isEmpty) {
        return AppBar(
          title: const Text('Ativos de Investimentos'),
          backgroundColor: Colors.black,
        );
    } else {
      return AppBar(
        backgroundColor: Colors.black,
        leading:  IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              selecionadas = [];
            });
          },
        ),
        title: Text('${selecionadas.length} selecionadas'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabela = ActiveRepository.tabela;

    return Scaffold(
      appBar: appBarDynamics(),
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
          bool isSelected = selecionadas.contains(tabela[active]);

          return ListTile(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(12),
              ),
            ),
            leading: isSelected
                ? const CircleAvatar(
              child: Icon(Icons.check),
            )
                : SizedBox(
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
            trailing: Text(
              real.format(tabela[active].price),
            ),
            selected: isSelected,
            tileColor: isSelected ? Colors.red : null,
            onLongPress: () {
              setState(() {
                isSelected
                    ? selecionadas.remove(tabela[active])
                    : selecionadas.add(tabela[active]);
              });
            },
          );
        },
        padding: const EdgeInsets.all(16.0),
        separatorBuilder: (_, __) => const Divider(),
        itemCount: tabela.length,
      ),
    );
  }

  Widget _bottomAction(IconData icon) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon),
      ),
      onTap: () {},
    );
  }
}
