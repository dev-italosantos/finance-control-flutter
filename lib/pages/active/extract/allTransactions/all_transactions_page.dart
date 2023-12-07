import 'package:flutter/material.dart';
import 'package:flutter_investment_control/models/transaction_model.dart';

class AllTransactionsPage extends StatelessWidget {
  final List<Transaction> transactions;

  AllTransactionsPage({required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todas as Transações'),
      ),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return ListTile(
            title: Text(
              'Transação: ${transaction.quantity} unidades por ${(transaction.price * transaction.quantity).toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
}
