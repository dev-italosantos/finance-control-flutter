import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key});
  static const String _title = 'Minha Carteira de Ativos';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AssetList(),
    );
  }
}

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

  double get totalAmount => currentPrice * quantity;
  double get profitability => (currentPrice - averagePrice) / averagePrice * 100;

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

class _AssetListState extends State<AssetList> {
  final List<Asset> assets = [];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController tickerController = TextEditingController();
  final TextEditingController averagePriceController = TextEditingController();
  final TextEditingController currentPriceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    final prefs = await SharedPreferences.getInstance();
    final assetList = prefs.getStringList('assets');

    if (assetList != null) {
      setState(() {
        assets.clear();
        assets.addAll(assetList.map((json) => Asset.fromJson(jsonDecode(json))));
        });
    }
  }

  Future<void> _saveAssets() async {
    final prefs = await SharedPreferences.getInstance();
    final assetList = assets.map((asset) => jsonEncode(asset.toJson())).toList();
    await prefs.setStringList('assets', assetList);
  }

  void _addAsset(Asset newAsset) {
    setState(() {
      assets.add(newAsset);
    });
    _saveAssets();
  }

  void _showAddAssetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Adicionar Ativo'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: tickerController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(labelText: 'Ticker'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor, insira um Ticker';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: averagePriceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Preço Médio'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor, insira o Preço Médio';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: currentPriceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Preço Atual'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor, insira o Preço Atual';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: quantityController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Quantidade'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor, insira a Quantidade';
                    }
                    return null;
                  },
                ),
              ],
            ),
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
                if (_formKey.currentState!.validate()) {
                  final ticker = tickerController.text.toUpperCase();
                  final averagePrice = double.tryParse(averagePriceController.text) ?? 0.0;
                  final currentPrice = double.tryParse(currentPriceController.text) ?? 0.0;
                  final quantity = int.tryParse(quantityController.text) ?? 0;

                  if (ticker.isNotEmpty && averagePrice > 0 && currentPrice > 0 && quantity > 0) {
                    final newAsset = Asset(
                      ticker: ticker,
                      averagePrice: averagePrice,
                      currentPrice: currentPrice,
                      quantity: quantity,
                    );

                    _addAsset(newAsset);

                    // Limpe os controladores do formulário
                    tickerController.clear();
                    averagePriceController.clear();
                    currentPriceController.clear();
                    quantityController.clear();

                    Navigator.of(context).pop();
                  }
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  double get totalGainedOrLost {
    double totalVariation = 0.0;
    for (final asset in assets) {
      totalVariation += asset.totalVariation;
    }
    return totalVariation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //     children: <Widget>[
      //       const Text(
      //         'Minha Carteira de Ativos',
      //         style: TextStyle(
      //           fontSize: 15,
      //           color: Colors.white70,
      //           fontFamily: 'Monospace',
      //         ),
      //       ),
      //       Text(
      //         'Total: R\$ ${totalGainedOrLost.toStringAsFixed(2)}',
      //         style: const TextStyle(
      //           fontSize: 13,
      //           // fontWeight: FontWeight.bold,
      //           color: Colors.white70,
      //           fontFamily: 'Monospace',
      //         ),
      //       ),
      //     ],
      //   ),
      //   backgroundColor: Colors.black,
      // ),

      appBar: AppBar(
        title: const Text(
          'Minha Carteira de Ativos',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
            fontFamily: 'Monospace',
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            color: Colors.black,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'Total Gained/Lost:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    'R\$ ${totalGainedOrLost.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                      fontFamily: 'Monospace',
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
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
                            Text(
                              'R\$ ${asset.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
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
                              'Preço Médio',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'R\$ ${asset.averagePrice.toStringAsFixed(2)}',
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
                            Row(
                              children: <Widget>[
                                Text(
                                  'R\$ ${asset.totalVariation.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: asset.totalVariation >= 0 ? Colors.green : Colors.red,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${asset.profitability.toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: asset.profitability >= 0 ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddAssetDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
