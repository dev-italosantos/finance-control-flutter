import 'package:flutter/material.dart';
import 'package:flutter_investment_control/models/asset_model.dart';

class ExtratoPage extends StatelessWidget {
  final List<Asset> assets;

  ExtratoPage({required this.assets});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extrato de Ativos'),
        backgroundColor: Colors.black,
      ),
      body: ListView.builder(
        itemCount: assets.length,
        itemBuilder: (context, index) {
          final asset = assets[index];
          return Card(
            margin: const EdgeInsets.all(16),
            child: Column(
              children: [
                ListTile(
                  title: Text('${asset.ticker} - ${asset.quantity} Cotas'),
                  subtitle: Text(
                      'Custo Médio: ${asset.averagePrice.toStringAsFixed(2)}'),
                ),
                // Adicione aqui a lista de transações do ativo
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: asset.transactions.length,
                  itemBuilder: (context, transactionIndex) {
                    final transaction = asset.transactions[transactionIndex];
                    return ListTile(
                      title: Text(
                          'Transação: ${transaction.amount.toStringAsFixed(2)}'),
                      subtitle: Text('Data: ${transaction.date.toString()}'),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
