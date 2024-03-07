import 'package:flutter/material.dart';
import 'package:flutter_investment_control/models/active_model.dart';
import 'package:flutter_investment_control/services/api_stocks_historicals.dart';
import 'package:intl/intl.dart';

class ActiveDetailsPage extends StatefulWidget {
  final Active active;

  ActiveDetailsPage({Key? key, required this.active}) : super(key: key);

  @override
  _ActiveDetailsPageState createState() => _ActiveDetailsPageState();
}

class _ActiveDetailsPageState extends State<ActiveDetailsPage> {
  NumberFormat real = NumberFormat.currency(locale: 'pt-br', name: 'R\$');

  Future<List<double>> _calculateReturns() async {
    try {
      // Get historical prices from the API response
      final response = await StocksHistoricals().getStockHistoricals(widget.active.symbol);

      if (response != null) {
        List<dynamic> historicals = response['historicals'] as List<dynamic>;

        // Filtrar os preços para o mês atual
        DateTime now = DateTime.now();
        DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
        DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

        List<double> prices = historicals
            .where((historical) {
          DateTime date = DateTime.parse(historical['date']);
          return date.isAfter(firstDayOfMonth.subtract(Duration(days: 1))) &&
              date.isBefore(lastDayOfMonth.add(Duration(days: 1)));
        })
            .map<double>((historical) => double.parse(historical['close'].toString()))
            .toList();

        // Verificar se há preços disponíveis para o mês atual
        double returnCurrentMonth = 0.0;
        if (prices.isNotEmpty) {
          // Obter o primeiro e o último preço de fechamento disponíveis
          double firstDayClosingPrice = prices.first;
          double lastDayClosingPrice = prices.last;

          // Calcular a rentabilidade para o mês atual
          returnCurrentMonth = ((lastDayClosingPrice - firstDayClosingPrice) / firstDayClosingPrice) * 100;
        }

        // Calcular a rentabilidade para os últimos 12 meses
        double returnLast12Months = ((widget.active.lastPrice - widget.active.lastYearLow) / widget.active.lastYearLow) * 100;

        return [returnCurrentMonth, returnLast12Months];
      } else {
        throw Exception('Failed to load historical prices');
      }
    } catch (e) {
      print('Error calculating returns: $e');
      throw Exception('Error calculating returns');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.white,
        ),
        title: Text(
          widget.active.symbol,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List<double>>(
              future: _calculateReturns(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error calculating returns: ${snapshot.error}');
                } else {
                  double returnCurrentMonth = snapshot.data![0];
                  double returnLast12Months = snapshot.data![1];
                  return _buildHeader(returnLast12Months, returnCurrentMonth);
                }
              },
            ),
            const SizedBox(height: 20),
            _buildInfoSection(
              title: 'Informações Gerais',
              children: [
                _buildGeneralInfoCard(
                  title: 'Preço Atual',
                  value: real.format(widget.active.lastPrice),
                ),
                _buildGeneralInfoCard(
                  title: 'Dividend Yield',
                  value: '${widget.active.dividendYield.toStringAsFixed(2)}%',
                ),
                _buildGeneralInfoCard(
                  title: 'Setor',
                  value: widget.active.sector,
                ),
                _buildGeneralInfoCard(
                  title: 'Segmento',
                  value: widget.active.segment,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoSection(
              title: 'Desempenho Anual',
              children: [
                _buildPerformanceInfoCard(
                  title: 'Último Ano Baixo',
                  value: real.format(widget.active.lastYearLow),
                ),
                _buildPerformanceInfoCard(
                  title: 'Último Ano Alto',
                  value: real.format(widget.active.lastYearHigh),
                ),
              ],
            ),
            // Add more sections as needed
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double returnLast12Months, double returnCurrentMonth) {
    return Row(
      children: <Widget>[
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: AssetImage(widget.active.icon),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.active.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Rentabilidade (12M): ${returnLast12Months.toStringAsFixed(2)}%',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              Text(
                'Mês Atual: ${returnCurrentMonth.toStringAsFixed(2)}%',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: children.map((widget) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: widget,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralInfoCard({required String title, required String value}) {
    return Card(
      elevation: 2,
      color:  Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color:  Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceInfoCard({required String title, required String value}) {
    return Card(
      elevation: 2,
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
