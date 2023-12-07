import 'package:flutter/material.dart';
import 'package:flutter_investment_control/models/asset_model.dart';
import 'package:flutter_investment_control/models/transaction_model.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ExtratoPage extends StatefulWidget {
  final List<Asset> assets;

  ExtratoPage({Key? key, required this.assets}) : super(key: key);

  @override
  _ExtratoPageState createState() => _ExtratoPageState();

}

class _ExtratoPageState extends State<ExtratoPage> {
  late List<Asset> assets;

  // Função auxiliar para converter String em DateTime
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

// Função auxiliar para extrair valor numérico de uma string no formato " R$ 21,95 "
  double _extractNumericValue(String valueString) {
    try {
      // Remover espaços e caracteres não numéricos, então converter para double
      final cleanedValue = double.parse(valueString.replaceAll(RegExp(r'[^\d.]'), ''));
      return cleanedValue;
    } catch (e) {
      throw ArgumentError('Erro ao extrair valor numérico: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // Inicializar a lista de ativos
    assets = List.from(widget.assets);
    // Carregar dados salvos
    _loadData();
  }

  // Função para carregar dados salvos
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final assetList = prefs.getStringList('assets');

    if (assetList != null) {
      setState(() {
        assets = assetList.map((json) => Asset.fromJson(jsonDecode(json))).toList();
      });
    }
  }

  // Função para salvar dados
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final assetList = assets.map((asset) => jsonEncode(asset.toJson())).toList();
    prefs.setStringList('assets', assetList);
  }

  @override
  void dispose() {
    // Salvar dados ao sair da página
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
              // Selecionar arquivo e lidar com upload
              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['csv'],
              );
              if (result != null) {
                // Processar arquivo carregado
                final PlatformFile file = result.files.single;

                try {
                  // Ler arquivo CSV
                  final lines = await File(file.path!).readAsLines();

                  print('Lines $lines');

                  // Mapear transações por tradingCode
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

                    if (!transactionsByTradingCode.containsKey(tradingCode)) {
                      transactionsByTradingCode[tradingCode] = [];
                    }

                    transactionsByTradingCode[tradingCode]!.add(transaction);
                  });

                  // Criar ativos com as transações
                  final newAssets = transactionsByTradingCode.entries.map((entry) {
                    final tradingCode = entry.key;
                    final transactions = entry.value;

                    return Asset(
                      ticker: tradingCode,
                      quantity: transactions.fold(0, (sum, transaction) => sum + transaction.quantity),
                      averagePrice: transactions.fold(0.0, (sum, transaction) => sum + transaction.amount) /
                          transactions.fold(0, (sum, transaction) => sum + transaction.quantity),
                      transactions: transactions,
                      currentPrice: 0.0, // Defina conforme necessário
                    );
                  }).toList();

                  // Atualizar estado da aplicação
                  setState(() {
                    assets.addAll(newAssets);
                  });

                  // Salvar dados
                  _saveData();
                } catch (e) {
                  // Lidar com erros
                  print("Erro ao processar o arquivo CSV: $e");
                }
              } else {
                // Usuário cancelou o seletor de arquivos
              }
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: assets.length,
        itemBuilder: (context, index) {
          final asset = assets[index];
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
                    itemCount: asset.transactions.length > 1 ? 1 : asset.transactions.length,
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
                            const SizedBox(height: 8), // Aumentei o espaçamento aqui
                            if (asset.transactions.length > 1 && transactionIndex == 0)
                              GestureDetector(
                                onTap: () {
                                  // Implemente a navegação para a tela com todas as transações
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
                  )

                  // ListView.builder(
                  //   shrinkWrap: true,
                  //   physics: const NeverScrollableScrollPhysics(),
                  //   itemCount: asset.transactions.length,
                  //   itemBuilder: (context, transactionIndex) {
                  //     final transaction = asset.transactions[transactionIndex];
                  //     return Padding(
                  //       padding: const EdgeInsets.all(12),
                  //       child: Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           Text(
                  //             'Transação: ${transaction.quantity} unidades por ${(transaction.price * transaction.quantity).toStringAsFixed(2)}',
                  //             style: TextStyle(
                  //               fontSize: 14,
                  //               color: Colors.grey,
                  //             ),
                  //           ),
                  //           const SizedBox(height: 8), // Aumentei o espaçamento aqui
                  //           Text(
                  //             'Data: ${transaction.date.toString()}',
                  //             style: TextStyle(
                  //               fontSize: 14,
                  //               color: Colors.grey[600],
                  //             ),
                  //           ),
                  //           const SizedBox(height: 4), // Reduzi o espaçamento aqui
                  //           Text(
                  //             'Mercado: ${transaction.market}',
                  //             style: TextStyle(
                  //               fontSize: 14,
                  //               color: Colors.grey[600],
                  //             ),
                  //           ),
                  //           const SizedBox(height: 4), // Reduzi o espaçamento aqui
                  //           Text(
                  //             'Tipo: ${_getTypeString(transaction.type)}',
                  //             style: TextStyle(
                  //               fontSize: 14,
                  //               color: Colors.grey[600],
                  //             ),
                  //           ),
                  //           const SizedBox(height: 4), // Reduzi o espaçamento aqui
                  //           Text(
                  //             'Instituição: ${transaction.institution}',
                  //             style: TextStyle(
                  //               fontSize: 14,
                  //               color: Colors.grey[600],
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     );
                  //   },
                  // ),
                ],
              ),
            ),
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
      final cleanedString = typeString.trim().toLowerCase(); // Remover espaços e converter para minúsculas

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
