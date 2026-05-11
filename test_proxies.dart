import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final targetUrl = 'https://query1.finance.yahoo.com/v8/finance/chart/CL=F?interval=1m&range=1d';
  
  final proxies = [
    'https://corsproxy.io/?\${Uri.encodeComponent(targetUrl)}',
    'https://api.codetabs.com/v1/proxy?quest=\${Uri.encodeComponent(targetUrl)}',
    'https://thingproxy.freeboard.io/fetch/\$targetUrl',
  ];
  
  for (var p in proxies) {
    try {
      final response = await http.get(Uri.parse(p)).timeout(Duration(seconds: 5));
      if (response.statusCode == 200) {
        print('SUCCESS: \$p');
        return;
      }
    } catch (e) {
      print('FAILED: \$p');
    }
  }
}
