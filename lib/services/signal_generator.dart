import 'dart:math';
import '../models/market_data.dart';
import '../models/trading_signal.dart';

class SignalGenerator {
  static const int rsiPeriod = 14;
  static const int macdShortPeriod = 12;
  static const int macdLongPeriod = 26;
  static const int macdSignalPeriod = 9;
  static const int bbPeriod = 20;
  static const double bbStdDev = 2.0;
  static const int smaPeriod = 50;

  TradingSignal analyze(List<MarketData> data, {String symbol = 'CL=F'}) {
    if (data.isEmpty) {
      return _buildEmptySignal(0.0, DateTime.now(), symbol);
    }

    final currentPrice = data.last.price;
    final timestamp = data.last.timestamp;

    if (data.length < smaPeriod) {
      return _buildEmptySignal(currentPrice, timestamp, symbol);
    }

    List<double> prices = data.map((d) => d.price).toList();
    Map<String, double> strategyScores = {};

    // 1. RSI Score
    double rsi = _calculateRSI(prices, rsiPeriod);
    // Lower RSI is bullish (oversold), so invert for score
    strategyScores['RSI'] = (100 - rsi).clamp(0.0, 100.0);

    // 2. MACD Score
    Map<String, double> macdData = _calculateMACD(prices, macdShortPeriod, macdLongPeriod, macdSignalPeriod);
    double macdDiff = macdData['macd']! - macdData['signal']!;
    // Normalize diff to 0-100. Assume max expected diff is 1% of price.
    double maxExpectedDiff = currentPrice * 0.01;
    double macdScore = 50 + ((macdDiff / maxExpectedDiff) * 50);
    strategyScores['MACD'] = macdScore.clamp(0.0, 100.0);

    // 3. Bollinger Bands Score
    Map<String, double> bbData = _calculateBB(prices, bbPeriod, bbStdDev);
    double upper = bbData['upper']!;
    double lower = bbData['lower']!;
    double bbScore = 50.0;
    if (upper != lower) {
      // Lower price is bullish
      bbScore = ((upper - currentPrice) / (upper - lower)) * 100;
    }
    strategyScores['Bollinger Bands'] = bbScore.clamp(0.0, 100.0);

    // 4. SMA Score
    double sma = _calculateSMA(prices, smaPeriod);
    double smaDiff = currentPrice - sma;
    double smaMaxDiff = currentPrice * 0.02; // assume 2% diff is max spectrum
    double smaScore = 50 + ((smaDiff / smaMaxDiff) * 50);
    strategyScores['SMA ($smaPeriod)'] = smaScore.clamp(0.0, 100.0);

    // Calculate Combined Spectrum
    double totalWeight = 4.0;
    double spectrumScore = (
        (strategyScores['RSI']! * 1.0) +
        (strategyScores['MACD']! * 1.0) +
        (strategyScores['Bollinger Bands']! * 1.0) +
        (strategyScores['SMA ($smaPeriod)']! * 1.0)
    ) / totalWeight;

    // Determine signal type based on combined spectrum
    SignalType type;
    String reasoning;

    if (spectrumScore >= 80) {
      type = SignalType.strongBuy;
      reasoning = "All indicators align strongly Bullish.";
    } else if (spectrumScore >= 60) {
      type = SignalType.buy;
      reasoning = "Bullish momentum detected across multiple indicators.";
    } else if (spectrumScore <= 20) {
      type = SignalType.strongSell;
      reasoning = "All indicators align strongly Bearish.";
    } else if (spectrumScore <= 40) {
      type = SignalType.sell;
      reasoning = "Bearish momentum detected across multiple indicators.";
    } else {
      type = SignalType.hold;
      reasoning = "Mixed signals. Awaiting clearer trend.";
    }

    // Target Price Calculation
    double targetPrice = currentPrice;
    double volatility = upper - lower;
    
    if (spectrumScore > 50) {
      // Bullish Target: Proportional upward projection
      double strength = (spectrumScore - 50) / 50; // 0.0 to 1.0
      targetPrice = upper + (volatility * strength * 0.5); // Push target slightly above upper band on strong momentum
    } else if (spectrumScore < 50) {
      // Bearish Target: Proportional downward projection
      double strength = (50 - spectrumScore) / 50; // 0.0 to 1.0
      targetPrice = lower - (volatility * strength * 0.5); // Push target slightly below lower band on strong momentum
    } else {
      targetPrice = sma; // Mean reversion
    }

    return TradingSignal(
      symbol: symbol,
      type: type,
      reasoning: reasoning,
      timestamp: timestamp,
      currentPrice: currentPrice,
      spectrumScore: spectrumScore,
      strategyScores: strategyScores,
      targetPrice: targetPrice,
    );
  }

