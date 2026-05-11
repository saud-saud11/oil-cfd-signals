import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/trade_setup.dart';
import '../models/trading_signal.dart';

class TradeAlertCard extends StatelessWidget {
  final TradeSetup? activeTrade;

  const TradeAlertCard({Key? key, this.activeTrade}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (activeTrade == null) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          width: double.infinity,
          child: Column(
            children: [
              Icon(Icons.search, size: 48, color: Colors.grey.shade600),
              const SizedBox(height: 16),
              Text(
                "Searching for Trade Setup...",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade400,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                "Waiting for strong directional momentum.",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    Color signalColor;
    String signalText;

    switch (activeTrade!.type) {
      case SignalType.strongBuy:
      case SignalType.buy:
        signalColor = Colors.greenAccent.shade700;
        signalText = "BUY ALERT";
        break;
      case SignalType.strongSell:
      case SignalType.sell:
        signalColor = Colors.redAccent.shade700;
        signalText = "SELL ALERT";
        break;
      default:
        signalColor = Colors.orange;
        signalText = "HOLD";
    }

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: signalColor, width: 2),
      ),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              signalColor.withAlpha(50),
              Theme.of(context).cardColor,
            ],
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: signalColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "LOCKED SETUP",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12),
                  ),
                ),
                Text(
                  "Entry Time: ${DateFormat.Hms().format(activeTrade!.entryTime)}",
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              signalText,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: signalColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoColumn("Entry Price", activeTrade!.entryPrice, Colors.white),
                Icon(Icons.arrow_forward, color: Colors.grey.shade600),
                _buildInfoColumn("Target Price", activeTrade!.targetPrice, signalColor),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              activeTrade!.reasoning,
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey.shade400, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, double price, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          NumberFormat.currency(symbol: '\$').format(price),
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
