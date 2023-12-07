import 'package:flutter/material.dart';
import 'package:flutter_investment_control/models/asset_model.dart';
import 'package:flutter_investment_control/models/transaction_model.dart';

class AllTransactionsPage extends StatelessWidget {
  final Asset asset;

  AllTransactionsPage({required this.asset});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarDynamics(),
      body: ListView.builder(
        itemCount: asset.transactions.length,
        itemBuilder: (context, index) {
          final transaction = asset.transactions[index];
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transação: ${transaction.quantity} unidades por ${(transaction.price * transaction.quantity).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Data: ${transaction.date.toString()}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mercado: ${transaction.market}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tipo: ${_getTypeString(transaction.type)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Instituição: ${transaction.institution}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getTypeString(TransactionType type) {
    switch (type) {
      case TransactionType.buy:
        return 'Compra';
      case TransactionType.sell:
        return 'Venda';
    }
  }

  AppBar appBarDynamics() {
    return AppBar(
      backgroundColor: Colors.black,
      title: Text(
        '${asset.ticker} selecionado',
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}


