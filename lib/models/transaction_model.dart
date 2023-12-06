class Transaction {
  final String ticker;
  final double amount;
  final DateTime date;

  Transaction({
    required this.ticker,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'ticker': ticker,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      ticker: json['ticker'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
    );
  }
}
