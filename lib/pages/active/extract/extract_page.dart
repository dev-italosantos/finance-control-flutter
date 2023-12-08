import 'package:flutter/material.dart';
import 'package:flutter_investment_control/models/asset_model.dart';
import 'package:flutter_investment_control/models/transaction_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_investment_control/pages/active/extract/allTransactions/all_transactions_page.dart';
import 'package:flutter_investment_control/services/api_service.dart';
import 'package:flutter_investment_control/services/asset_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ExtratoPage extends StatefulWidget {
  ExtratoPage({Key? key}) : super(key: key);

  @override
  _ExtratoPageState createState() => _ExtratoPageState();
}

class _ExtratoPageState extends State<ExtratoPage> {
  late List<Asset> assets = [];

  final ApiService _apiService = ApiService();

  DateTime _parseDate(String dateString) {
    try {
      if (dateString == '-') {
        return DateTime(2000, 1, 1);
      }

      final parts = dateString.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);

        return DateTime(year, month, day);
      } else {
        throw FormatException('Formato de data inválido: $dateString');
      }
    } catch (e) {
      throw FormatException('Erro ao processar a data: $e');
    }
  }

  double _extractNumericValue(String valueString) {
    try {
      final cleanedValue = double.parse(valueString.replaceAll(RegExp(r'[^\d.]'), ''));
      return cleanedValue;
    } catch (e) {
      throw ArgumentError('Erro ao extrair valor numérico: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Future<void> _loadData() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final assetList = prefs.getStringList('assets');
  //
  //     if (assetList != null) {
  //       final loadedAssets = assetList.map((json) => Asset.fromJson(jsonDecode(json))).toList();
  //       context.read<AssetProvider>().updateAssets(loadedAssets);
  //
  //       setState(() {
  //         assets = List.from(loadedAssets);
  //       });
  //
  //       // Adicione esta linha para notificar o AssetProvider após atualizar o estado local
  //       context.read<AssetProvider>().updateAssets(assets);
  //
  //     }
  //   } catch (e) {
  //     print("Erro ao carregar dados: $e");
  //   }
  // }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final assetList = prefs.getStringList('assets');

    if (assetList != null) {
      final loadedAssets = assetList.map((json) => Asset.fromJson(jsonDecode(json))).toList();
      context.read<AssetProvider>().updateAssets(loadedAssets);

      setState(() {
        assets = List.from(loadedAssets);
      });
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final assetList = assets.map((asset) => jsonEncode(asset.toJson())).toList();
      prefs.setStringList('assets', assetList);
    } catch (e) {
      print("Erro ao salvar dados: $e");
    }
  }

  @override
  void dispose() {
    _saveData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Extrato de Ativos'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.upload_file),
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['csv'],
              );
              if (result != null) {
                final PlatformFile file = result.files.single;

                try {
                  final lines = await File(file.path!).readAsLines();
                  final transactionsByTradingCode = <String, List<Transaction>>{};

                  lines.skip(1).forEach((line) {
                    final columns = line.split(',');

                    final date = _parseDate(columns[0]);
                    final ticker = columns[5];
                    final type = _getTypeFromString(columns[1]);
                    final market = columns[2];
                    final maturityDate = _parseDate(columns[3]);
                    final institution = columns[4];
                    final tradingCode = columns[5];
                    final quantity = int.parse(columns[6]);
                    final price = _extractNumericValue(columns[7]);
                    final amount = _extractNumericValue(columns[8]);

                    final transaction = Transaction(
                      date: date,
                      ticker: ticker,
                      type: type,
                      market: market,
                      maturityDate: maturityDate,
                      institution: institution,
                      tradingCode: tradingCode,
                      quantity: quantity,
                      price: price,
                      amount: amount,
                    );

                    transactionsByTradingCode
                        .putIfAbsent(tradingCode, () => [])
                        .add(transaction);
                  });

                  transactionsByTradingCode.entries.forEach((entry) async {
                    final tradingCode = entry.key;
                    final transactions = entry.value;

                    final existingAssetIndex =
                    assets.indexWhere((asset) => asset.ticker == tradingCode);

                    if (existingAssetIndex != -1) {
                      final existingAsset = assets[existingAssetIndex];
                      existingAsset.transactions.addAll(transactions);

                      final totalAmount =
                      transactions.fold(0.0, (sum, transaction) => sum + transaction.amount);
                      final totalQuantity =
                      transactions.fold(0, (sum, transaction) => sum + transaction.quantity);
                      final averagePrice = totalAmount / totalQuantity;

                      if (totalQuantity > 0) {
                        existingAsset.averagePrice = averagePrice;
                      }

                      existingAsset.quantity += totalQuantity;

                      final assetDetails =
                      await _apiService.getAssetDetails(tradingCode);

                      if (assetDetails != null) {
                        setState(() {
                          existingAsset.currentPrice = assetDetails['currentPrice'];
                        });
                      }

                      context.read<AssetProvider>().updateAssets(assets); // Adicione esta linha
                    } else {
                      final newAsset = Asset(
                        ticker: tradingCode,
                        quantity: transactions.fold(0, (sum, transaction) => sum + transaction.quantity),
                        averagePrice: transactions.fold(0.0, (sum, transaction) => sum + transaction.amount) /
                            transactions.fold(0, (sum, transaction) => sum + transaction.quantity),
                        transactions: transactions,
                        currentPrice: 0.0,
                      );

                      assets.add(newAsset);

                      final assetDetails =
                      await _apiService.getAssetDetails(tradingCode);

                      if (assetDetails != null) {
                        setState(() {
                          newAsset.currentPrice = assetDetails['currentPrice'];
                        });
                      }
                    }

                    context.read<AssetProvider>().updateAssets(assets);
                  });

                  setState(() {
                    // Não precisamos mais da lista newAssets
                  });
                } catch (e) {
                  print("Erro ao processar o arquivo CSV: $e");
                }
              } else {
                // Usuário cancelou o seletor de arquivos
              }
            },
          ),
        ],
      ),
      body: Consumer<AssetProvider>(
        builder: (context, assetProvider, _) {

          return ListView.builder(
            itemCount: assets.length,
            itemBuilder: (context, index) {
              final asset = assets[index];

              // Ordenar as transações por data, da mais recente para a mais antiga
              asset.transactions.sort((a, b) => b.date.compareTo(a.date));

              return Card(
                elevation: 4,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(12),
                          ),
                        ),
                        title: Text(
                          '${asset.ticker} - ${asset.quantity} Cotas',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5),
                            Text(
                              'Custo Médio: ${asset.averagePrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: asset.transactions.length > 1
                            ? 1
                            : asset.transactions.length,
                        itemBuilder: (context, transactionIndex) {
                          final transaction = asset.transactions[transactionIndex];
                          return Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Transação: ${transaction.quantity} unidades por ${(transaction.price * transaction.quantity).toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Data: ${transaction.date.toString()}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Mercado: ${transaction.market}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tipo: ${_getTypeString(transaction.type)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Instituição: ${transaction.institution}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(
                                    height: 8),
                                if (asset.transactions.length > 1 &&
                                    transactionIndex == 0)
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AllTransactionsPage(asset: asset),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Ver mais transações...',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _getTypeString(TransactionType type) {
    switch (type) {
      case TransactionType.buy:
        return 'Compra';
      case TransactionType.sell:
        return 'Venda';
    }
  }

  TransactionType _getTypeFromString(String typeString) {
    try {
      final cleanedString = typeString
          .trim()
          .toLowerCase();

      if (cleanedString.contains('compra')) {
        return TransactionType.buy;
      } else if (cleanedString.contains('venda')) {
        return TransactionType.sell;
      } else {
        throw ArgumentError('Tipo de transação desconhecido: $typeString');
      }
    } catch (e) {
      throw ArgumentError('Erro ao processar o tipo de transação: $e');
    }
  }
}
