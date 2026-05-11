import 'dart:async';
import 'package:flutter/material.dart';
import '../models/market_data.dart';
import '../models/trading_signal.dart';
import '../models/trade_setup.dart';
import '../models/trade_result.dart';
import '../services/market_data_service.dart';
import '../services/signal_generator.dart';
import '../services/firebase_service.dart';

class TradingProvider extends ChangeNotifier {
  final MarketDataService _marketDataService = MarketDataService();
  final SignalGenerator _signalGenerator = SignalGenerator();
  final FirebaseService _firebaseService = FirebaseService();

  List<MarketData> _priceHistory = [];
  TradingSignal? _currentSignal;
  TradeSetup? _activeTrade;
  StreamSubscription? _subscription;
  List<TradeResult> _tradeLog = [];
  DateTime? _lastTradeTriggerTime;
  String? _activeTradeDocId;

  List<MarketData> get priceHistory => _priceHistory;
  TradingSignal? get currentSignal => _currentSignal;
  TradeSetup? get activeTrade => _activeTrade;
  List<TradeResult> get tradeLog => _tradeLog;
  
  // Win Rate Calculation Methods
  double getAllTimeWinRate() => _calculateWinRate(_tradeLog);
  
  double getDailyWinRate() {
    final dayAgo = DateTime.now().subtract(const Duration(hours: 24));
    return _calculateWinRate(_tradeLog.where((t) => t.closeTime.isAfter(dayAgo)).toList());
  }

  double getHourlyWinRate() {
    final hourAgo = DateTime.now().subtract(const Duration(minutes: 60));
    return _calculateWinRate(_tradeLog.where((t) => t.closeTime.isAfter(hourAgo)).toList());
  }

  double _calculateWinRate(List<TradeResult> trades) {
    if (trades.isEmpty) return 0.0;
    int wins = trades.where((t) => t.isWin).length;
    return (wins / trades.length) * 100;
  }

  TradingProvider() {
    _init();
  }

  void _init() async {
    // Load historical trades from Firebase
    try {
      _tradeLog = await _firebaseService.getAllTrades();
      notifyListeners();
    } catch (e) {
      print('Failed to load trade history from Firebase: $e');
    }

    // Get some historical data so the chart isn't empty initially
    _priceHistory = _marketDataService.getInitialHistory(100);
    _updateSignal();
    
    // Start listening to live mock data
    _marketDataService.startSimulating();
    _subscription = _marketDataService.marketDataStream.listen((data) {
      _priceHistory.add(data);
      // Keep only last 200 data points to prevent memory bloat
      if (_priceHistory.length > 200) {
        _priceHistory.removeAt(0);
      }
      _updateSignal();
      notifyListeners();
    });
  }

  void _updateSignal() {
    _currentSignal = _signalGenerator.analyze(_priceHistory);
    
    // Trade Setup Logic
    if (_currentSignal != null) {
      // 1. Strictly enforce > 80% accuracy (Strong Buy or Strong Sell ONLY)
      bool isStrongSignal = _currentSignal!.type == SignalType.strongBuy || 
                            _currentSignal!.type == SignalType.strongSell;
                            
      // 2. Enforce 1-hour cooldown between signals
      bool isCooldownOver = true;
      if (_lastTradeTriggerTime != null) {
        if (DateTime.now().difference(_lastTradeTriggerTime!).inMinutes < 60) {
          isCooldownOver = false;
        }
      }

      // If we don't have an active trade, the signal is >80%, and cooldown is over
      if (_activeTrade == null && isStrongSignal && isCooldownOver) {
        _lastTradeTriggerTime = DateTime.now();
        _activeTrade = TradeSetup(
          type: _currentSignal!.type,
          entryTime: _currentSignal!.timestamp,
          entryPrice: _currentSignal!.currentPrice,
          targetPrice: _currentSignal!.targetPrice,
          reasoning: _currentSignal!.reasoning,
        );
        // Save to Firebase
        _firebaseService.saveTradeSignal(_activeTrade!).then((docId) {
          _activeTradeDocId = docId;
        });
      } else if (_activeTrade != null) {
        // Invalidate trade if the trend strongly reverses
        bool trendReversed = (_activeTrade!.type == SignalType.strongBuy || _activeTrade!.type == SignalType.buy) && 
                             (_currentSignal!.type == SignalType.strongSell || _currentSignal!.type == SignalType.sell);
        bool trendReversedBearish = (_activeTrade!.type == SignalType.strongSell || _activeTrade!.type == SignalType.sell) && 
                                    (_currentSignal!.type == SignalType.strongBuy || _currentSignal!.type == SignalType.buy);
        
        // Also invalidate if target is hit (for simulation purposes)
        bool targetHit = false;
        if ((_activeTrade!.type == SignalType.strongBuy || _activeTrade!.type == SignalType.buy) && _currentSignal!.currentPrice >= _activeTrade!.targetPrice) targetHit = true;
        if ((_activeTrade!.type == SignalType.strongSell || _activeTrade!.type == SignalType.sell) && _currentSignal!.currentPrice <= _activeTrade!.targetPrice) targetHit = true;

        if (trendReversed || trendReversedBearish || targetHit) {
          // Log the result locally
          _tradeLog.add(TradeResult(
            setup: _activeTrade!,
            isWin: targetHit,
            closeTime: _currentSignal!.timestamp,
            closePrice: _currentSignal!.currentPrice,
          ));
          // Update in Firebase
          if (_activeTradeDocId != null) {
            _firebaseService.updateTradeResult(
              _activeTradeDocId!,
              targetHit,
              _currentSignal!.currentPrice,
            );
            _activeTradeDocId = null;
          }
          _activeTrade = null; // Clear the trade
        }
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _marketDataService.stopSimulating();
    super.dispose();
  }
}