  TradingSignal _buildEmptySignal(double price, DateTime ts, String symbol) {
    return TradingSignal(
      symbol: symbol,
      type: SignalType.hold,
      reasoning: "Accumulating data for multi-strategy analysis...",
      timestamp: ts,
      currentPrice: price,
      spectrumScore: 50.0,
      strategyScores: {},
      targetPrice: price,
    );
  }

  double _calculateRSI(List<double> prices, int period) {
    if (prices.length < period + 1) return 50.0;
    double sumGain = 0;
    double sumLoss = 0;
    for (int i = prices.length - period; i < prices.length; i++) {
      double diff = prices[i] - prices[i - 1];
      if (diff >= 0) sumGain += diff;
      else sumLoss -= diff;
    }
    if (sumGain == 0) return 0;
    if (sumLoss == 0) return 100;
    double rs = (sumGain / period) / (sumLoss / period);
    return 100 - (100 / (1 + rs));
  }

  Map<String, double> _calculateMACD(List<double> prices, int shortP, int longP, int sigP) {
    List<double> shortEma = _calculateEMA(prices, shortP);
    List<double> longEma = _calculateEMA(prices, longP);
    List<double> macdLine = [];
    for (int i = 0; i < prices.length; i++) {
      if (i >= longP - 1) macdLine.add(shortEma[i] - longEma[i]);
      else macdLine.add(0);
    }
    List<double> signalLine = _calculateEMA(macdLine, sigP, skipLeadingZeroes: true);
    return {
      'macd': macdLine.last,
      'signal': signalLine.last,
    };
  }

  Map<String, double> _calculateBB(List<double> prices, int period, double stdDevMultiplier) {
    double sma = _calculateSMA(prices, period);
    double variance = 0.0;
    for (int i = prices.length - period; i < prices.length; i++) {
      variance += pow(prices[i] - sma, 2);
    }
    variance /= period;
    double stdDev = sqrt(variance);
    return {
      'upper': sma + (stdDevMultiplier * stdDev),
      'lower': sma - (stdDevMultiplier * stdDev),
    };
  }

  double _calculateSMA(List<double> prices, int period) {
    double sum = 0;
    for (int i = prices.length - period; i < prices.length; i++) {
      sum += prices[i];
    }
    return sum / period;
  }

  List<double> _calculateEMA(List<double> values, int period, {bool skipLeadingZeroes = false}) {
    List<double> ema = List.filled(values.length, 0.0);
    double multiplier = 2 / (period + 1);
    int startIndex = 0;
    if (skipLeadingZeroes) {
      while (startIndex < values.length && values[startIndex] == 0.0) startIndex++;
    }
    if (values.length - startIndex < period) return ema;
    double sum = 0;
    for (int i = startIndex; i < startIndex + period; i++) sum += values[i];
    ema[startIndex + period - 1] = sum / period;
    for (int i = startIndex + period; i < values.length; i++) {
      ema[i] = ((values[i] - ema[i - 1]) * multiplier) + ema[i - 1];
    }
    return ema;
  }
}
