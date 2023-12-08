import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  Future<Map<String, dynamic>?> getAssetDetails(String ticker) async {
    final apiUrl = 'https://brapi.dev/api/quote/$ticker?token=m2VDSqSjN5diYAp5VjZSNv';

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
}
