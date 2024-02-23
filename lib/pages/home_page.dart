import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_investment_control/core/app_icons.dart';
import 'package:flutter_investment_control/models/active_model.dart';
import 'package:flutter_investment_control/pages/active/details/active_details_page.dart';
import 'package:flutter_investment_control/pages/active/active_page.dart';
import 'package:flutter_investment_control/repositories/active_repository.dart';
import 'package:flutter_investment_control/services/api_stocks_indicators.dart';
import 'package:flutter_investment_control/widgets/btc/bitcoin_card_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

// class _HomePageState extends State<HomePage> {
//   List<Active> selecionadas = [];
//   NumberFormat real = NumberFormat.currency(locale: 'pt-br', name: 'R\$');
//
//   appBarDynamics() {
//     if (selecionadas.isEmpty) {
//       return AppBar(
//         title: const Text(
//           'Ativos de Investimentos',
//           style: TextStyle(
//             fontSize: 16,
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: Colors.black,
//       );
//     } else {
//       return AppBar(
//         backgroundColor: Colors.black,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             setState(() {
//               selecionadas = [];
//             });
//           },
//         ),
//         title: Text('${selecionadas.length} selecionadas'),
//       );
//     }
//   }
//
//   showDetails(Active active) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => ActiveDetalisPage(active: active),
//       ),
//     );
//   }
//
//   navigateToWalletPage() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => const AssetList(),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final tabela = ActiveRepository.tabela;
//
//     return Scaffold(
//       appBar: appBarDynamics(),
//       bottomNavigationBar: SizedBox(
//         height: 70.0,
//         child: BottomAppBar(
//           shape: const CircularNotchedRectangle(),
//           child: Row(
//             mainAxisSize: MainAxisSize.max,
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _bottomAction(
//                   FontAwesomeIcons.clockRotateLeft, navigateToWalletPage),
//               _bottomAction(FontAwesomeIcons.chartPie, navigateToWalletPage),
//               const SizedBox(width: 48.0),
//               _bottomAction(FontAwesomeIcons.wallet, navigateToWalletPage),
//               _bottomAction(Icons.settings, navigateToWalletPage),
//             ],
//           ),
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//       floatingActionButton: selecionadas.isNotEmpty
//           ? Padding(
//               padding: const EdgeInsets.only(bottom: 16.0),
//               child: FloatingActionButton(
//                 backgroundColor: Colors.grey,
//                 onPressed: () {},
//                 shape: const CircleBorder(),
//                 elevation: 0.0,
//                 child: const Icon(Icons.add, color: Colors.black),
//               ),
//             )
//           : null,
//       body: ListView.separated(
//         itemBuilder: (BuildContext context, int active) {
//           bool isSelected = selecionadas.contains(tabela[active]);
//
//           return ListTile(
//             shape: const RoundedRectangleBorder(
//               borderRadius: BorderRadius.all(
//                 Radius.circular(12),
//               ),
//             ),
//             leading: isSelected
//                 ? const CircleAvatar(
//                     child: Icon(Icons.check),
//                   )
//                 : SizedBox(
//                     width: 40.0,
//                     child: Image.asset(tabela[active].icon),
//                   ),
//             title: Text(
//               tabela[active].name,
//               style: const TextStyle(
//                 color: Colors.black54,
//                 fontSize: 17.0,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             trailing: Text(
//               real.format(tabela[active].price),
//             ),
//             selected: isSelected,
//             tileColor: isSelected ? Colors.red : null,
//             onLongPress: () {
//               setState(() {
//                 isSelected
//                     ? selecionadas.remove(tabela[active])
//                     : selecionadas.add(tabela[active]);
//               });
//             },
//             onTap: () => showDetails(tabela[active]),
//           );
//         },
//         padding: const EdgeInsets.all(16.0),
//         separatorBuilder: (_, __) => const Divider(),
//         itemCount: tabela.length,
//       ),
//     );
//   }
//
//   Widget _bottomAction(IconData icon, VoidCallback onTap) {
//     return InkWell(
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Icon(
//             icon,
//             color: Colors.grey[900],
//             size: 20.0,
//           ),
//         ));
//   }
// }

class _HomePageState extends State<HomePage> {
  List<Active> selecionadas = [];
  NumberFormat real = NumberFormat.currency(locale: 'pt-br', name: 'R\$');

  StockIndicatorsApi api = StockIndicatorsApi();
  List<dynamic> stockIndicators = [];


  final PageController _controller = PageController();
  int _currentPage = 0;
  final List<Map<String, dynamic>> newsList = [
    {
      "title": "Bitcoin reaches new all-time high!",
      "image": "https://www.cointribune.com/app/uploads/2024/02/bitcoin-proces-Australien-2.png",
    },
    {
      "title": "Major companies now accepting Bitcoin as payment",
      "image": "https://www.cointribune.com/app/uploads/2024/02/bitcoin-proces-Australien-2.png",
    },
    {
      "title": "Bitcoin price analysis: Is it the right time to invest?",
      "image": "https://www.cointribune.com/app/uploads/2024/02/bitcoin-proces-Australien-2.png",
    },
    {
      "title": "Government regulations shake up the Bitcoin market",
      "image": "https://www.cointribune.com/app/uploads/2024/02/bitcoin-proces-Australien-2.png",
    },
    {
      "title": "Top 5 Bitcoin wallets for secure storage",
      "image": "https://www.cointribune.com/app/uploads/2024/02/bitcoin-proces-Australien-2.png",
    },
  ];

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (_currentPage < newsList.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _controller.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
    fetchData();
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  fetchData() async {
    var data = await api.fetchStockIndicators();
    setState(() {
      stockIndicators = data;
    });
  }

  appBarDynamics() {
    if (selecionadas.isEmpty) {
      return AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ativos de Investimentos',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            Icon(
              Icons.notifications, // Ícone de notificação
              color: Colors.white,
              size: 20.0,
            ),
          ],
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

  navigateToBtcPage() {
    final List<String> newsList = [
      "Bitcoin reaches new all-time high!",
      "Major companies now accepting Bitcoin as payment",
      "Bitcoin price analysis: Is it the right time to invest?",
      "Government regulations shake up the Bitcoin market",
      "Top 5 Bitcoin wallets for secure storage",
    ];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BitcoinCard(),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
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
              _bottomAction(Icons.settings, navigateToBtcPage),
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
      body: Column(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: 200,
              child: PageView.builder(
                controller: _controller,
                itemCount: newsList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Stack(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16.0),
                              child: Image.network(
                                newsList[index]['image'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(Icons.error),
                                  );
                                },
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(16.0),
                                  bottomRight: Radius.circular(16.0),
                                ),
                                color: Colors.black.withOpacity(0.6),
                              ),
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                newsList[index]['title'],
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16.0, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded( // Wrap your ListView.separated with Expanded
            child: ListView.separated(
              itemBuilder: (BuildContext context, int active) {
                bool isSelected = selecionadas.contains(stockIndicators[active]);

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
                    child: Image.asset(AppIcons.btc),
                  ),
                  title: Text(
                    stockIndicators[active]['symbol'],
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 17.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Text(
                    real.format(stockIndicators[active]['lastPrice']),
                  ),
                  selected: isSelected,
                  tileColor: isSelected ? Colors.red : null,
                  onLongPress: () {
                    setState(() {
                      isSelected
                          ? selecionadas.remove(stockIndicators[active])
                          : selecionadas.add(stockIndicators[active]);
                    });
                  },
                  onTap: () => showDetails(stockIndicators[active]),
                );
              },
              padding: const EdgeInsets.all(16.0),
              separatorBuilder: (_, __) => const Divider(),
              itemCount:  stockIndicators.length,
            ),
          ),
        ],
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