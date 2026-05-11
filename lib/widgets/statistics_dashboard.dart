import 'package:flutter/material.dart';

class StatisticsDashboard extends StatelessWidget {
  final double allTimeWinRate;
  final double dailyWinRate;
  final double hourlyWinRate;
  final int totalTrades;
  final VoidCallback? onTap;

  const StatisticsDashboard({
    Key? key,
    required this.allTimeWinRate,
    required this.dailyWinRate,
    required this.hourlyWinRate,
    required this.totalTrades,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).cardColor,
          border: Border.all(color: Colors.blueAccent.withAlpha(50), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Trading Statistics",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withAlpha(50),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Total Trades: $totalTrades",
                    style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCircle(context, "Hourly", hourlyWinRate),
                _buildStatCircle(context, "Daily", dailyWinRate),
                _buildStatCircle(context, "All-Time", allTimeWinRate),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildStatCircle(BuildContext context, String label, double winRate) {
    Color color = winRate >= 60 ? Colors.green : (winRate >= 40 ? Colors.orange : Colors.red);
    if (totalTrades == 0) color = Colors.grey;

    return Column(
      children: [
        SizedBox(
          height: 80,
          width: 80,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: totalTrades == 0 ? 0 : winRate / 100,
                strokeWidth: 8,
                backgroundColor: color.withAlpha(30),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              Center(
                child: Text(
                  totalTrades == 0 ? "N/A" : "${winRate.toStringAsFixed(0)}%",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: totalTrades == 0 ? Colors.grey : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
