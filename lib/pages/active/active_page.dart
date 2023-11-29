import 'package:flutter/material.dart';
import 'package:flutter_investment_control/pages/home_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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

class _AssetListState extends State<AssetList> {
  List<Asset> assets = [];
  Set<Asset> selectedAssets = Set<Asset>(); // Usaremos um conjunto para armazenar os ativos selecionados

  Color selectedBackgroundColor = Colors.blue;

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

  appBarDynamics() {
    if (selectedAssets.isEmpty) {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Future.delayed(const Duration(seconds: 1)).then(
                  (value) => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
                ),
              ),
            );
          },
        ),
        title: const Text(
          'Minha Carteira de Ativos',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
      );
    } else {
      return AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              Future.delayed(const Duration(seconds: 1)).then(
                    (value) => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  ),
                ),
              );
            });
          },
        ),
        title: Text('${selectedAssets.length} selecionadas'),
      );
    }
  }

  Future<void> _loadAssets() async {
    final prefs = await SharedPreferences.getInstance();
    final assetList = prefs.getStringList('assets');

    if (assetList != null) {
      setState(() {
        assets.clear();
        assets
            .addAll(assetList.map((json) => Asset.fromJson(jsonDecode(json))));
      });
    }
  }

  Future<void> _saveAssets() async {
    final prefs = await SharedPreferences.getInstance();
    final assetList =
    assets.map((asset) => jsonEncode(asset.toJson())).toList();
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
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
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
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
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
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
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

  Widget _bottomAction(IconData icon) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon),
      ),
      onTap: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarDynamics(),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            color: Colors.grey[900],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'Total Gained/Lost:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'R\$ ${totalGainedOrLost.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
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
                final isSelected = selectedAssets.contains(asset);

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? selectedBackgroundColor
                          : Colors.grey[900], // Alterado para usar a variável selectedBackgroundColor
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(12),
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${asset.ticker} - ${asset.quantity} Cotas',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white, // Cor do texto
                                ),
                              ),
                              Text(
                                'R\$ ${asset.totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Custo Médio',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                'R\$ ${(asset.averagePrice * asset.quantity).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Preço Médio',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                'R\$ ${asset.averagePrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Última Cotação',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                'R\$ ${asset.currentPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              const Text(
                                'Rentabilidade',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              Row(
                                children: <Widget>[
                                  Text(
                                    '${asset.profitability.toStringAsFixed(2)}%',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: asset.profitability >= 0
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'R\$ ${asset.totalVariation.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: asset.totalVariation >= 0
                                          ? Colors.grey
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      selected: isSelected,
                      onLongPress: () {
                        setState(() {
                          isSelected
                              ? selectedAssets.remove(asset)
                              : selectedAssets.add(asset);
                        });
                        selectedBackgroundColor = (isSelected
                            ? Colors.grey[900]
                            : Colors.blue)!; // Defina a cor desejada
                      },

                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        notchMargin: 8.0,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _bottomAction(FontAwesomeIcons.clockRotateLeft),
            _bottomAction(FontAwesomeIcons.chartPie),
            const SizedBox(width: 48.0),
            _bottomAction(FontAwesomeIcons.wallet),
            _bottomAction(Icons.settings),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(150, 150, 150, 1.0),
        child: const Icon(Icons.add),
        onPressed: () {
          _showAddAssetDialog(context);
        },
      ),
    );
  }
}
