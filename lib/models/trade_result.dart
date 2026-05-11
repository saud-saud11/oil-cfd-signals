import 'trade_setup.dart';

class TradeResult {
  final TradeSetup setup;
  final bool isWin;
  final DateTime closeTime;
  final double closePrice;

  TradeResult({
    required this.setup,
    required this.isWin,
    required this.closeTime,
    required this.closePrice,
  });
}
