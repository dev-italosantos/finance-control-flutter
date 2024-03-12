// import 'package:flutter/material.dart';
// import 'package:flutter_investment_control/models/active_model.dart';
// import 'package:flutter_investment_control/services/api_stock_indicators.dart';
// import 'package:flutter_investment_control/services/api_stocks_historicals.dart';
// import 'package:intl/intl.dart';
//
// class ActiveDetailsPage extends StatefulWidget {
//   final Active active;
//
//   ActiveDetailsPage({Key? key, required this.active}) : super(key: key);
//
//   @override
//   _ActiveDetailsPageState createState() => _ActiveDetailsPageState();
// }
//
// class _ActiveDetailsPageState extends State<ActiveDetailsPage> {
//   NumberFormat real = NumberFormat.currency(locale: 'pt-br', name: 'R\$');
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchStockIndicators(); // Chama a função para buscar os indicadores ao iniciar a página
//   }
//
//   Map<String, dynamic>? _stockIndicators;
//
//   Future<List<double>> _calculateReturns() async {
//     try {
//       // Get historical prices from the API response
//       final response =
//       await StocksHistoricals().getStockHistoricals(widget.active.symbol);
//
//       if (response != null) {
//         List<dynamic> historicals = response['historicals'] as List<dynamic>;
//
//         // Obter a data de hoje e o primeiro dia do mês passado
//         DateTime now = DateTime.now();
//         DateTime firstDayOfLastMonth = DateTime(now.year, now.month - 1, 1);
//
//         // Filtrar os preços para o último mês
//         List<double> pricesLastMonth = historicals
//             .where((historical) {
//           DateTime date = DateTime.parse(historical['date']);
//           return date.isAfter(
//               firstDayOfLastMonth.subtract(Duration(days: 1))) &&
//               date.isBefore(now);
//         })
//             .map<double>(
//                 (historical) => double.parse(historical['close'].toString()))
//             .toList();
//
//         // Verificar se há preços disponíveis para o último mês
//         double returnLastMonth = 0.0;
//         if (pricesLastMonth.isNotEmpty) {
//           // Obter o primeiro e o último preço de fechamento disponíveis
//           double firstDayClosingPrice = pricesLastMonth.first;
//           double lastDayClosingPrice = pricesLastMonth.last;
//
//           // Calcular a rentabilidade para o último mês
//           returnLastMonth = ((lastDayClosingPrice - firstDayClosingPrice) /
//               firstDayClosingPrice) *
//               100;
//         }
//
//         // Calcular a rentabilidade para os últimos 12 meses
//         DateTime twelveMonthsAgo = DateTime.now().subtract(Duration(days: 365));
//         List<double> pricesLast12Months = historicals
//             .where((historical) {
//           DateTime date = DateTime.parse(historical['date']);
//           return date.isAfter(twelveMonthsAgo.subtract(Duration(days: 1)));
//         })
//             .map<double>(
//                 (historical) => double.parse(historical['close'].toString()))
//             .toList();
//
//         double returnLast12Months = 0.0;
//         if (pricesLast12Months.isNotEmpty) {
//           // Obter o primeiro e o último preço de fechamento dos últimos 12 meses
//           double firstPriceLast12Months = pricesLast12Months.first;
//           double lastPriceLast12Months = pricesLast12Months.last;
//
//           // Calcular a rentabilidade dos últimos 12 meses
//           returnLast12Months =
//               ((lastPriceLast12Months - firstPriceLast12Months) /
//                   firstPriceLast12Months) *
//                   100;
//         }
//
//         return [returnLastMonth, returnLast12Months];
//       } else {
//         throw Exception('Failed to load historical prices');
//       }
//     } catch (e) {
//       print('Error calculating returns: $e');
//       throw Exception('Error calculating returns');
//     }
//   }
//
//   Future<void> _fetchStockIndicators() async {
//     try {
//       // Chama a função para obter os indicadores da API
//       final indicators = await StockIndicators().getStockIndicators(widget.active.symbol);
//       setState(() {
//         _stockIndicators = indicators;
//       });
//     } catch (e) {
//       print('Error fetching stock indicators: $e');
//       // Trate o erro conforme necessário
//     }
//   }
//
//   String _formatIndicatorValue(dynamic value) {
//     if (value is double) {
//       return value.toStringAsFixed(2);
//     } else if (value is String) {
//       return value;
//     } else {
//       return '';
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           color: Colors.white,
//         ),
//         title: Text(
//           widget.active.symbol,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 18,
//           ),
//         ),
//         backgroundColor: Colors.black,
//       ),
//       body: Stack(
//         children: [
//           SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   FutureBuilder<List<double>>(
//                     future: _calculateReturns(),
//                     builder: (context, snapshot) {
//                       double returnCurrentMonth = 0.0;
//                       double returnLast12Months = 0.0;
//
//                       if (snapshot.connectionState == ConnectionState.done &&
//                           snapshot.hasData) {
//                         returnCurrentMonth = snapshot.data![0];
//                         returnLast12Months = snapshot.data![1];
//                       }
//
//                       return _buildHeader(
//                           returnLast12Months, returnCurrentMonth);
//                     },
//                   ),
//                   const SizedBox(height: 20),
//                   _buildInfoSection(
//                     title: 'Informações Gerais',
//                     children: [
//                       _buildGeneralInfoCard(
//                         title: 'Preço Atual',
//                         value: real.format(widget.active.lastPrice),
//                       ),
//                       _buildGeneralInfoCard(
//                         title: 'Dividend Yield',
//                         value:
//                         '${widget.active.dividendYield.toStringAsFixed(2)}%',
//                       ),
//                       _buildGeneralInfoCard(
//                         title: 'Setor',
//                         value: widget.active.sector,
//                       ),
//                       _buildGeneralInfoCard(
//                         title: 'Segmento',
//                         value: widget.active.segment,
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   _buildInfoSection(
//                     title: 'Desempenho Anual',
//                     children: [
//                       _buildPerformanceInfoCard(
//                         title: 'Último Ano Baixo',
//                         value: real.format(widget.active.lastYearLow),
//                       ),
//                       _buildPerformanceInfoCard(
//                         title: 'Último Ano Alto',
//                         value: real.format(widget.active.lastYearHigh),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   // Add more sections as needed
//                   // Substitua a parte relevante do código pelo seguinte:
//
//                   // ListView.builder(
//                   //   shrinkWrap: true,
//                   //   physics: NeverScrollableScrollPhysics(),
//                   //   itemCount: _stockIndicators!['indicators'].length,
//                   //   itemBuilder: (context, index) {
//                   //     final indicator = _stockIndicators!['indicators'][index];
//                   //     return _buildIndicatorCard(indicator); // Corrigido: Passando o mapa inteiro
//                   //   },
//                   // )
//
//                   _buildIndicatorsSection(),
//                 ],
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
//
//   Widget _buildIndicatorsSection() {
//     if (_stockIndicators == null || _stockIndicators!['indicators'] == null) {
//       return Center(child: CircularProgressIndicator());
//     }
//
//     final List<dynamic>? indicators = _stockIndicators!['indicators'];
//
//     if (indicators == null) {
//       return SizedBox(); // Ou algum outro widget de espaço reservado
//     }
//
//     return SizedBox(
//       height: 300, // Set a finite height for the ListView
//       child: ListView.builder(
//         padding: EdgeInsets.all(16.0),
//         itemCount: indicators.length,
//         itemBuilder: (context, index) {
//           final indicator = indicators[index];
//           return _buildIndicatorCard(indicator);
//         },
//       ),
//     );
//   }
//
//
//   Widget _buildIndicatorCard(Map<String, dynamic> filteredIndicator) {
//     // No need to check for null here since filteredIndicator should never be null
//     // Also removed the unnecessary loop
//
//     if (filteredIndicator == null) {
//       return SizedBox(); // Ou algum outro widget de espaço reservado
//     }
//
//     List<Widget> indicatorWidgets = [];
//
//     filteredIndicator.forEach((key, value) {
//       if (value is Map && key != 'name' && key != 'description') { // Verifica se o valor é um mapa
//         indicatorWidgets.add(
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 key,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                   color: Colors.white,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 'Value: ${value['value']}',
//                 style: const TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey,
//                 ),
//               ),
//               Text(
//                 'Description: ${value['description']}',
//                 style: const TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey,
//                 ),
//               ),
//             ],
//           ),
//         );
//       }
//     });
//
//     return Card(
//       elevation: 2,
//       color: Colors.grey[900],
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       margin: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: indicatorWidgets,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader(double returnLast12Months, double returnCurrentMonth) {
//     return Row(
//       children: <Widget>[
//         Container(
//           width: 100,
//           height: 100,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(10),
//             image: DecorationImage(
//               image: AssetImage(widget.active.icon),
//               fit: BoxFit.cover,
//             ),
//           ),
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 widget.active.name,
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 'Rentabilidade (12M): ${returnLast12Months.toStringAsFixed(2)}%',
//                 style: const TextStyle(
//                   fontSize: 16,
//                   color: Colors.grey,
//                 ),
//               ),
//               Text(
//                 'Último Mês: ${returnCurrentMonth.toStringAsFixed(2)}%',
//                 style: const TextStyle(
//                   fontSize: 16,
//                   color: Colors.grey,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildInfoSection(
//       {required String title, required List<Widget> children}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(
//             fontSize: 16.0,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 12),
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Row(
//             children: children.map((widget) {
//               return Padding(
//                 padding: const EdgeInsets.only(right: 16.0),
//                 child: widget,
//               );
//             }).toList(),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildGeneralInfoCard({required String title, required String value}) {
//     return Card(
//       elevation: 2,
//       color: Colors.grey[900],
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               title,
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//                 color: Colors.white,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPerformanceInfoCard(
//       {required String title, required String value}) {
//     return Card(
//       elevation: 2,
//       color: Colors.grey[900],
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               title,
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//                 color: Colors.white,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_investment_control/models/active_model.dart';
import 'package:flutter_investment_control/services/api_stock_indicators.dart';
import 'package:flutter_investment_control/services/api_stocks_historicals.dart';
import 'package:intl/intl.dart';

class ActiveDetailsPage extends StatefulWidget {
  final Active active;

  ActiveDetailsPage({Key? key, required this.active}) : super(key: key);

  @override
  _ActiveDetailsPageState createState() => _ActiveDetailsPageState();
}

class _ActiveDetailsPageState extends State<ActiveDetailsPage> {
  NumberFormat real = NumberFormat.currency(locale: 'pt-br', name: 'R\$');

  @override
  void initState() {
    super.initState();
    _fetchStockIndicators(); // Chama a função para buscar os indicadores ao iniciar a página
  }

  Map<String, dynamic>? _stockIndicators;

  Future<List<double>> _calculateReturns() async {
    try {
      // Get historical prices from the API response
      final response =
      await StocksHistoricals().getStockHistoricals(widget.active.symbol);

      if (response != null) {
        List<dynamic> historicals = response['historicals'] as List<dynamic>;

        // Obter a data de hoje e o primeiro dia do mês passado
        DateTime now = DateTime.now();
        DateTime firstDayOfLastMonth = DateTime(now.year, now.month - 1, 1);

        // Filtrar os preços para o último mês
        List<double> pricesLastMonth = historicals
            .where((historical) {
          DateTime date = DateTime.parse(historical['date']);
          return date.isAfter(
              firstDayOfLastMonth.subtract(Duration(days: 1))) &&
              date.isBefore(now);
        })
            .map<double>(
                (historical) => double.parse(historical['close'].toString()))
            .toList();

        // Verificar se há preços disponíveis para o último mês
        double returnLastMonth = 0.0;
        if (pricesLastMonth.isNotEmpty) {
          // Obter o primeiro e o último preço de fechamento disponíveis
          double firstDayClosingPrice = pricesLastMonth.first;
          double lastDayClosingPrice = pricesLastMonth.last;

          // Calcular a rentabilidade para o último mês
          returnLastMonth = ((lastDayClosingPrice - firstDayClosingPrice) /
              firstDayClosingPrice) *
              100;
        }

        // Calcular a rentabilidade para os últimos 12 meses
        DateTime twelveMonthsAgo = DateTime.now().subtract(Duration(days: 365));
        List<double> pricesLast12Months = historicals
            .where((historical) {
          DateTime date = DateTime.parse(historical['date']);
          return date.isAfter(twelveMonthsAgo.subtract(Duration(days: 1)));
        })
            .map<double>(
                (historical) => double.parse(historical['close'].toString()))
            .toList();

        double returnLast12Months = 0.0;
        if (pricesLast12Months.isNotEmpty) {
          // Obter o primeiro e o último preço de fechamento dos últimos 12 meses
          double firstPriceLast12Months = pricesLast12Months.first;
          double lastPriceLast12Months = pricesLast12Months.last;

          // Calcular a rentabilidade dos últimos 12 meses
          returnLast12Months =
              ((lastPriceLast12Months - firstPriceLast12Months) /
                  firstPriceLast12Months) *
                  100;
        }

        return [returnLastMonth, returnLast12Months];
      } else {
        throw Exception('Failed to load historical prices');
      }
    } catch (e) {
      print('Error calculating returns: $e');
      throw Exception('Error calculating returns');
    }
  }

  Future<void> _fetchStockIndicators() async {
    try {
      // Chama a função para obter os indicadores da API
      final indicators = await StockIndicators().getStockIndicators(widget.active.symbol);
      setState(() {
        _stockIndicators = indicators;
      });
    } catch (e) {
      print('Error fetching stock indicators: $e');
      // Trate o erro conforme necessário
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.white,
        ),
        title: Text(
          widget.active.symbol,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<List<double>>(
                    future: _calculateReturns(),
                    builder: (context, snapshot) {
                      double returnCurrentMonth = 0.0;
                      double returnLast12Months = 0.0;

                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData) {
                        returnCurrentMonth = snapshot.data![0];
                        returnLast12Months = snapshot.data![1];
                      }

                      return _buildHeader(
                          returnLast12Months, returnCurrentMonth);
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildInfoSection(
                    title: 'Informações Gerais',
                    children: [
                      _buildGeneralInfoCard(
                        title: 'Preço Atual',
                        value: real.format(widget.active.lastPrice),
                      ),
                      _buildGeneralInfoCard(
                        title: 'Dividend Yield',
                        value:
                        '${widget.active.dividendYield.toStringAsFixed(2)}%',
                      ),
                      _buildGeneralInfoCard(
                        title: 'Setor',
                        value: widget.active.sector,
                      ),
                      _buildGeneralInfoCard(
                        title: 'Segmento',
                        value: widget.active.segment,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildInfoSection(
                    title: 'Desempenho Anual',
                    children: [
                      _buildPerformanceInfoCard(
                        title: 'Último Ano Baixo',
                        value: real.format(widget.active.lastYearLow),
                      ),
                      _buildPerformanceInfoCard(
                        title: 'Último Ano Alto',
                        value: real.format(widget.active.lastYearHigh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Add more sections as needed
                  _buildIndicatorsSection(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildIndicatorsSection() {
    if (_stockIndicators == null || _stockIndicators!['indicators'] == null) {
      return Center(child: CircularProgressIndicator());
    }

    final List<dynamic>? indicatorsDynamic = _stockIndicators!['indicators'];

    if (indicatorsDynamic == null) {
      return SizedBox(); // Ou algum outro widget de espaço reservado
    }

    // Convertendo a lista dinâmica para uma lista de mapas
    final List<Map<String, dynamic>> indicators = indicatorsDynamic.cast<Map<String, dynamic>>();

    final List<String> indicatorKeys = ['assetTurnoverRatio', 'priceEarningsRatio', 'priceToBookValue' /* outras chaves aqui */];

    List<Widget> cards = _buildIndicatorCards(indicators, indicatorKeys);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Indicadores', // Adicione um título para a seção de indicadores
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: cards,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildIndicatorCards(List<Map<String, dynamic>> indicators, List<String> keys) {
    List<Widget> cards = [];

    for (String key in keys) {
      for (Map<String, dynamic> indicator in indicators) {
        final dynamic value = indicator[key];
        if (value != null) {
          IconData iconData = Icons.info; // Altere aqui o ícone desejado

          cards.add(
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Card(
                elevation: 2,
                color: Colors.grey[900],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Alinha widgets à direita
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${(value['name'])}', // Nome específico do indicador
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(value['value'])}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          _showIndicatorDescription('${(value['description'])}' ?? '');
                        },
                        child: Icon(
                          iconData,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      }
    }

    return cards;
  }

  void _showIndicatorDescription(String description) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Descrição do Indicador',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 10),
              Text(
                description,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(double returnLast12Months, double returnCurrentMonth) {
    return Row(
      children: <Widget>[
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: AssetImage(widget.active.icon),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.active.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Rentabilidade (12M): ${returnLast12Months.toStringAsFixed(2)}%',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              Text(
                'Último Mês: ${returnCurrentMonth.toStringAsFixed(2)}%',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(
      {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 7),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: children.map((widget) {
              return Padding(
                padding: const EdgeInsets.only(right: 0.0),
                child: widget,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralInfoCard({required String title, required String value}) {
    return Card(
      elevation: 2,
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceInfoCard(
      {required String title, required String value}) {
    return Card(
      elevation: 2,
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
