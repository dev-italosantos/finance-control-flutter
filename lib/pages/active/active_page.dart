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
  bool _hideValues = false;

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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Minha Carteira de Ativos',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            IconButton(
              icon: Icon(_hideValues ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                setState(() {
                  _hideValues = !_hideValues;
                });
              },
            ),
          ],
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
                // Adicione os novos campos aqui
                // Exemplo:
                // TextFormField(
                //   controller: tradingCodeController,
                //   decoration: const InputDecoration(labelText: 'Código de Negociação'),
                //   validator: (value) {
                //     if (value!.isEmpty) {
                //       return 'Por favor, insira o Código de Negociação';
                //     }
                //     return null;
                //   },
                // ),
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
                // Limpe os novos controladores aqui
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
                  final ticker = tickerController.text.toUpperCase();
                  final averagePrice = double.tryParse(averagePriceController.text) ?? 0.0;
                  final currentPrice = double.tryParse(currentPriceController.text) ?? 0.0;
                  final quantity = int.tryParse(quantityController.text) ?? 0;

                  if (ticker.isNotEmpty && averagePrice > 0 && currentPrice > 0 && quantity > 0) {
                    // Crie um novo objeto Asset com as informações editadas
                    final editedAsset = Asset(
                      ticker: ticker,
                      averagePrice: averagePrice,
                      currentPrice: currentPrice,
                      quantity: quantity,
                      transactions: List<Transaction>.from(asset.transactions),
                      // ... (outros campos do ativo)
                    );

                    // Encontre o índice do ativo na lista
                    final index = assets.indexOf(asset);

                    // Atualize as informações do ativo na lista
                    assets[index] = editedAsset;

                    // Salve as alterações
                    _saveAssets();

                    // Limpe os controladores
                    tickerController.clear();
                    averagePriceController.clear();
                    currentPriceController.clear();
                    quantityController.clear();

                    // Volte para a tela principal
                    setState(() {
                      selectedAsset = null;
                    });

                    // Recarregue os ativos
                    _loadAssets();

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

          // Verifica se 'transactions' existe e não é nulo
          final transactionsList = assetMap['transactions'] != null
              ? List<Transaction>.from(assetMap['transactions'].map((t) {
            return Transaction(
              date: DateTime.parse(t['date']),
              ticker: t['ticker'],
              type: t['type'] == 'buy' ? TransactionType.buy : TransactionType.sell,
              market: t['market'],
              maturityDate: DateTime.parse(t['maturityDate']),
              institution: t['institution'],
              tradingCode: t['tradingCode'],
              quantity: t['quantity'],
              price: t['price'],
              amount: t['amount'],
            );
          }))
              : []; // Se 'transactions' for nulo ou ausente, inicializa com uma lista vazia

          return Asset.fromJson(assetMap)..setTransactions = transactionsList.cast<Transaction>();
        }));
      });
    }
  }


  Future<Map<String, dynamic>?> getAssetDetails(String ticker) async {
    final apiUrl =
        'https://brapi.dev/api/quote/$ticker?token=m2VDSqSjN5diYAp5VjZSNv';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('Resposta JSON: $jsonData');

        if (jsonData != null &&
            jsonData['results'] != null &&
            jsonData['results'].isNotEmpty) {
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
        print(
            'Falha ao obter detalhes do ativo. Status: ${response.statusCode}');
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
      assetMap['transactions'] = asset.transactions.map((transaction) => {
        'date': transaction.date.toIso8601String(),
        'ticker': transaction.ticker,
        'type': transaction.type.toString(), // ou 'buy' conforme necessário
        'market': transaction.market,
        'maturityDate': transaction.maturityDate.toIso8601String(),
        'institution': transaction.institution,
        'tradingCode': transaction.tradingCode,
        'quantity': transaction.quantity,
        'price': transaction.price,
        'amount': transaction.amount,
      }).toList();
      return jsonEncode(assetMap);
    }).toList();
    await prefs.setStringList('assets', assetList);
  }

  void _addAsset(Asset newAsset) {
    // Verifica se o ativo já existe na lista
    final existingAsset = assets.firstWhereOrNull((asset) => asset.ticker == newAsset.ticker);

    if (existingAsset != null) {
      // Atualiza as informações do ativo existente
      final totalQuantity = existingAsset.quantity + newAsset.quantity;
      final totalInvested =
          (existingAsset.averagePrice * existingAsset.quantity) +
              (newAsset.averagePrice * newAsset.quantity);
      final updatedAveragePrice = totalInvested / totalQuantity;

      existingAsset.averagePrice = updatedAveragePrice;
      existingAsset.quantity = totalQuantity;

      // Adiciona novas transações sem duplicatas
      for (Transaction newTransaction in newAsset.transactions) {
        final existingTransactionIndex = existingAsset.transactions.indexWhere(
                (transaction) => transaction.date == newTransaction.date);

        if (existingTransactionIndex != -1) {
          // Atualiza a transação existente
          final existingTransaction =
          existingAsset.transactions[existingTransactionIndex];

          existingTransaction.amount += newTransaction.amount;
        } else {
          // Adiciona uma nova transação
          existingAsset.transactions.add(newTransaction);
        }
      }
    } else {
      // Adiciona um novo ativo se ele não existir
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
                    tickerController.clear();
                    averagePriceController.clear();
                    currentPriceController.clear();
                    quantityController.clear();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final ticker = tickerController.text.toUpperCase();
                      final currentPrice =
                          double.tryParse(currentPriceController.text) ?? 0.0;
                      final quantity =
                          int.tryParse(quantityController.text) ?? 0;

                      if (ticker.isNotEmpty &&
                          currentPrice > 0 &&
                          quantity > 0) {
                        // Verifica se o ativo já existe na lista
                        final existingAsset = assets.firstWhereOrNull(
                            (asset) => asset.ticker == ticker);

                        if (existingAsset != null) {
                          // Atualiza as informações do ativo existente
                          final totalQuantity =
                              existingAsset.quantity + quantity;
                          final totalInvested = (existingAsset.averagePrice *
                                  existingAsset.quantity) +
                              (currentPrice * quantity);
                          final updatedAveragePrice =
                              totalInvested / totalQuantity;

                          existingAsset.averagePrice = updatedAveragePrice;
                          existingAsset.quantity = totalQuantity;

                          // Adiciona uma nova transação ao ativo existente
                          existingAsset.addTransaction(Transaction(
                            date: DateTime.now(),
                            ticker: existingAsset.ticker,
                            type: TransactionType
                                .buy, // Ajuste conforme necessário
                            market: 'Bovespa', // Ajuste conforme necessário
                            maturityDate: DateTime.now().add(Duration(
                                days: 30)), // Ajuste conforme necessário
                            institution:
                                'Sua Instituição', // Ajuste conforme necessário
                            tradingCode: 'ABC123', // Ajuste conforme necessário
                            quantity: existingAsset.quantity,
                            price: existingAsset.currentPrice,
                            amount: existingAsset.currentPrice *
                                existingAsset.quantity,
                          ));
                        } else {
                          // Adiciona um novo ativo se ele não existir
                          final newAsset = Asset(
                            ticker: ticker,
                            averagePrice: currentPrice,
                            currentPrice: currentPrice,
                            quantity: quantity,
                            transactions: [], // Inicialize com uma lista vazia
                          );

                          // Adiciona uma nova transação ao novo ativo
                          newAsset.addTransaction(Transaction(
                            date: DateTime.now(),
                            ticker: newAsset.ticker,
                            type: TransactionType
                                .buy, // Ajuste conforme necessário
                            market: 'Bovespa', // Ajuste conforme necessário
                            maturityDate: DateTime.now().add(Duration(
                                days: 30)), // Ajuste conforme necessário
                            institution:
                                'Sua Instituição', // Ajuste conforme necessário
                            tradingCode: 'ABC123', // Ajuste conforme necessário
                            quantity: newAsset.quantity,
                            price: newAsset.currentPrice,
                            amount: newAsset.currentPrice * newAsset.quantity,
                          ));

                          _addAsset(newAsset);
                        }

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
              value: real.format(_calculateTotalInvested()),
            ),
            const SizedBox(height: 16),
            _infoRow(
              title: 'Total Atual',
              value: real.format(_calculateTotalCurrent()),
            ),
            const SizedBox(height: 16),
            _infoRow(
              title: 'Total Gained/Lost',
              value: real.format(totalGainedOrLost),
              valueColor: totalGainedOrLost >= 0 ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow({
    required String title,
    required String value,
    Color? valueColor,
  }) {
    if (_hideValues &&
        ['Custo Médio', 'Preço Médio', 'Rentabilidade'].contains(title)) {
      return const SizedBox
          .shrink(); // Oculta os valores numéricos quando _hideValues for verdadeiro
    }

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
        !_hideValues
            ? Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? Colors.white,
                ),
              )
            : Text(
                "R\$",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? Colors.white,
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
                                  !_hideValues
                                      ? Text(
                                          real.format(asset.totalAmount),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? Colors.black
                                                : Colors.white,
                                          ),
                                        )
                                      : Text(
                                          'R\$',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? Colors.black
                                                : Colors.white,
                                          ),
                                        )
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
                              !_hideValues
                                  ? Text(
                                      real.format(
                                          asset.averagePrice * asset.quantity),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    )
                                  : Text(
                                      'R\$',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isSelected
                                            ? Colors.black
                                            : Colors.grey,
                                      ),
                                    )
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
                              !_hideValues
                                  ? Text(
                                      real.format(asset.averagePrice),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    )
                                  : Text(
                                      'R\$',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isSelected
                                            ? Colors.black
                                            : Colors.grey,
                                      ),
                                    )
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
                                  !_hideValues
                                      ? Text(
                                          'R\$ ${asset.totalVariation.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: asset.totalVariation >= 0
                                                ? Colors.grey
                                                : Colors.red,
                                          ),
                                        )
                                      : Text(
                                          'R\$',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isSelected
                                                ? Colors.black
                                                : Colors.grey,
                                          ),
                                        )
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
