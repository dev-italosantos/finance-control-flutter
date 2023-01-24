import 'dart:math';

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

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
