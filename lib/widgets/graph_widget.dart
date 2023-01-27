import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:intl/intl.dart';

class GraphWidget extends StatefulWidget {
  const GraphWidget({Key? key}) : super(key: key);

  @override
  State<GraphWidget> createState() => _GraphWidgetState();
}

class _GraphWidgetState extends State<GraphWidget> {
  @override
  Widget build(BuildContext context) {
    final List<ChartData> chartData = [
      // ChartData('CDI', 12.82, Colors.pinkAccent),
      // ChartData('IBOVESPA', 4.89, Colors.green),
      // ChartData('IFIX', 0.22, Colors.yellow),
      // ChartData('IPCA', 5.82, Colors.blue)
      ChartData(DateTime(2022, 05, 12), Colors.pinkAccent, 0),
      ChartData(DateTime.now(), Colors.green, 1.8),
      // ChartData(DateTime(2022, 05, 24), Colors.yellow, 12),
      // ChartData(DateTime.now(), Colors.blue, 2.82)
    ];

    final List<ChartData> chartData1 = [
      ChartData(DateTime.now(), Colors.blue, 2.82),
      ChartData(DateTime(2022, 05, 24), Colors.yellow, 12),
      ChartData(DateTime(2022, 05, 25), Colors.yellow, 24),
      ChartData(DateTime(2022, 05, 26), Colors.yellow, 32),
    ];

    return Scaffold(
      body: Center(
        // child: SfCircularChart(
        //   series: <CircularSeries>[
        //     // Render pie chart
        //     PieSeries<ChartData, String>(
        //         dataSource: chartData,
        //         pointColorMapper: (ChartData data, _) => data.color,
        //         xValueMapper: (ChartData data, _) => data.x,
        //         yValueMapper: (ChartData data, _) => data.y)
        //   ],
        // ),
        child: SfTheme(
          data: SfThemeData(brightness: Brightness.dark),
          child: SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              legend: Legend(isVisible: true),
              enableAxisAnimation: true,
              // primaryXAxis: DateTimeAxis(
              //   // X axis labels will be rendered based on the below format
              //     dateFormat: DateFormat.y()
              // ),
              series: <ChartSeries>[
                StackedLine100Series<ChartData, DateTime>(
                    dataSource: chartData1,
                    dashArray: const <double>[5, 5],
                    markerSettings: const MarkerSettings(
                      isVisible: true,
                      shape: DataMarkerType.diamond,
                    ),
                    pointColorMapper: (ChartData data, _) => data.color,
                    xValueMapper: (ChartData data, _) => data.x,
                    yValueMapper: (ChartData data, _) => data.y1),
                StackedLine100Series<ChartData, DateTime>(
                    dataSource: chartData,
                    dashArray: const <double>[5, 5],
                    markerSettings: const MarkerSettings(
                        isVisible: true, shape: DataMarkerType.diamond),
                    pointColorMapper: (ChartData data, _) => data.color,
                    xValueMapper: (ChartData data, _) => data.x,
                    yValueMapper: (ChartData data, _) => data.y1),
                StackedLine100Series<ChartData, DateTime>(
                    dataSource: chartData1,
                    dashArray: const <double>[5, 5],
                    markerSettings: const MarkerSettings(isVisible: true),
                    pointColorMapper: (ChartData data, _) => data.color,
                    xValueMapper: (ChartData data, _) => data.x,
                    yValueMapper: (ChartData data, _) => data.y1),
                StackedLine100Series<ChartData, DateTime>(
                    dataSource: chartData,
                    dashArray: const <double>[5, 5],
                    markerSettings: const MarkerSettings(isVisible: true),
                    pointColorMapper: (ChartData data, _) => data.color,
                    xValueMapper: (ChartData data, _) => data.x,
                    yValueMapper: (ChartData data, _) => data.y1)
              ]),
          // child: SfCartesianChart(
          //     primaryXAxis: CategoryAxis(),
          //     series: <ChartSeries>[
          //       StackedLineSeries<ChartData, String>(
          //           dataLabelSettings: const DataLabelSettings(
          //               isVisible: true,
          //               showCumulativeValues: true,
          //               useSeriesColor: true
          //           ),
          //           dataSource: chartData,
          //           xValueMapper: (ChartData data, _) => data.x,
          //           yValueMapper: (ChartData data, _) => data.y3
          //       ),
          //       StackedLineSeries<ChartData, String>(
          //           dataLabelSettings: const DataLabelSettings(
          //               isVisible: true,
          //               showCumulativeValues: true,
          //               useSeriesColor: true
          //           ),
          //           dataSource: chartData,
          //           xValueMapper: (ChartData data, _) => data.x,
          //           yValueMapper: (ChartData data, _) => data.y3
          //       ),
          //       StackedLineSeries<ChartData, String>(
          //           dataLabelSettings: const DataLabelSettings(
          //               isVisible: true,
          //               showCumulativeValues: true,
          //               useSeriesColor: true
          //           ),
          //           dataSource: chartData,
          //           xValueMapper: (ChartData data, _) => data.x,
          //           yValueMapper: (ChartData data, _) => data.y3
          //       ),
          //     ],
          //   primaryYAxis: CategoryAxis(),
          // )
        ),
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.color, this.y1);
  final DateTime x;
  final double y1;
  final Color color;
}

class ExpenseData {
  ExpenseData(this.test, this.test1, this.test2, this.test3, this.test4);
  final String test;
  final num test1;
  final num test2;
  final num test3;
  final num test4;
}

class SalesData {
  SalesData(this.month, this.namber);
  final String month;
  final int namber;
}
