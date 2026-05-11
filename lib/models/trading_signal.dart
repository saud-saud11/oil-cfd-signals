enum SignalType {
  strongBuy,
  buy,
  hold,
  sell,
  strongSell,
}

class TradingSignal {
  final SignalType type;
  final String reasoning;
  final DateTime timestamp;
  final double currentPrice;
  final double spectrumScore;
  final Map<String, double> strategyScores;
  final double targetPrice;

  TradingSignal({
    required this.type,
    required this.reasoning,
    required this.timestamp,
    required this.currentPrice,
    required this.spectrumScore,
    required this.strategyScores,
    required this.targetPrice,
  });
}
