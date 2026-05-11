import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/market_data.dart';

class MarketDataService {
  final _dataController = StreamController<MarketData>.broadcast();
  Timer? _timer;
  final String symbol;

  MarketDataService({this.symbol = 'CL=F'});
  
  double _lastPrice = 75.0; // Fallback starting price
  bool _historyLoaded = false;

  Stream<MarketData> get marketDataStream => _dataController.stream;

  void startSimulating() {
    // Initial fetch for history
    _fetchData();
    // Poll every 5 seconds for live updates
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchData();
    });
  }

  void stopSimulating() {
    _timer?.cancel();
  }

  Future<void> _fetchData() async {
    final targetUrl = 'https://query1.finance.yahoo.com/v8/finance/chart/$symbol?interval=1m&range=1d';
    final url = Uri.parse('https://corsproxy.io/?${Uri.encodeComponent(targetUrl)}&timestamp=${DateTime.now().millisecondsSinceEpoch}');
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final content = json.decode(response.body);
        final result = content['chart']['result'][0];
        
        if (!_historyLoaded) {
          // Push historical data first
          final timestamps = result['timestamp'] as List;
          final closePrices = result['indicators']['quote'][0]['close'] as List;
          
          for (int i = 0; i < timestamps.length; i++) {
            if (closePrices[i] != null) {
               _dataController.add(MarketData(
                 timestamp: DateTime.fromMillisecondsSinceEpoch(timestamps[i] * 1000),
                 price: (closePrices[i] as num).toDouble(),
               ));
            }
          }
          _historyLoaded = true;
        }

        // Always push the absolute latest live market price
        final meta = result['meta'];
        double currentPrice = (meta['regularMarketPrice'] as num).toDouble();
        
        // Add tiny random jitter to simulate high-frequency ticks between 1m polling
        if (_historyLoaded) {
           _lastPrice = currentPrice;
           _dataController.add(MarketData(
             timestamp: DateTime.now(),
             price: currentPrice,
           ));
        }

      }
    } catch (e) {
      print("Failed to fetch live data: $e");
      // Add fake tick if failed to keep app alive
      _dataController.add(MarketData(
        timestamp: DateTime.now(),
        price: _lastPrice,
      ));
    }
  }

  // Get initial historical data (return dummy flatline to prevent UI crash, 
  // real history will pour in immediately via the stream)
  List<MarketData> getInitialHistory(int count) {
    List<MarketData> history = [];
    for (int i = count; i > 0; i--) {
       history.add(MarketData(
         timestamp: DateTime.now().subtract(Duration(seconds: i)),
         price: _lastPrice,
       ));
    }
    return history;
  }

  // Generic static method for the Scanner to fetch data for any symbol
  static Future<List<MarketData>> fetchHistoryFor(String symbol) async {
    final targetUrl = 'https://query1.finance.yahoo.com/v8/finance/chart/$symbol?interval=1m&range=1d';
    final url = Uri.parse('https://corsproxy.io/?${Uri.encodeComponent(targetUrl)}&timestamp=${DateTime.now().millisecondsSinceEpoch}');
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final content = json.decode(response.body);
        final result = content['chart']['result'][0];
        
        final timestamps = result['timestamp'] as List?;
        final closePrices = result['indicators']['quote'][0]['close'] as List?;
        
        if (timestamps == null || closePrices == null) return [];

        List<MarketData> history = [];
        for (int i = 0; i < timestamps.length; i++) {
          if (closePrices[i] != null) {
             history.add(MarketData(
               timestamp: DateTime.fromMillisecondsSinceEpoch(timestamps[i] * 1000),
               price: (closePrices[i] as num).toDouble(),
             ));
          }
        }
        return history;
      }
    } catch (e) {
      print("Failed to fetch data for $symbol: $e");
    }
    return [];
  }
}
