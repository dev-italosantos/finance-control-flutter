class Transaction {
  final String ticker;
  final double amount;
  final DateTime date;

  Transaction({
    required this.ticker,
    required this.amount,
    required this.date,
  });
}