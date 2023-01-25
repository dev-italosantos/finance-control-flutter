import 'dart:math';
import 'package:charts_flutter/flutter.dart';

import 'package:flutter/material.dart';

class GraphWidget extends StatefulWidget {
  const GraphWidget({Key? key}) : super(key: key);

  @override
  State<GraphWidget> createState() => _GraphWidgetState();
}

class _GraphWidgetState extends State<GraphWidget> {
  var data;

  @override
  void initState() {
    super.initState();

    var r = Random();
    data = List<double>.generate(50, (index) => r.nextDouble() * 1500);
  }

  _onSelectionChanged(SelectionModel model) {
    final selectedDatum = model.selectedDatum;

    var time;
    final measures = <String, double>{};

    if (selectedDatum.isNotEmpty) {
      time = selectedDatum.first.datum;
      selectedDatum.forEach((SeriesDatum datumPair) {
        measures[datumPair.series.displayName] = datumPair.datum;
      });
    }

    print(time);
    print(measures);
  }

  @override
  Widget build(BuildContext context) {
    List<Series<double, num>> series = [
      Series<double, int>(
        id: '63d07b59b1159',
        data: data,
        colorFn: (_, __) => MaterialPalette.blue.shadeDefault,
        domainFn: (value, index) => index,
        measureFn: (value, _) => value,
        strokeWidthPxFn: (_, __) => 4
      )
    ];
    return LineChart(
      series,
      animate: false,
      selectionModels: [
        SelectionModelConfig(
          type: SelectionModelType.info,
          changedListener: _onSelectionChanged
        )
      ],
    );
  }
}
