class Transaction {
   DateTime date;
   String ticker;
   TransactionType type; // Adicione o tipo de movimentação (compra/venda)
   String market; // Adicione o mercado
   DateTime maturityDate; // Adicione o prazo/vencimento
   String institution; // Adicione a instituição
   String tradingCode; // Adicione o código de negociação
  int quantity;
  final double price;
  double amount;

  Transaction({
    required this.date,
    required this.ticker,
    required this.type,
    required this.market,
    required this.maturityDate,
    required this.institution,
    required this.tradingCode,
    required this.quantity,
    required this.price,
    required this.amount,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      date: DateTime.parse(json['date']),
      ticker: json['ticker'],
      type: json['type'],
      market: json['market'],
      maturityDate: DateTime.parse(json['maturityDate']),
      institution: json['institution'],
      tradingCode: json['tradingCode'],
      quantity: json['quantity'],
      price: json['price'],
      amount: json['amount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'ticker': ticker,
      'type': type,
      'market': market,
      'maturityDate': maturityDate.toIso8601String(),
      'institution': institution,
      'tradingCode': tradingCode,
      'quantity': quantity,
      'price': price,
      'amount': amount,
    };
  }
}

// Adicione o enum para o tipo de movimentação
enum TransactionType {
  buy,
  sell,
}
