import 'package:flutter/material.dart';
import 'package:flutter_investment_control/models/active_model.dart';
import 'package:flutter_investment_control/pages/active/details/active_details_page.dart';
import 'package:flutter_investment_control/pages/active/active_page.dart';
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
        title: const Text(
          'Ativos de Investimentos',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
      );
    } else {
      return AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
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

  showDetails(Active active) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ActiveDetalisPage(active: active),
      ),
    );
  }

  navigateToWalletPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AssetList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabela = ActiveRepository.tabela;

    return Scaffold(
      appBar: appBarDynamics(),
      bottomNavigationBar: SizedBox(
        height: 70.0,
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _bottomAction(
                  FontAwesomeIcons.clockRotateLeft, navigateToWalletPage),
              _bottomAction(FontAwesomeIcons.chartPie, navigateToWalletPage),
              const SizedBox(width: 48.0),
              _bottomAction(FontAwesomeIcons.wallet, navigateToWalletPage),
              _bottomAction(Icons.settings, navigateToWalletPage),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: selecionadas.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: FloatingActionButton(
                backgroundColor: Colors.grey,
                onPressed: () {},
                shape: const CircleBorder(),
                elevation: 0.0,
                child: const Icon(Icons.add, color: Colors.black),
              ),
            )
          : null,
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
            onTap: () => showDetails(tabela[active]),
          );
        },
        padding: const EdgeInsets.all(16.0),
        separatorBuilder: (_, __) => const Divider(),
        itemCount: tabela.length,
      ),
    );
  }

  Widget _bottomAction(IconData icon, VoidCallback onTap) {
    return InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            color: Colors.grey[900],
            size: 20.0,
          ),
        ));
  }
}
