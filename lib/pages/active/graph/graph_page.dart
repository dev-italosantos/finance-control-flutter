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
      length: 5, // Modificado para incluir o novo Tab
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
            color: Colors.white, // Defina a cor desejada aqui
          ),
          title: const Text(
            'Gráficos',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.black,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Posição'),
              Tab(text: 'Ativos'),
              Tab(text: 'Ações'), // Novo Tab para as ações
              Tab(text: 'Fiis'),
              Tab(text: 'Indices'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCurrentPositionChart(),
            _buildDistributionChart(),
            _buildStockChart(),
            _buildFiisChart(),
            _buildProfitabilityChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPositionChart() {
    // Filtra apenas os ativos não totalmente liquidados
    final List<Asset> nonLiquidatedAssets =
        widget.assetList.where((asset) => !asset.isFullyLiquidated).toList();

    // Verifica se há ativos para exibir o gráfico
    if (nonLiquidatedAssets.isEmpty) {
      return Center(
        child: Text('Nenhum ativo encontrado.'),
      );
    }

    // Calcula o valor total da carteira
    double totalPortfolioValue = nonLiquidatedAssets.fold(
        0, (total, asset) => total + asset.totalAmount);

    // Filtra os ativos do tipo FII
    final List<Asset> fiiAssets = nonLiquidatedAssets
        .where((asset) => asset.activeType == 'fiis')
        .toList();

    // Filtra os ativos do tipo ação
    final List<Asset> stockAssets = nonLiquidatedAssets
        .where((asset) => asset.activeType == 'stocks')
        .toList();

    // Calcula a porcentagem total para cada tipo de ativo
    double fiiPercentage =
        fiiAssets.fold(0.0, (total, asset) => total + asset.totalAmount) /
            totalPortfolioValue *
            100;
    double stockPercentage =
        stockAssets.fold(0.0, (total, asset) => total + asset.totalAmount) /
            totalPortfolioValue *
            100;

    return Scaffold(
      body: Column(
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
                      touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                sectionsSpace: 5,
                centerSpaceRadius: 50,
                sections: [
                  PieChartSectionData(
                    color: _getColor(0), // Cor para FIIs
                    value: fiiPercentage,
                    title: 'FIIs\n${fiiPercentage.toStringAsFixed(2)}%',
                    radius: 80,
                    titleStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xffffffff),
                    ),
                    titlePositionPercentageOffset: 0.5,
                  ),
                  PieChartSectionData(
                    color: _getColor(1), // Cor para ações
                    value: stockPercentage,
                    title: 'Ações\n${stockPercentage.toStringAsFixed(2)}%',
                    radius: 80,
                    titleStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xffffffff),
                    ),
                    titlePositionPercentageOffset: 0.5,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
                children:
                    _buildTickerWidgets(nonLiquidatedAssets, totalCurrent),
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
          _buildRecommendationChart(nonLiquidatedAssets),
        ],
      ),
    );
  }

  Widget _buildStockChart() {
    // Filtra apenas as ações da lista de ativos
    final List<Asset> stockAssets = widget.assetList
        .where(
            (asset) => asset.activeType == 'stocks' && !asset.isFullyLiquidated)
        .toList();

    // Verifica se há ações para exibir o gráfico
    if (stockAssets.isEmpty) {
      return Center(
        child: Text('Nenhuma ação encontrada.'),
      );
    }

    // Calcula o total atual das ações
    double totalStockValue = stockAssets.fold(
        0, (total, asset) => total + asset.currentPrice * asset.quantity);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _buildTickerWidgets(stockAssets, totalStockValue),
                ),
              ),
            ),
            Container(
              height: 300,
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
                  sections: _getSections(stockAssets, totalStockValue),
                ),
              ),
            ),
            _buildRecommendationChart(stockAssets),
            _buildSectorDistributionChart(stockAssets),
          ],
        ),
      ),
    );
  }

  Widget _buildFiisChart() {
    // Filtra apenas as ações da lista de ativos
    final List<Asset> fiiAssets = widget.assetList
        .where(
            (asset) => asset.activeType == 'fiis' && !asset.isFullyLiquidated)
        .toList();

    // Verifica se há ações para exibir o gráfico
    if (fiiAssets.isEmpty) {
      return Center(
        child: Text('Nenhuma ação encontrada.'),
      );
    }

    // Calcula o total atual das ações
    double totalFiiValue = fiiAssets.fold(
        0, (total, asset) => total + asset.currentPrice * asset.quantity);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _buildTickerWidgets(fiiAssets, totalFiiValue),
                ),
              ),
            ),
            Container(
              height: 300,
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
                  sections: _getSections(fiiAssets, totalFiiValue),
                ),
              ),
            ),
            _buildRecommendationChart(fiiAssets),
            _buildSectorDistributionChart(fiiAssets),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _getSections(
      List<Asset> assets, double totalStockValue) {
    double percentageOffset = 0.5;

    return List.generate(assets.length, (index) {
      final isTouched = index == touchedIndex;
      final double fontSize = isTouched ? 20 : 14;
      final double radius = isTouched ? 90 : 80;

      return PieChartSectionData(
        color: _getColor(index),
        value: assets[index].currentPrice * assets[index].quantity,
        title:
            '${((assets[index].currentPrice * assets[index].quantity) / totalStockValue * 100).toStringAsFixed(2)}%',
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
            color: _getColor(index),
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

  Widget _buildRecommendationChart(List<Asset> assets) {
    double totalValue = assets.fold(
        0, (total, asset) => total + asset.currentPrice * asset.quantity);
    double equalDistribution = totalValue / assets.length;

    return Container(
      height: 300,
      child: PieChart(
        PieChartData(
          borderData: FlBorderData(show: false),
          sectionsSpace: 5,
          centerSpaceRadius: 50,
          sections:
              _getRecommendationSections(assets, equalDistribution, totalValue),
        ),
      ),
    );
  }

  Widget _buildSectorDistributionChart(List<Asset> stockAssets) {
    // Se não houver ativos de ações, retorna um widget informativo
    if (stockAssets.isEmpty) {
      return Center(
        child: Text('Nenhuma ação encontrada.'),
      );
    }

    // Mapeia os ativos de ações por setor
    Map<String, double> sectorMap = {};
    stockAssets.forEach((asset) {
      sectorMap.update(asset.segment, (value) => value + asset.totalAmount,
          ifAbsent: () => asset.totalAmount);
    });

    // Calcula o valor total dos ativos de ações
    double totalStockValue =
        stockAssets.fold(0, (total, asset) => total + asset.totalAmount);

    // Converte o mapa em uma lista de Setor
    List<PieChartSectionData> sectors = sectorMap.entries
        .map(
          (entry) => PieChartSectionData(
            color: _getColor(sectorMap.keys.toList().indexOf(entry.key)),
            value: entry.value,
            title:
                '${(entry.value / totalStockValue * 100).toStringAsFixed(2)}%',
            radius: 80,
            titleStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff),
            ),
            titlePositionPercentageOffset: 0.5,
          ),
        )
        .toList();

    // Constrói o gráfico de distribuição por setor
    return Container(
      height: 400, // Ajuste conforme necessário
      child: Column(
        children: [
          Container(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _buildSectorNameWidgets(sectorMap.keys.toList()),
              ),
            ),
          ),
          Container(
            height: 300,
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
                      touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                sectionsSpace: 5,
                centerSpaceRadius: 50,
                sections: _getTouchedSections(sectors),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _getTouchedSections(
      List<PieChartSectionData> sectors) {
    return sectors.map((entry) {
      final isTouched = sectors.indexOf(entry) == touchedIndex;
      final double fontSize = isTouched ? 20 : 14;
      final double radius = isTouched ? 90 : 80;

      return PieChartSectionData(
        color: entry.color,
        value: entry.value,
        title: entry.title,
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
        ),
        titlePositionPercentageOffset: isTouched ? 0.55 : 0.5,
      );
    }).toList();
  }

  List<Widget> _buildSectorNameWidgets(List<String> sectorNames) {
    return sectorNames.asMap().entries.map((entry) {
      final index = entry.key;
      final name = entry.value;

      return GestureDetector(
        onTap: () {
          setState(() {
            touchedIndex = index;
          });
        },
        child: Container(
          margin: EdgeInsets.all(8.0),
          padding: EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: _getColor(index),
            borderRadius: BorderRadius.circular(4.0),
            border: Border.all(
              color: touchedIndex == index ? Colors.yellow : Colors.transparent,
              width: 2.0,
            ),
          ),
          child: Text(
            '$name',
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

  List<PieChartSectionData> _getRecommendationSections(
      List<Asset> assets, double equalDistribution, double totalValue) {
    double percentageOffset = 0.5;

    return List.generate(assets.length, (index) {
      const isTouched = false;
      const double fontSize = isTouched ? 20 : 14;
      const double radius = isTouched ? 90 : 80;

      return PieChartSectionData(
        color: _getColor(index),
        value: equalDistribution,
        title:
            '${assets[index].ticker} ${(equalDistribution / totalValue * 100).toStringAsFixed(2)}%',
        radius: radius,
        titleStyle: const TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Color(0xffffffff),
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
