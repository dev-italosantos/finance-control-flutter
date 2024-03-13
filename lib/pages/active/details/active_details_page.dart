// import 'dart:math';
//
// import 'package:fl_chart/fl_chart.dart';
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
//   double _calculateFairValue() {
//     if (_stockIndicators == null || _stockIndicators!['indicators'] == null) {
//       return 0.0; // Valor padrão se os indicadores não estiverem disponíveis
//     }
//
//     final List<dynamic> indicators = _stockIndicators!['indicators'];
//
//     if (indicators.isEmpty) {
//       return 0.0; // Retorna valor padrão se a lista de indicadores estiver vazia
//     }
//
//     print('Dados recebidos _calculateFairValue: $indicators');
//
//     // Encontra os indicadores necessários na lista
//     final Map<String, dynamic> earningsPerShareIndicator =
//         indicators.firstWhere(
//       (indicator) => indicator.containsKey('earningsPerShare'),
//       orElse: () => <String, dynamic>{
//         'earningsPerShare': {'value': 0.0}
//       }, // Retorna um mapa com valor padrão se não encontrar
//     );
//
//     final Map<String, dynamic> bookValuePerShareIndicator =
//         indicators.firstWhere(
//       (indicator) => indicator.containsKey('bookValuePerShare'),
//       orElse: () => <String, dynamic>{
//         'bookValuePerShare': {'value': 0.0}
//       }, // Retorna um mapa com valor padrão se não encontrar
//     );
//
//     final double earningsPerShare =
//         earningsPerShareIndicator['earningsPerShare']['value'] ?? 0.0;
//     final double bookValuePerShare =
//         bookValuePerShareIndicator['bookValuePerShare']['value'] ?? 0.0;
//
//     // Fórmula de Valor Intrínseco de Benjamin Graham
//     final double fairValue = sqrt(22.5 * earningsPerShare * bookValuePerShare);
//
//     return fairValue;
//   }
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
//           await StocksHistoricals().getStockHistoricals(widget.active.symbol);
//
//       if (response != null) {
//         List<dynamic> historicals = response['historicals'] as List<dynamic>;
//
//         // Obter a data de hoje e o primeiro dia do mês passado
//         DateTime now = DateTime.now();
//         DateTime firstDayOfLastMonth = DateTime(now.year, now.month - 1, 1);
//
//         // Filtrar os preços para o último d
//         List<double> pricesLastMonth = historicals
//             .where((historical) {
//               DateTime date = DateTime.parse(historical['date']);
//               return date.isAfter(
//                       firstDayOfLastMonth.subtract(Duration(days: 1))) &&
//                   date.isBefore(now);
//             })
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
//                   firstDayClosingPrice) *
//               100;
//         }
//
//         // Calcular a rentabilidade para os últimos 12 meses
//         DateTime twelveMonthsAgo = DateTime.now().subtract(Duration(days: 365));
//         List<double> pricesLast12Months = historicals
//             .where((historical) {
//               DateTime date = DateTime.parse(historical['date']);
//               return date.isAfter(twelveMonthsAgo.subtract(Duration(days: 1)));
//             })
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
//                       firstPriceLast12Months) *
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
//       final indicators =
//           await StockIndicators().getStockIndicators(widget.active.symbol);
//       setState(() {
//         _stockIndicators = indicators;
//       });
//     } catch (e) {
//       print('Error fetching stock indicators: $e');
//       // Trate o erro conforme necessário
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
//                             '${widget.active.dividendYield.toStringAsFixed(2)}%',
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
//                   const SizedBox(height: 15),
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
//                   const SizedBox(height: 15),
//                   // Add more sections as needed
//                   _buildIndicatorsSection(),
//                   const SizedBox(height: 15),
//                   _buildFairValueSection(), // Substitua esta linha
//                 ],
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
//
//   void _showHistoryChart() {
//     // Mock de dados fictícios para o gráfico de linhas
//     List<double> values = [10, 20, 15, 25, 30, 35];
//
//     // Criação do gráfico de linhas
//     Widget chart = LineChart(
//       LineChartData(
//         gridData: FlGridData(show: false),
//         titlesData: FlTitlesData(show: false),
//         borderData: FlBorderData(show: false),
//         lineBarsData: [
//           LineChartBarData(
//             spots: values.asMap().entries.map((entry) {
//               return FlSpot(entry.key.toDouble(), entry.value);
//             }).toList(),
//             isCurved: true,
//             colors: [Colors.blue],
//             barWidth: 4,
//             isStrokeCapRound: true,
//             dotData: FlDotData(show: true),
//             belowBarData: BarAreaData(show: false),
//           ),
//         ],
//         minX: 0,
//         maxX: values.length.toDouble() - 1,
//         minY: 0,
//         maxY: values
//                 .reduce((curr, next) => curr > next ? curr : next)
//                 .toDouble() +
//             10,
//       ),
//     );
//
//     // Mostra o modal com o gráfico de linhas
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Histórico do Indicador'),
//         content: SizedBox(
//           width: MediaQuery.of(context).size.width - 100,
//           height: MediaQuery.of(context).size.height - 200,
//           child: chart,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop(); // Fecha o modal
//             },
//             child: Text('Fechar'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showIndicatorDescription(String description, String name) {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return Container(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 name,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 18,
//                 ),
//               ),
//               SizedBox(height: 10),
//               Text(
//                 description,
//                 style: TextStyle(
//                   fontSize: 16,
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
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
//         const SizedBox(height: 7),
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Row(
//             children: children.map((widget) {
//               return widget;
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
//             const SizedBox(height: 7),
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
//
//   List<Widget> _buildIndicatorCards(
//       List<Map<String, dynamic>> indicators, List<String> keys) {
//     List<Widget> cards = [];
//
//     for (String key in keys) {
//       for (Map<String, dynamic> indicator in indicators) {
//         final dynamic value = indicator[key];
//         if (value != null) {
//           IconData infoIcon = Icons.info;
//           IconData historyIcon = Icons.history; // Ícone para histórico
//
//           cards.add(
//             Container(
//               margin:
//                   const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
//               width: MediaQuery.of(context).size.width / 2 -
//                   24, // Defina um tamanho máximo
//               child: Card(
//                 elevation: 2,
//                 color: Colors.grey[900],
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(12.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Flexible(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               '${value['name']}', // Nome específico do indicador
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16,
//                                 color: Colors.white,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               '${value['value']}',
//                               style: const TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           GestureDetector(
//                             onTap: () {
//                               _showIndicatorDescription(
//                                   '${value['description']}' ?? '',
//                                   '${value['name']}' ?? '');
//                             },
//                             child: Icon(
//                               infoIcon,
//                               color: Colors.white,
//                               size: 20,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           GestureDetector(
//                             onTap:
//                                 _showHistoryChart, // Chama o método para exibir o gráfico de histórico
//                             child: Icon(
//                               historyIcon,
//                               color: Colors.white,
//                               size: 20,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//         }
//       }
//     }
//
//     return cards;
//   }
//
//   Widget _buildIndicatorsSection() {
//     if (_stockIndicators == null || _stockIndicators!['indicators'] == null) {
//       return Center(child: CircularProgressIndicator());
//     }
//
//     final List<dynamic>? indicatorsDynamic = _stockIndicators!['indicators'];
//
//     if (indicatorsDynamic == null) {
//       return SizedBox(); // Ou algum outro widget de espaço reservado
//     }
//
//     final List<Map<String, dynamic>> indicators =
//         indicatorsDynamic.cast<Map<String, dynamic>>();
//
//     final Map<String, List<String>> sectionKeys = {
//       'Indicadores de Valuation': [
//         'priceToBookValue',
//         'priceEarningsRatio',
//         'enterpriseValueEbitda',
//         'enterpriseValueEbit',
//         'bookValuePerShare',
//         'earningsPerShare',
//         'priceToEbit',
//         'priceToEbitda',
//         'priceToAssets',
//         'priceToNetNetWorkingCapital',
//         'priceToNetCurrentAssets',
//       ],
//       'Indicadores de Endividamento': [
//         'netDebtToAssets',
//         'netDebtToEbitda',
//         'netDebtToEbit',
//         'equityToAssetsRatio',
//         'liabilitiesToAssetsRatio',
//         'currentLiquidity'
//       ],
//       'Indicadores de Eficiência': [
//         'grossMargin',
//         'ebitdaMargin',
//         'ebitMargin',
//         'netMargin'
//       ],
//       'Indicadores de Rentabilidade': [
//         'returnOnEquity',
//         'returnOnAssets',
//         'returnOnInvestedCapital',
//         'assetTurnoverRatio'
//       ],
//       'Indicadores de Crescimento': ['cagrProfitsFiveYears'],
//     };
//
//     List<Widget> cards = [];
//
//     sectionKeys.forEach((sectionTitle, keys) {
//       List<Widget> sectionCards = _buildIndicatorCards(indicators, keys);
//       cards.add(
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
//               child: Text(
//                 sectionTitle,
//                 style: const TextStyle(
//                   fontSize: 16.0,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: sectionCards,
//               ),
//             ),
//           ],
//         ),
//       );
//     });
//
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Indicadores', // Adicione um título para a seção de indicadores
//             style: TextStyle(
//               fontSize: 16.0,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           ...cards,
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFairValueSection() {
//     double fairValue = _calculateFairValue();
//     String formattedFairValue = real.format(fairValue);
//
//     double currentPrice = widget.active.lastPrice;
//     double potentialReturn = ((fairValue - currentPrice) / currentPrice) * 100;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         GestureDetector(
//           onTap: () {
//             _showIndicatorDescription(
//                 'O Preço Justo é calculado utilizando a fórmula simplificada de Valor Intrínseco proposta por Benjamin Graham: VI = √(22,5 x LPA x VPA). Essa fórmula é uma estimativa do valor intrínseco por ação, considerando o Lucro por Ação (LPA) e o Valor Patrimonial por Ação (VPA). A constante 22,5 é uma simplificação para facilitar o cálculo, porém, é importante destacar que essa versão não considera fatores como taxa de crescimento esperada (g) ou taxa de rendimento do investimento sem risco (Y) presentes na fórmula original de Graham. Assim, enquanto o Preço Justo pode fornecer uma estimativa rápida do valor intrínseco, outras análises e considerações são necessárias para decisões de investimento informadas.',
//                 "Valor Intrínseco"
//             );
//           },
//           child: Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   'Valor Intrínseco por Benjamin Graham',
//                   style: TextStyle(
//                     fontSize: 16.0,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               Icon(Icons.info_outline, color: Colors.grey),
//             ],
//           ),
//         ),
//         const SizedBox(height: 10),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Preço Justo',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Colors.black,
//                   ),
//                 ),
//                 const SizedBox(height: 5),
//                 Text(
//                   formattedFairValue,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ],
//             ),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Potencial de Rentabilidade',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Colors.black,
//                   ),
//                 ),
//                 const SizedBox(height: 5),
//                 Text(
//                   '${potentialReturn.toStringAsFixed(2)}%',
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
// }



import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
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

  double _calculateFairValue() {
    if (_stockIndicators == null || _stockIndicators!['indicators'] == null) {
      return 0.0; // Valor padrão se os indicadores não estiverem disponíveis
    }

    final List<dynamic> indicators = _stockIndicators!['indicators'];

    if (indicators.isEmpty) {
      return 0.0; // Retorna valor padrão se a lista de indicadores estiver vazia
    }

    print('Dados recebidos _calculateFairValue: $indicators');

    // Encontra os indicadores necessários na lista
    final Map<String, dynamic> earningsPerShareIndicator =
    indicators.firstWhere(
          (indicator) => indicator.containsKey('earningsPerShare'),
      orElse: () => <String, dynamic>{
        'earningsPerShare': {'value': 0.0}
      }, // Retorna um mapa com valor padrão se não encontrar
    );

    final Map<String, dynamic> bookValuePerShareIndicator =
    indicators.firstWhere(
          (indicator) => indicator.containsKey('bookValuePerShare'),
      orElse: () => <String, dynamic>{
        'bookValuePerShare': {'value': 0.0}
      }, // Retorna um mapa com valor padrão se não encontrar
    );

    final double earningsPerShare =
        earningsPerShareIndicator['earningsPerShare']['value'] ?? 0.0;
    final double bookValuePerShare =
        bookValuePerShareIndicator['bookValuePerShare']['value'] ?? 0.0;

    // Fórmula de Valor Intrínseco de Benjamin Graham
    final double fairValue = sqrt(22.5 * earningsPerShare * bookValuePerShare);

    return fairValue;
  }

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

        // Filtrar os preços para o último d
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
      final indicators =
      await StockIndicators().getStockIndicators(widget.active.symbol);
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
                      _buildGeneralInfoRow(
                        icon: Icons.monetization_on,
                        title: 'Preço Atual',
                        value: real.format(widget.active.lastPrice),
                      ),
                      _buildGeneralInfoRow(
                        icon: Icons.trending_up,
                        title: 'Dividend Yield',
                        value:
                        '${widget.active.dividendYield.toStringAsFixed(2)}%',
                      ),
                      _buildGeneralInfoRow(
                        icon: Icons.business,
                        title: 'Setor',
                        value: widget.active.sector,
                      ),
                      _buildGeneralInfoRow(
                        icon: Icons.work,
                        title: 'Segmento',
                        value: widget.active.segment,
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildInfoSection(
                    title: 'Desempenho Anual',
                    children: [
                      _buildPerformanceInfoRow(
                        icon: Icons.arrow_downward,
                        title: 'Último Ano Baixo',
                        value: real.format(widget.active.lastYearLow),
                      ),
                      _buildPerformanceInfoRow(
                        icon: Icons.arrow_upward,
                        title: 'Último Ano Alto',
                        value: real.format(widget.active.lastYearHigh),
                      ),
                    ],
                  ),
                  // Add more sections as needed
                  _buildIndicatorsSection(),
                  const SizedBox(height: 15),
                  _buildFairValueSection(), // Substitua esta linha
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showHistoryChart() {
    // Mock de dados fictícios para o gráfico de linhas
    List<double> values = [10, 20, 15, 25, 30, 35];

    // Criação do gráfico de linhas
    Widget chart = LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: values.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value);
            }).toList(),
            isCurved: true,
            colors: [Colors.blue],
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
        ],
        minX: 0,
        maxX: values.length.toDouble() - 1,
        minY: 0,
        maxY: values
            .reduce((curr, next) => curr > next ? curr : next)
            .toDouble() +
            10,
      ),
    );

    // Mostra o modal com o gráfico de linhas
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Histórico do Indicador'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width - 100,
          height: MediaQuery.of(context).size.height - 200,
          child: chart,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fecha o modal
            },
            child: Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showIndicatorDescription(String description, String name) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: const TextStyle(
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
              return widget;
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralInfoRow(
      {required IconData icon, required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceInfoRow(
      {required IconData icon, required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 18.0),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
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

    final List<Map<String, dynamic>> indicators =
    indicatorsDynamic.cast<Map<String, dynamic>>();

    final Map<String, List<String>> sectionKeys = {
      'Indicadores de Valuation': [
        'priceToBookValue',
        'priceEarningsRatio',
        'enterpriseValueEbitda',
        'enterpriseValueEbit',
        'bookValuePerShare',
        'earningsPerShare',
        'priceToEbit',
        'priceToEbitda',
        'priceToAssets',
        'priceToNetNetWorkingCapital',
        'priceToNetCurrentAssets',
      ],
      'Indicadores de Endividamento': [
        'netDebtToAssets',
        'netDebtToEbitda',
        'netDebtToEbit',
        'equityToAssetsRatio',
        'liabilitiesToAssetsRatio',
        'currentLiquidity'
      ],
      'Indicadores de Eficiência': [
        'grossMargin',
        'ebitdaMargin',
        'ebitMargin',
        'netMargin'
      ],
      'Indicadores de Rentabilidade': [
        'returnOnEquity',
        'returnOnAssets',
        'returnOnInvestedCapital',
        'assetTurnoverRatio'
      ],
      'Indicadores de Crescimento': ['cagrProfitsFiveYears'],
    };

    List<Widget> cards = [];

    sectionKeys.forEach((sectionTitle, keys) {
      List<Widget> sectionCards = _buildIndicatorCards(indicators, keys);
      cards.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Text(
                sectionTitle,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: sectionCards,
              ),
            ),
          ],
        ),
      );
    });

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Indicadores', // Adicione um título para a seção de indicadores
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          ...cards,
        ],
      ),
    );
  }

  Widget _buildIndicatorCard(
      {required String name,
        required String description,
        required IconData infoIcon,
        required IconData historyIcon,
        required String value}) { // Adicionando o parâmetro value
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      width: MediaQuery.of(context).size.width / 2 - 24, // Defina um tamanho máximo
      child: Card(
        elevation: 2,
        color: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4), // Adicionando espaço entre description e value
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white, // Altere a cor conforme necessário
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      _showIndicatorDescription(description, name);
                    },
                    child: Icon(
                      infoIcon,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _showHistoryChart,
                    child: Icon(
                      historyIcon,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  List<Widget> _buildIndicatorCards(
      List<Map<String, dynamic>> indicators, List<String> keys) {
    List<Widget> cards = [];

    for (String key in keys) {
      for (Map<String, dynamic> indicator in indicators) {
        final dynamic value = indicator[key];
        if (value != null) {
          IconData infoIcon = Icons.info;
          IconData historyIcon = Icons.history; // Ícone para histórico

          cards.add(
            _buildIndicatorCard(
              name: value['name'],
              description: value['description'] ?? '',
              value: value['value'].toString() ?? '',
              infoIcon: infoIcon,
              historyIcon: historyIcon,
            ),
          );
        }
      }
    }

    return cards;
  }

  Widget _buildFairValueSection() {
    double fairValue = _calculateFairValue();
    String formattedFairValue = real.format(fairValue);

    double currentPrice = widget.active.lastPrice;
    double potentialReturn = ((fairValue - currentPrice) / currentPrice) * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            _showIndicatorDescription(
              'O Preço Justo é calculado utilizando a fórmula simplificada de Valor Intrínseco proposta por Benjamin Graham: VI = √(22,5 x LPA x VPA). Essa fórmula é uma estimativa do valor intrínseco por ação, considerando o Lucro por Ação (LPA) e o Valor Patrimonial por Ação (VPA). A constante 22,5 é uma simplificação para facilitar o cálculo, porém, é importante destacar que essa versão não considera fatores como taxa de crescimento esperada (g) ou taxa de rendimento do investimento sem risco (Y) presentes na fórmula original de Graham. Assim, enquanto o Preço Justo pode fornecer uma estimativa rápida do valor intrínseco, outras análises e considerações são necessárias para decisões de investimento informadas.',
              "Valor Intrínseco",
            );
          },
          child: const Row(
            children: [
              Text(
                'Valor Intrínseco por Benjamin Graham',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 110),
                child: Icon(Icons.info_outline, color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Preço Justo',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  formattedFairValue,
                  style: TextStyle(
                    fontSize: 14,
                    color: fairValue > currentPrice
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Potencial de Retorno',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${potentialReturn.toStringAsFixed(2)}%',
                  style: TextStyle(
                    fontSize: 14,
                    color: fairValue > currentPrice
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
