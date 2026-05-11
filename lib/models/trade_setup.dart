import 'trading_signal.dart';

class TradeSetup {
  final SignalType type;
  final DateTime entryTime;
  final double entryPrice;
  final double targetPrice;
  final String reasoning;

  TradeSetup({
    required this.type,
    required this.entryTime,
    required this.entryPrice,
    required this.targetPrice,
    required this.reasoning,
  });
}
