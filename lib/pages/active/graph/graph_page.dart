import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_investment_control/models/asset_model.dart';

class GraphPage extends StatefulWidget {
  final List<Asset> assetList;

  const GraphPage({Key? key, required this.assetList}) : super(key: key);

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  int touchedIndex = -1;

  void _handleTickerTap(int index) {
    setState(() {
      touchedIndex = touchedIndex == index ? -1 : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Gráficos',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          backgroundColor: Colors.black,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Distribuição por Ativo'),
              Tab(text: 'Rentabilidade da Carteira vs CDI'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDistributionChart(),
            _buildProfitabilityChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationChart(List<Asset> assets) {
    double totalValue = assets.fold(0, (total, asset) => total + asset.currentPrice * asset.quantity);
    double equalDistribution = totalValue / assets.length;

    return Container(
      height: 300,
      margin: EdgeInsets.symmetric(vertical: 16.0),
      child: PieChart(
        PieChartData(
          borderData: FlBorderData(show: false),
          sectionsSpace: 5,
          centerSpaceRadius: 50,
          sections: _getRecommendationSections(assets, equalDistribution, totalValue),
        ),
      ),
    );
  }

  List<PieChartSectionData> _getRecommendationSections(List<Asset> assets, double equalDistribution, double totalValue) {
    double percentageOffset = 0.5; // Ajuste este valor conforme necessário

    return List.generate(assets.length, (index) {
      final isTouched = false; // Você pode ajustar conforme necessário
      final double fontSize = isTouched ? 20 : 14;
      final double radius = isTouched ? 90 : 80;

      final double assetValue = assets[index].currentPrice * assets[index].quantity;

      return PieChartSectionData(
        color: _getColor(index),
        value: equalDistribution,
        title: '${assets[index].ticker} ${(equalDistribution / totalValue * 100).toStringAsFixed(2)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
        ),
        titlePositionPercentageOffset: percentageOffset,
      );
    });
  }


// Modifique o método _buildDistributionChart para chamar o novo método
  Widget _buildDistributionChart() {
    double totalCurrent = 0;

    final List<Asset> nonLiquidatedAssets =
    widget.assetList.where((asset) => !asset.isFullyLiquidated).toList();

    for (final asset in nonLiquidatedAssets) {
      totalCurrent += asset.currentPrice * asset.quantity;
    }

    return Scaffold(
      body: Column(
        children: [
          Container(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _buildTickerWidgets(nonLiquidatedAssets, totalCurrent),
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      sectionsSpace: 5,
                      centerSpaceRadius: 50,
                      sections: _getSections(nonLiquidatedAssets, totalCurrent),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildRecommendationChart(nonLiquidatedAssets), // Adicione o novo gráfico de recomendação
        ],
      ),
    );
  }

  // Widget _buildDistributionChart() {
  //   double totalCurrent = 0;
  //
  //   final List<Asset> nonLiquidatedAssets =
  //       widget.assetList.where((asset) => !asset.isFullyLiquidated).toList();
  //
  //   for (final asset in nonLiquidatedAssets) {
  //     totalCurrent += asset.currentPrice * asset.quantity;
  //   }
  //
  //   return Scaffold(
  //     body: Column(
  //       children: [
  //         Expanded(
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               Expanded(
  //                 child: PieChart(
  //                   PieChartData(
  //                     pieTouchData: PieTouchData(
  //                       touchCallback: (FlTouchEvent event, pieTouchResponse) {
  //                         setState(() {
  //                           if (!event.isInterestedForInteractions ||
  //                               pieTouchResponse == null ||
  //                               pieTouchResponse.touchedSection == null) {
  //                             touchedIndex = -1;
  //                             return;
  //                           }
  //                           touchedIndex = pieTouchResponse
  //                               .touchedSection!.touchedSectionIndex;
  //                         });
  //                       },
  //                     ),
  //                     borderData: FlBorderData(
  //                       show: false,
  //                     ),
  //                     sectionsSpace: 5,
  //                     centerSpaceRadius: 50,
  //                     sections: _getSections(nonLiquidatedAssets, totalCurrent),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         Container(
  //           child: SingleChildScrollView(
  //             scrollDirection: Axis.horizontal,
  //             child: Row(
  //               children: _buildTickerWidgets(nonLiquidatedAssets, totalCurrent),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  List<Widget> _buildTickerWidgets(List<Asset> assets, double totalCurrent) {
    return assets.asMap().entries.map((entry) {
      final index = entry.key;
      final asset = entry.value;

      final rentabilityPercentage =
          (asset.currentPrice * asset.quantity) / totalCurrent * 100;

      return GestureDetector(
        onTap: () => _handleTickerTap(index),
        child: Container(
          margin: EdgeInsets.all(8.0),
          padding: EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: _getColor(index), // Usa a mesma cor do gráfico
            borderRadius: BorderRadius.circular(4.0),
            border: Border.all(
              color: touchedIndex == index ? Colors.yellow : Colors.transparent,
              width: 2.0,
            ),
          ),
          child: Text(
            '${asset.ticker} ${rentabilityPercentage.toStringAsFixed(2)}%',
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }).toList();
  }


  Color _getColor(int index) {
    final List<Color> colors = [
      Color(0xFF4FC3F7),
      Color(0xFF81C784),
      Color(0xFFFFB74D),
      Color(0xFF9575CD),
      Color(0xFFFF867C),
      Color(0xFF616161),
      Color(0xFF7E57C2),
      Color(0xFF26A69A),
      Color(0xFFF06292),
      Color(0xFF8D6E63),
      Color(0xFF78909C),
    ];

    return colors[index % colors.length];
  }

  List<PieChartSectionData> _getSections(List<Asset> assets, double totalCurrent) {
    double percentageOffset = 0.5; // Ajuste este valor conforme necessário

    return List.generate(assets.length, (index) {
      final isTouched = index == touchedIndex;
      final double fontSize = isTouched ? 20 : 14;
      final double radius = isTouched ? 90 : 80;

      return PieChartSectionData(
        color: _getColor(index),
        value: assets[index].currentPrice * assets[index].quantity,
        title:
        '${((assets[index].currentPrice * assets[index].quantity) / totalCurrent * 100).toStringAsFixed(2)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
        ),
        titlePositionPercentageOffset: percentageOffset,
      );
    });
  }

  Widget _buildProfitabilityChart() {
    // Simulação de dados para a rentabilidade da carteira e do CDI
    List<Map<String, dynamic>> data = [
      {'label': 'Out', 'carteira': -0.40, 'cdi': 1.01},
      {'label': 'Nov', 'carteira': 6.345, 'cdi': 1.01},
      {'label': 'Dez', 'carteira': 1.105, 'cdi': 1.01},
      // Adicione mais pontos de dados conforme necessário
    ];

    return Scaffold(
      body: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: 400,
          height: 300,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(show: false),
              borderData: FlBorderData(show: true),
              minX: 0,
              maxX: data.length.toDouble() - 1,
              minY: -1,
              maxY: 8,
              lineBarsData: [
                _buildLineChartBarData(data, 'carteira', _getColor(0)),
                _buildLineChartBarData(data, 'cdi', _getColor(1)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  LineChartBarData _buildLineChartBarData(
      List<Map<String, dynamic>> data, String key, Color color) {
    return LineChartBarData(
      spots: _getDataSpots(data, key),
      isCurved: true,
      colors: [color],
      belowBarData: BarAreaData(show: false),
    );
  }

  List<FlSpot> _getDataSpots(List<Map<String, dynamic>> data, String key) {
    return List.generate(data.length, (index) {
      return FlSpot(index.toDouble(), data[index][key]);
    });
  }
}
