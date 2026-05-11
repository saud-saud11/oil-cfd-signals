import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final targetUrl = 'https://query1.finance.yahoo.com/v8/finance/chart/CL=F?interval=1m&range=1d';
  final url = Uri.parse('https://api.allorigins.win/get?url=${Uri.encodeComponent(targetUrl)}');
  
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final content = json.decode(data['contents']);
      final result = content['chart']['result'][0];
      final meta = result['meta'];
      print('Current Price: \${meta["regularMarketPrice"]}');
    } else {
      print('Failed: \${response.statusCode}');
    }
  } catch (e) {
    print('Error: \$e');
  }
}
