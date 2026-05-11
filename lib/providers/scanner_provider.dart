import 'dart:async';
import 'package:flutter/material.dart';
import '../models/market_data.dart';
import '../models/trading_signal.dart';
import '../models/trade_setup.dart';
import '../services/market_data_service.dart';
import '../services/signal_generator.dart';
import '../services/firebase_service.dart';

class ScannerProvider extends ChangeNotifier {
  final SignalGenerator _signalGenerator = SignalGenerator();
  final FirebaseService _firebaseService = FirebaseService();

  // Curated list of high-beta / explosive US stocks
  final List<String> _watchlist = [
    'NVDA', 'TSLA', 'MSTR', 'COIN', 'PLTR', 
    'AMD', 'AAPL', 'META', 'NFLX', 'SMCI',
    'ARM', 'SOUN', 'MARA', 'RIOT', 'HOOD'
  ];

  Map<String, double> _currentPrices = {};
  Map<String, double> _priceChanges = {};
  List<TradeSetup> _activeAlerts = [];
  bool _isScanning = false;
  Timer? _scannerTimer;

  List<String> get watchlist => _watchlist;
  Map<String, double> get currentPrices => _currentPrices;
  Map<String, double> get priceChanges => _priceChanges;
  List<TradeSetup> get activeAlerts => _activeAlerts;
  bool get isScanning => _isScanning;

  ScannerProvider() {
    startScanner();
  }

  void startScanner() {
    if (_isScanning) return;
    _isScanning = true;
    notifyListeners();

    // Initial scan
    _scanAll();

    // Scan every 30 seconds
    _scannerTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _scanAll();
    });
  }

  void stopScanner() {
    _scannerTimer?.cancel();
    _isScanning = false;
    notifyListeners();
  }

  Future<void> _scanAll() async {
    for (String symbol in _watchlist) {
      try {
        final history = await MarketDataService.fetchHistoryFor(symbol);
        if (history.isEmpty) continue;

        // Update current price and change
        final currentPrice = history.last.price;
        final openPrice = history.first.price;
        final change = ((currentPrice - openPrice) / openPrice) * 100;

        _currentPrices[symbol] = currentPrice;
        _priceChanges[symbol] = change;

        // Generate signal
        final signal = _signalGenerator.analyze(history, symbol: symbol);
        
        if (signal != null) {
          bool isStrongSignal = signal.type == SignalType.strongBuy || 
                                signal.type == SignalType.strongSell;

          if (isStrongSignal) {
            // Check if we already have an active alert for this symbol
            bool alreadyAlerted = _activeAlerts.any((a) => a.symbol == symbol);
            
            if (!alreadyAlerted) {
              final setup = TradeSetup(
                symbol: symbol,
                type: signal.type,
                entryTime: signal.timestamp,
                entryPrice: signal.currentPrice,
                targetPrice: signal.targetPrice,
                reasoning: signal.reasoning,
              );
              
              _activeAlerts.insert(0, setup); // Add to top
              
              // Save to Firebase
              _firebaseService.saveTradeSignal(setup);
            }
          }
        }
      } catch (e) {
        print("Error scanning $symbol: $e");
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    stopScanner();
    super.dispose();
  }
}
