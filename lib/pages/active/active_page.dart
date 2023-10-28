import "package:flutter/material.dart";

class AssetList extends StatefulWidget {
  const AssetList({Key? key});

  @override
  _AssetListState createState() => _AssetListState();
}

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

  double get totalInvested => averagePrice * quantity;
  double get profitability =>
      (currentPrice - averagePrice) / averagePrice * 100;
}

class _AssetListState extends State<AssetList> {
  final List<Asset> assets = [];

  final TextEditingController tickerController = TextEditingController();
  final TextEditingController averagePriceController = TextEditingController();
  final TextEditingController currentPriceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Carteira de Ativos'),
      ),
      body: ListView.builder(
        itemCount: assets.length,
        itemBuilder: (context, index) {
          final asset = assets[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        '${asset.ticker} - ${asset.quantity} Cotas',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text(
                        'Última Cotação',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'R\$ ${asset.currentPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text(
                        'Valor total investido',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'R\$ ${asset.totalInvested.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text(
                        'Rentabilidade',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${asset.profitability.toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontSize: 16,
                          color: asset.profitability >= 0
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddAssetDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddAssetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Adicionar Ativo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: tickerController,
                decoration: const InputDecoration(labelText: 'Ticker'),
              ),
              TextField(
                controller: averagePriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Preço Médio'),
              ),
              TextField(
                controller: currentPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Preço Atual'),
              ),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantidade'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final ticker = tickerController.text;
                final averagePrice =
                    double.tryParse(averagePriceController.text) ?? 0.0;
                final currentPrice =
                    double.tryParse(currentPriceController.text) ?? 0.0;
                final quantity = int.tryParse(quantityController.text) ?? 0;

                if (ticker.isNotEmpty &&
                    averagePrice > 0 &&
                    currentPrice > 0 &&
                    quantity > 0) {
                  final newAsset = Asset(
                    ticker: ticker,
                    averagePrice: averagePrice,
                    currentPrice: currentPrice,
                    quantity: quantity,
                  );

                  setState(() {
                    assets.add(newAsset);
                  });

                  Navigator.of(context).pop();
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }
}
