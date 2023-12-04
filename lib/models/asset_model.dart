class Asset {
  final String ticker;
  final double averagePrice;
  final double currentPrice;
  final int quantity;

  Asset({
    required this.ticker,
    required this.averagePrice,
    required this.currentPrice,
    required this.quantity,
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
    };
  }

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      ticker: json['ticker'],
      averagePrice: json['averagePrice'],
      currentPrice: json['currentPrice'],
      quantity: json['quantity'],
    );
  }

  double get totalVariation {
    return (currentPrice - averagePrice) * quantity;
  }
}