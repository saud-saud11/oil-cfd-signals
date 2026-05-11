import 'package:flutter/material.dart';
import '../models/trading_signal.dart';
import 'package:intl/intl.dart';

class SignalCard extends StatelessWidget {
  final TradingSignal? signal;

  const SignalCard({Key? key, this.signal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (signal == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    Color signalColor;
    String signalText;
    IconData signalIcon;

    switch (signal!.type) {
      case SignalType.strongBuy:
        signalColor = Colors.greenAccent.shade700;
        signalText = "STRONG BUY";
        signalIcon = Icons.keyboard_double_arrow_up;
        break;
      case SignalType.buy:
        signalColor = Colors.green;
        signalText = "BUY";
        signalIcon = Icons.arrow_upward;
        break;
      case SignalType.hold:
        signalColor = Colors.orange;
        signalText = "HOLD";
        signalIcon = Icons.remove;
        break;
      case SignalType.sell:
        signalColor = Colors.red;
        signalText = "SELL";
        signalIcon = Icons.arrow_downward;
        break;
      case SignalType.strongSell:
        signalColor = Colors.redAccent.shade700;
        signalText = "STRONG SELL";
        signalIcon = Icons.keyboard_double_arrow_down;
        break;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              signalColor.withAlpha(51),
              Theme.of(context).cardColor,
            ],
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Multi-Strategy Signal",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey.shade400,
                      ),
                ),
                Text(
                  DateFormat.Hms().format(signal!.timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade500,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(signalIcon, color: signalColor, size: 48),
                const SizedBox(width: 16),
                Text(
                  signalText,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: signalColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Target Price Display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor.withAlpha(150),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: signalColor.withAlpha(100), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.track_changes, color: signalColor, size: 24),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "1-Hour Target Price",
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                      ),
                      Text(
                        NumberFormat.currency(symbol: '\$').format(signal!.targetPrice),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Percentage Spectrum UI
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Strong Sell', style: TextStyle(color: Colors.red, fontSize: 12)),
                    Text(
                      'Combined Score: ${signal!.spectrumScore.toStringAsFixed(1)}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text('Strong Buy', style: TextStyle(color: Colors.green, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: signal!.spectrumScore / 100,
                    minHeight: 12,
                    backgroundColor: Colors.red.withAlpha(50),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color.lerp(Colors.red, Colors.green, signal!.spectrumScore / 100) ?? Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Individual Strategy Breakdown
            if (signal!.strategyScores.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 8),
              Text(
                "Strategy Breakdown",
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.grey.shade400,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: signal!.strategyScores.entries.map((entry) {
                  return Chip(
                    label: Text(
                      '${entry.key}: ${entry.value.toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Color.lerp(Colors.red.withAlpha(100), Colors.green.withAlpha(100), entry.value / 100),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 16),

            Text(
              signal!.reasoning,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "Generated at ${NumberFormat.currency(symbol: '\$').format(signal!.currentPrice)}",
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
