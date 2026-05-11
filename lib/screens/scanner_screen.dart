import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/scanner_provider.dart';
import '../models/trading_signal.dart';
import '../models/trade_setup.dart';
import 'package:intl/intl.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('US Stocks Breakout Scanner', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Consumer<ScannerProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              _buildActiveAlertsSection(provider.activeAlerts),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Live Watchlist Monitoring',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                child: _buildWatchlistGrid(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActiveAlertsSection(List<TradeSetup> alerts) {
    if (alerts.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.radar, size: 48, color: Colors.grey),
              SizedBox(height: 12),
              Text(
                'Scanning for Breakouts...',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          final alert = alerts[index];
          final isBuy = alert.type == SignalType.strongBuy || alert.type == SignalType.buy;
          final color = isBuy ? Colors.greenAccent : Colors.redAccent;
          final icon = isBuy ? Icons.rocket_launch : Icons.trending_down;

          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.2), const Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.5), width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      alert.symbol,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Icon(icon, color: color),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isBuy ? 'BREAKOUT ALERT' : 'BREAKDOWN ALERT',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Entry', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text('\$${alert.entryPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Target', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text('\$${alert.targetPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('HH:mm:ss').format(alert.entryTime),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWatchlistGrid(ScannerProvider provider) {
    if (provider.currentPrices.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: provider.watchlist.length,
      itemBuilder: (context, index) {
        final symbol = provider.watchlist[index];
        final price = provider.currentPrices[symbol];
        final change = provider.priceChanges[symbol];

        if (price == null || change == null) {
          return Card(
            color: const Color(0xFF1E293B),
            child: Center(
              child: Text(symbol, style: const TextStyle(color: Colors.grey)),
            ),
          );
        }

        final isPositive = change >= 0;
        final color = isPositive ? Colors.greenAccent : Colors.redAccent;

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                symbol,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${price.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                '${isPositive ? '+' : ''}${change.toStringAsFixed(2)}%',
                style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }
}
