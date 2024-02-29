import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_investment_control/core/app_icons.dart';
import 'package:flutter_investment_control/models/active_model.dart';
import 'package:flutter_investment_control/pages/active/details/active_details_page.dart';
import 'package:flutter_investment_control/pages/active/active_page.dart';
import 'package:flutter_investment_control/services/api_stocks_indicators.dart';
import 'package:flutter_investment_control/widgets/btc/bitcoin_card_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

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

  AppBar appBarDynamics() {
    if (selecionadas.isEmpty) {
      return AppBar(
        title: Text(
          'Home',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications, // Ícone de notificação
              color: Colors.white,
              size: 20.0,
            ),
            onPressed: () {
              // Adicione aqui a ação desejada para o ícone de notificação
            },
          ),
        ],
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
          // Seção de Notícias
          Align(
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
                  child: Text(
                    'New',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: stockIndicators.isEmpty // Verifica se os dados estão vazios
                      ? Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: 5, // Define um valor fixo para o shimmer
                      itemBuilder: (_, __) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Container(), // Container vazio para o efeito shimmer
                        ),
                      ),
                    ),
                  )
                      : PageView.builder(
                    controller: _controller,
                    itemCount: newsList.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                                      return const Center(
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
                                    borderRadius: const BorderRadius.only(
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
              ],
            ),
          ),
          // Seção de Indicadores de Ações
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
                  child: const Text(
                    'Stocks',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Expanded(
                  child: FutureBuilder(
                    future: Future.delayed(Duration(seconds: 3), () {}),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // Exibe shimmer enquanto aguarda
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: ListView.separated(
                            itemBuilder: (_, __) => Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Container(
                                height: 24.0, // Altura do shimmer
                                color: Colors.white, // Cor do shimmer
                              ),
                            ),
                            separatorBuilder: (_, __) => const Divider(),
                            itemCount: 10, // Define um valor para o shimmer
                          ),
                        );
                      } else {
                        // Exibe o conteúdo após o carregamento
                        return ListView.separated(
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
                          itemCount: stockIndicators.length,
                        );
                      }
                    },
                  ),
                ),
              ],
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