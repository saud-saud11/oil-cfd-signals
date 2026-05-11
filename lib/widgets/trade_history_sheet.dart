import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/trade_result.dart';
import '../models/trading_signal.dart';

class TradeHistorySheet extends StatelessWidget {
  final List<TradeResult> tradeLog;

  const TradeHistorySheet({Key? key, required this.tradeLog}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Closed Signals History",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: tradeLog.isEmpty
                ? Center(
                    child: Text(
                      "No closed trades yet.",
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: tradeLog.length,
                    itemBuilder: (context, index) {
                      // Reverse order to show newest first
                      final trade = tradeLog[tradeLog.length - 1 - index];
                      return _buildTradeCard(context, trade);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradeCard(BuildContext context, TradeResult trade) {
    Color resultColor = trade.isWin ? Colors.green : Colors.red;
    String resultText = trade.isWin ? "WIN" : "LOSS";

    String directionText = (trade.setup.type == SignalType.strongBuy || trade.setup.type == SignalType.buy) ? "BUY" : "SELL";
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: resultColor.withAlpha(50), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: resultColor.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    resultText,
                    style: TextStyle(color: resultColor, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    trade.setup.symbol,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    directionText,
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Entry: ${NumberFormat.currency(symbol: '\$').format(trade.setup.entryPrice)}",
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        DateFormat.Hm().format(trade.closeTime),
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Target: ${NumberFormat.currency(symbol: '\$').format(trade.setup.targetPrice)}",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade300),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Close: ${NumberFormat.currency(symbol: '\$').format(trade.closePrice)}",
                    style: TextStyle(fontSize: 14, color: resultColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
