import 'package:flutter_investment_control/models/transaction_model.dart';

class Asset {
  String ticker;
  String segment;
  String activeType;
  double averagePrice;
  double currentPrice;
  int quantity;

  List<Transaction> transactions;
  bool isFullyLiquidated;

  Asset({
    required this.ticker,
    required this.activeType,
    required this.segment,
    required this.averagePrice,
    required this.currentPrice,
    required this.quantity,
    required this.transactions,
    required this.isFullyLiquidated
  });

  double get totalAmount => currentPrice * quantity;
  double get profitability =>
      (currentPrice - averagePrice) / averagePrice * 100;

  Map<String, dynamic> toJson() {
    return {
      'ticker': ticker,
      'segment': segment,
      'activeType': activeType,
      'averagePrice': averagePrice,
      'currentPrice': currentPrice,
      'quantity': quantity,
      'transactions': transactions.map((transaction) => transaction.toJson()).toList(),
      'isFullyLiquidated': isFullyLiquidated,
    };
  }

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      ticker: json['ticker'],
      segment: json['segment'] as String? ?? '',
      activeType: json['activeType'] as String ?? '',
      averagePrice: json['averagePrice'],
      currentPrice: json['currentPrice'],
      quantity: json['quantity'],
      transactions: (json['transactions'] as List<dynamic>?)
          ?.map((transactionJson) => Transaction.fromJson(transactionJson as Map<String, dynamic>))
          .toList() ??
          [],  isFullyLiquidated: json['isFullyLiquidated'] ?? false,
    );
  }

  double get totalVariation {
    return (currentPrice - averagePrice) * quantity;
  }

  void addTransaction(Transaction transaction) {
    transactions.add(transaction);
  }

  set setTransactions(List<Transaction> value) {
    transactions = value;
  }
}
