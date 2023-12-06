import 'package:flutter/material.dart';
import 'package:flutter_investment_control/models/asset_model.dart';
import 'package:flutter_investment_control/models/transaction_model.dart';
import 'package:flutter_investment_control/pages/active/extract/extract_page.dart';
import 'package:flutter_investment_control/pages/active/graph/graph_page.dart';
import 'package:flutter_investment_control/pages/home_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:collection/collection.dart';

class AssetList extends StatefulWidget {
  const AssetList({Key? key}) : super(key: key);

  @override
  State<AssetList> createState() => _AssetListState();
}

class _AssetListState extends State<AssetList> {
  List<Asset> assets = [];
  Asset? selectedAsset; // Alteração para armazenar apenas um ativo selecionado
  NumberFormat real = NumberFormat.currency(locale: 'pt-br', name: 'R\$');
  Color? selectedBackgroundColor = Colors.grey[900];
  String? selectedAssetCode;
  List<String> availableAssetCodes =
      []; // Adicione esta linha para rastrear os códigos de ativos disponíveis
  bool isAddAssetDialogOpen = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController tickerController = TextEditingController();
  final TextEditingController averagePriceController = TextEditingController();
  final TextEditingController currentPriceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedAssetCode = null;
    _loadAssets();
  }

  appBarDynamics() {
    if (selectedAsset == null) {
      return AppBar(
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
        title: Text(
          '${selectedAsset!.ticker} selecionado',
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _showEditAssetDialog(context, selectedAsset!);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteAssetDialog(context, selectedAsset!);
            },
          ),
        ]
            .where((_) => selectedAsset != null)
            .toList(), // Adiciona a verificação condicional aqui
      );
    }
  }

  void _showEditAssetDialog(BuildContext context, Asset asset) {
    // Inicialize os controladores com os valores do ativo selecionado
    tickerController.text = asset.ticker;
    averagePriceController.text = asset.averagePrice.toString();
    currentPriceController.text = asset.currentPrice.toString();
    quantityController.text = asset.quantity.toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Ativo'),
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
                tickerController.clear();
                averagePriceController.clear();
                currentPriceController.clear();
                quantityController.clear();
                Navigator.of(context).pop();

                setState(() {
                  selectedAsset = null;
                });
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Lógica para editar o ativo
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
                    final editedAsset = Asset(
                      ticker: ticker,
                      averagePrice: averagePrice,
                      currentPrice: currentPrice,
                      quantity: quantity,
                      transactions: [],
                    );

                    // Substitua o ativo antigo pelo ativo editado na lista
                    final index = assets.indexOf(asset);
                    assets[index] = editedAsset;

                    // Salve as alterações
                    _saveAssets();

                    // Recarregue os ativos
                    _loadAssets();

                    // Limpe os controladores do formulário
                    tickerController.clear();
                    averagePriceController.clear();
                    currentPriceController.clear();
                    quantityController.clear();

                    // Redefina selectedAsset para null
                    setState(() {
                      selectedAsset = null;
                    });

                    // Feche o diálogo
                    Navigator.of(context).pop();
                  }
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAssetDialog(BuildContext context, Asset asset) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Excluir Ativo'),
          content: const Text('Tem certeza que deseja excluir este ativo?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // Adicione a lógica para excluir o ativo aqui
                // Você pode acessar as propriedades do ativo usando a instância 'asset'
                // Remova o ativo da lista e salve as alterações
                // Após excluir, você pode chamar _loadAssets() para atualizar a lista
                assets.remove(asset);
                _saveAssets();
                _loadAssets();
                selectedAsset = null;
                Navigator.of(context).pop();
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadAssets() async {
    final prefs = await SharedPreferences.getInstance();
    final assetList = prefs.getStringList('assets');

    if (assetList != null) {
      setState(() {
        assets.clear();
        assets.addAll(assetList.map((json) {
          final assetMap = jsonDecode(json);
          final transactionsList = assetMap['transactions'] != null
              ? List<Transaction>.from(assetMap['transactions'].map((t) => Transaction.fromJson(t)))
              : [];
          return Asset.fromJson(assetMap)..setTransactions = transactionsList.cast<Transaction>();
        }));
      });
    }
  }


  Future<Map<String, dynamic>?> getAssetDetails(String ticker) async {
    final apiUrl = 'https://brapi.dev/api/quote/$ticker?token=m2VDSqSjN5diYAp5VjZSNv';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('Resposta JSON: $jsonData');

        if (jsonData != null && jsonData['results'] != null && jsonData['results'].isNotEmpty) {
          final assetDetails = {
            'currentPrice': jsonData['results'][0]['regularMarketPrice'] ?? 0.0,
          };

          return assetDetails;
        } else {
          print('Detalhes do ativo não encontrados para o ticker: $ticker');
          // Adicione lógica para lidar com a ausência de detalhes do ativo
          return null;
        }
      } else {
        print('Falha ao obter detalhes do ativo. Status: ${response.statusCode}');
        // Adicione lógica para lidar com falhas na resposta do servidor
        return null;
      }
    } catch (error) {
      print('Erro ao obter detalhes do ativo: $error');
      // Adicione lógica para lidar com exceções durante a solicitação HTTP
      throw error;
    }
  }



  Future<void> _saveAssets() async {
    final prefs = await SharedPreferences.getInstance();
    final assetList = assets.map((asset) {
      final assetMap = asset.toJson();
      assetMap['transactions'] = asset.transactions.map((transaction) => transaction.toJson()).toList();
      return jsonEncode(assetMap);
    }).toList();
    await prefs.setStringList('assets', assetList);
  }


  void _addAsset(Asset newAsset) {
    // Verifica se o ativo já existe na lista
    final existingAsset =
    assets.firstWhereOrNull((asset) => asset.ticker == newAsset.ticker);

    if (existingAsset != null) {
      // Atualiza as informações do ativo existente
      final totalQuantity = existingAsset.quantity + newAsset.quantity;
      final totalInvested =
          (existingAsset.averagePrice * existingAsset.quantity) +
              (newAsset.averagePrice * newAsset.quantity);
      final updatedAveragePrice = totalInvested / totalQuantity;

      existingAsset.averagePrice = updatedAveragePrice;
      existingAsset.quantity = totalQuantity;
    } else {
      // Adiciona um novo ativo se ele não existir
      newAsset.addTransaction(Transaction(
        ticker: newAsset.ticker,
        amount: newAsset.currentPrice * newAsset.quantity,
        date: DateTime.now(),
      ));
      assets.add(newAsset);
    }

    setState(() {
      selectedAsset = null;
    });

    _saveAssets();
  }

  void _showAddAssetDialog(BuildContext context) async {
    setState(() {
      isAddAssetDialogOpen = true;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
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
                      onChanged: (ticker) async {
                        if (ticker.isNotEmpty) {
                          final assetDetails = await getAssetDetails(ticker);

                          if (assetDetails != null) {
                            setState(() {
                              currentPriceController.text =
                                  assetDetails['currentPrice'].toString();
                            });
                          } else {
                            // Tratar caso não encontre os detalhes do ativo
                          }
                        }
                      },
                    ),
                    TextFormField(
                      controller: currentPriceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration:
                          const InputDecoration(labelText: 'Preço Atual'),
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
                      decoration:
                          const InputDecoration(labelText: 'Quantidade'),
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
                      final currentPrice =
                          double.tryParse(currentPriceController.text) ?? 0.0;
                      final quantity =
                          int.tryParse(quantityController.text) ?? 0;

                      if (ticker.isNotEmpty &&
                          currentPrice > 0 &&
                          quantity > 0) {
                        final newAsset = Asset(
                          ticker: ticker,
                          averagePrice: currentPrice,
                          currentPrice: currentPrice,
                          quantity: quantity,
                          transactions: [],
                        );

                        _addAsset(newAsset);

                        tickerController.clear();
                        averagePriceController.clear();
                        currentPriceController.clear();
                        quantityController.clear();
                        selectedAssetCode = null;

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
      },
    ).then((value) {
      setState(() {
        isAddAssetDialogOpen = false;
      });
    });
  }

  Widget _bottomAction(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon),
      ),
    );
  }

  Widget _totalInfoCard() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _infoRow(
                title: 'Total Investido',
                amount: _calculateTotalInvested(),
              ),
              const SizedBox(height: 16),
              _infoRow(
                title: 'Total Atual',
                amount: _calculateTotalCurrent(),
              ),
              const SizedBox(height: 16),
              _infoRow(
                title: 'Total Gained/Lost',
                amount: totalGainedOrLost,
                amountColor: totalGainedOrLost >= 0 ? Colors.green : Colors.red,
              ),
            ]),
      ),
    );
  }

  Widget _infoRow({
    required String title,
    required double amount,
    Color? amountColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'R\$ ${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: amountColor ?? Colors.white,
          ),
        ),
      ],
    );
  }

  double _calculateTotalInvested() {
    double totalInvested = 0.0;
    for (final asset in assets) {
      totalInvested += asset.averagePrice * asset.quantity;
    }
    return totalInvested;
  }

  double _calculateTotalCurrent() {
    double totalCurrent = 0.0;
    for (final asset in assets) {
      totalCurrent += asset.currentPrice * asset.quantity;
    }
    return totalCurrent;
  }

  double get totalGainedOrLost {
    double totalVariation = 0.0;
    for (final asset in assets) {
      totalVariation += asset.totalVariation;
    }
    return totalVariation;
  }

  navigateToGraphPage(List<Asset> assetList) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GraphPage(assetList: assetList),
      ),
    );
    // Adicione aqui a lógica para navegar para outra tela específica
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarDynamics(),
      body: Column(
        children: [
          _totalInfoCard(),
          Expanded(
            child: ListView.builder(
              itemCount: assets.length,
              itemBuilder: (context, index) {
                final asset = assets[index];
                final isSelected = selectedAsset ==
                    asset; // Alteração para verificar se o ativo está selecionado
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? selectedBackgroundColor
                          : Colors.grey[
                              900], // Alterado para usar a variável selectedBackgroundColor
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
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isSelected ? Colors.black : Colors.white,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${((asset.totalAmount / _calculateTotalCurrent()) * 100).toStringAsFixed(2)}%',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    real.format(asset.totalAmount),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                real.format(
                                    asset.averagePrice * asset.quantity),
                                style: const TextStyle(
                                  fontSize: 14,
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
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                real.format(asset.averagePrice),
                                style: const TextStyle(
                                  fontSize: 14,
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
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                real.format(asset.currentPrice),
                                style: const TextStyle(
                                  fontSize: 14,
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
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              Row(
                                children: <Widget>[
                                  Text(
                                    '${asset.profitability.toStringAsFixed(2)}%',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: asset.profitability >= 0
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'R\$ ${asset.totalVariation.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 14,
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
                      onTap: () {
                        setState(() {
                          selectedAsset = isSelected
                              ? null
                              : asset; // Seleciona ou deseleciona o ativo
                        });
                        selectedBackgroundColor = (isSelected
                            ? Colors.grey[900]
                            : Colors.white)!; // Define a cor desejada
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
            _bottomAction(FontAwesomeIcons.clockRotateLeft, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ExtratoPage(
                          assets: assets,
                        )),
              );
            }),
            _bottomAction(
                FontAwesomeIcons.chartPie, () => navigateToGraphPage(assets)),
            const SizedBox(width: 48.0),
            _bottomAction(FontAwesomeIcons.wallet, () => navigateToGraphPage),
            _bottomAction(Icons.settings, () => navigateToGraphPage),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: !isAddAssetDialogOpen && selectedAsset == null
          ? FloatingActionButton(
              backgroundColor: const Color.fromRGBO(150, 150, 150, 1.0),
              child: const Icon(Icons.add),
              onPressed: () {
                _showAddAssetDialog(context);
              },
            )
          : null,
    );
  }
}
