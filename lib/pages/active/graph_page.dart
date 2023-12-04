import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_investment_control/models/asset_model.dart';

class GraphPage extends StatelessWidget {
  final List<Asset> assetList;

  const GraphPage({Key? key, required this.assetList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double totalCurrent = 0;
    for (final asset in assetList) {
      totalCurrent += asset.currentPrice * asset.quantity;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Distribuição por Ativo'),
      ),
      body: Center(
        child: SfCircularChart(
          legend: Legend(
            isVisible: true,
            position: LegendPosition.bottom,
          ),
          series: <DoughnutSeries<Asset, String>>[
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
            Colors.cyanAccent

            // Adicione mais cores conforme necessário
          ],
          // Ajuste a posição central para controlar o tamanho do gráfico
          centerX: '50%',
          centerY: '30%',
        ),
      ),
    );
  }
}
