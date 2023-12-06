import 'package:flutter_investment_control/models/transaction_model.dart';

class Asset {
   String ticker;
   double averagePrice;
   double currentPrice;
   int quantity;

  List<Transaction> transactions;

  Asset({
    required this.ticker,
    required this.averagePrice,
    required this.currentPrice,
    required this.quantity,
    required this.transactions,
  });

  double get totalAmount => currentPrice * quantity;
  double get profitability =>
      (currentPrice - averagePrice) / averagePrice * 100;

  Map<String, dynamic> toJson() {
    return {
      'ticker': ticker,
      'averagePrice': averagePrice,
      'currentPrice': currentPrice,
      'quantity': quantity,
      'transactions': transactions.map((transaction) => transaction.toJson()).toList(),
    };
  }

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      ticker: json['ticker'],
      averagePrice: json['averagePrice'],
      currentPrice: json['currentPrice'],
      quantity: json['quantity'],
      transactions: (json['transactions'] as List<dynamic>?)
          ?.map((transactionJson) => Transaction.fromJson(transactionJson as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  double get totalVariation {
    return (currentPrice - averagePrice) * quantity;
  }

  void addTransaction(Transaction transaction) {
    transactions.add(transaction);
  }

  // Adicione este setter
  set setTransactions(List<Transaction> value) {
    transactions = value;
  }
}