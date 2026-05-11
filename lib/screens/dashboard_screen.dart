import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/trading_provider.dart';
import '../widgets/price_chart.dart';
import '../widgets/signal_card.dart';
import '../widgets/trade_alert_card.dart';
import '../widgets/statistics_dashboard.dart';
import '../widgets/trade_history_sheet.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'WTI Crude Oil Signals',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<TradingProvider>(
        builder: (context, provider, child) {
          if (provider.priceHistory.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final currentPrice = provider.priceHistory.last.price;
          final previousPrice = provider.priceHistory.length > 1
              ? provider.priceHistory[provider.priceHistory.length - 2].price
              : currentPrice;
              
          final priceChange = currentPrice - previousPrice;
          final isPositive = priceChange >= 0;

          return RefreshIndicator(
            onRefresh: () async {
              // Usually fetches new data, but we are streaming
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header section
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Text(
                            'Current Price (CFD)',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                NumberFormat.currency(symbol: '\$').format(currentPrice),
                                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                                color: isPositive ? Colors.green : Colors.red,
                                size: 20,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Fixed Trade Alert
                  Text(
                    'Active Trade Setup',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  TradeAlertCard(activeTrade: provider.activeTrade),
                  const SizedBox(height: 32),

                  // Live Analysis
                  Text(
                    'Live Market Analysis',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  SignalCard(signal: provider.currentSignal),
                  const SizedBox(height: 24),

                  // Chart Section
                  Text(
                    'Price History (Live)',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: PriceChart(data: provider.priceHistory),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Statistics Section
                  StatisticsDashboard(
                    allTimeWinRate: provider.getAllTimeWinRate(),
                    dailyWinRate: provider.getDailyWinRate(),
                    hourlyWinRate: provider.getHourlyWinRate(),
                    totalTrades: provider.tradeLog.length,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (context) => FractionallySizedBox(
                          heightFactor: 0.8,
                          child: TradeHistorySheet(tradeLog: provider.tradeLog),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
