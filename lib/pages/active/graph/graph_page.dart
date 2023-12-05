import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_investment_control/models/asset_model.dart';

class GraphPage extends StatelessWidget {
  final List<Asset> assetList;

  const GraphPage({Key? key, required this.assetList}) : super(key: key);

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
            // Tela para a distribuição por ativo
            buildDistributionChart(),

            // Tela para a rentabilidade da carteira e CDI
            buildProfitabilityChart(),
          ],
        ),
      ),
    );
  }

  Widget buildDistributionChart() {
    double totalCurrent = 0;
    for (final asset in assetList) {
      totalCurrent += asset.currentPrice * asset.quantity;
    }

    return Scaffold(
      body: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: 400,
          height: 300,
          child: SfCircularChart(
            legend: const Legend(
              isVisible: true,
              position: LegendPosition.bottom,
            ),
            series: <DoughnutSeries>[
              DoughnutSeries<Asset, String>(
                dataSource: assetList,
                xValueMapper: (Asset asset, _) => asset.ticker,
                yValueMapper: (Asset asset, _) => asset.currentPrice * asset.quantity,
                dataLabelMapper: (Asset asset, _) {
                  final percentage = (asset.currentPrice * asset.quantity) / totalCurrent * 100;
                  return '${asset.ticker}\n${percentage.toStringAsFixed(2)}%';
                },
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  labelPosition: ChartDataLabelPosition.outside,
                  connectorLineSettings: ConnectorLineSettings(
                    type: ConnectorType.curve,
                    length: '10%',
                  ),
                  textStyle: TextStyle(color: Colors.black, fontSize: 12),
                ),
              ),
            ],
            borderWidth: 2,
            borderColor: Colors.white,
            backgroundColor: Colors.transparent,
            palette: const <Color>[
              Colors.blue,
              Colors.green,
              Colors.orange,
              Colors.purple,
              Colors.red,
              Colors.black,
              Colors.deepPurpleAccent,
              Colors.teal,
              Colors.pinkAccent,
              Colors.brown,
              Colors.blueGrey
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProfitabilityChart() {
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
          width: 400, // Ajuste a largura conforme necessário
          height: 300, // Ajuste a altura conforme necessário
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            legend: const Legend(isVisible: true, position: LegendPosition.bottom),
            trackballBehavior: TrackballBehavior(
              enable: true,
              activationMode: ActivationMode.singleTap,
              tooltipSettings: const InteractiveTooltip(
                enable: true,
              ),
            ),
            series: <ChartSeries>[
              LineSeries<Map<String, dynamic>, String>(
                dataSource: data,
                xValueMapper: (Map<String, dynamic> data, _) => data['label'],
                yValueMapper: (Map<String, dynamic> data, _) => data['carteira'],
                name: 'Carteira',
                width: 2,
                markerSettings: MarkerSettings(isVisible: true),
              ),
              LineSeries<Map<String, dynamic>, String>(
                dataSource: data,
                xValueMapper: (Map<String, dynamic> data, _) => data['label'],
                yValueMapper: (Map<String, dynamic> data, _) => data['cdi'],
                name: 'CDI',
                width: 2,
                markerSettings: MarkerSettings(isVisible: true),
              ),
            ],
            borderWidth: 2,
            borderColor: Colors.white,
            backgroundColor: Colors.transparent,
            palette: const <Color>[
              Colors.blue,
              Colors.green,
            ],
          ),
        ),
      ),
    );
  }
}
