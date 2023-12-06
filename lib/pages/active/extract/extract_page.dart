import 'package:flutter/material.dart';
import 'package:flutter_investment_control/models/asset_model.dart';
import 'package:flutter_investment_control/models/transaction_model.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class ExtratoPage extends StatefulWidget {
  final List<Asset> assets;

  ExtratoPage({required this.assets});

  @override
  _ExtratoPageState createState() => _ExtratoPageState();
}

class _ExtratoPageState extends State<ExtratoPage> {
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
                final File file = result.files.single as File;

                try {
                  // Ler arquivo CSV
                  final lines = await file.readAsLines();

                  // Extrair dados relevantes
                  final transactions = lines.skip(1).map((line) {
                    final columns = line.split(',');

                    // Ajuste conforme as colunas fornecidas
                    final date = DateTime.parse(columns[0]);
                    final ticker = columns[5];
                    final type = _getTypeFromString(columns[1]);
                    final market = columns[2];
                    final maturityDate = DateTime.parse(columns[3]);
                    final institution = columns[4];
                    final tradingCode = columns[5];
                    final quantity = int.parse(columns[6]);
                    final price = double.parse(columns[7]);
                    final amount = double.parse(columns[8]);

                    // Criar objeto de transação
                    return Transaction(
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
                  }).toList();

                  // Criar um novo ativo com as transações
                  final newAsset = Asset(
                    ticker: 'Novo Ativo', // Substitua com o ticker apropriado
                    quantity: transactions.fold(0, (sum, transaction) => sum + transaction.quantity),
                    averagePrice: transactions.fold(0.0, (sum, transaction) => sum + transaction.amount) /
                        transactions.fold(0, (sum, transaction) => sum + transaction.quantity),
                    transactions: transactions,
                    currentPrice: 0.0, // Defina conforme necessário
                  );

                  // Atualizar estado da aplicação
                  setState(() {
                    widget.assets.add(newAsset);
                  });
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
        itemCount: widget.assets.length,
        itemBuilder: (context, index) {
          final asset = widget.assets[index];
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
                    title: Text(
                      '${asset.ticker} - ${asset.quantity} Cotas',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      'Custo Médio: ${asset.averagePrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  // Adicione aqui a lista de transações do ativo
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: asset.transactions.length,
                    itemBuilder: (context, transactionIndex) {
                      final transaction = asset.transactions[transactionIndex];
                      return ListTile(
                        title: Text(
                          'Transação: ${transaction.quantity} unidades por ${transaction.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        subtitle: Text(
                          'Data: ${transaction.date.toString()}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Função auxiliar para converter String em TransactionType
  TransactionType _getTypeFromString(String typeString) {
    if (typeString.toLowerCase() == 'buy') {
      return TransactionType.buy;
    } else if (typeString.toLowerCase() == 'sell') {
      return TransactionType.sell;
    } else {
      throw ArgumentError('Tipo de transação desconhecido: $typeString');
    }
  }
}
