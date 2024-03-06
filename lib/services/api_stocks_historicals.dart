import 'dart:convert';

import 'package:http/http.dart' as http;

class StocksHistoricals {
  Future<Map<String, dynamic>?> getStockHistoricals(String ticker) async {
    final String apiUrl =
        "https://mfinance.com.br/api/v1/stocks/historicals/$ticker?months=1";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        var historicals = jsonData['historicals'];
        return historicals;
      } else {
        throw Exception('Failed to load stock indicators');
      }
    } catch (err) {}
  }
}
