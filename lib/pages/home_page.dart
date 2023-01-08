import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  Future<String> getData() async {
    var url = Uri.https('https://api.b3.com.br/b3api/api/v1/ativos', '');
    var response = await http.get(url);

    return response.body;
  }

  void mainTest() async {
    var data = await getData();
    print(data);
  }

  @override
  Widget build(BuildContext context) {
    mainTest();

    return Container();
  }
}
