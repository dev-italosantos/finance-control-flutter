import 'package:flutter/material.dart';
import 'package:flutter_investment_control/models/active_model.dart';
import 'package:intl/intl.dart';

class ActiveDetalisPage extends StatefulWidget {
  Active active;

  ActiveDetalisPage({Key ? key, required this.active}) : super(key: key);

  @override
  _ActiveDetalisPageState createState() => _ActiveDetalisPageState();
}

class _ActiveDetalisPageState extends State<ActiveDetalisPage> {
  NumberFormat real = NumberFormat.currency(locale: 'pt-br', name: 'R\$');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.active.name),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [

            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 50,
                    child: Image.asset(widget.active.icon),
                  ),
                  Container(width: 30,)
                ],
              ),
            )
          ]
        ),
      )
    );
  }
}
