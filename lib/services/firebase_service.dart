import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trade_setup.dart';
import '../models/trade_result.dart';
import '../models/trading_signal.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save a new trade signal when it's triggered
  Future<String> saveTradeSignal(TradeSetup setup) async {
    final doc = await _db.collection('trades').add({
      'type': setup.type == SignalType.strongBuy || setup.type == SignalType.buy ? 'BUY' : 'SELL',
      'entryPrice': setup.entryPrice,
      'targetPrice': setup.targetPrice,
      'entryTime': Timestamp.fromDate(setup.entryTime),
      'reasoning': setup.reasoning,
      'status': 'OPEN',
      'closePrice': null,
      'closeTime': null,
    });
    return doc.id;
  }

  // Update a trade when it's resolved (WIN or LOSS)
  Future<void> updateTradeResult(String docId, bool isWin, double closePrice) async {
    await _db.collection('trades').doc(docId).update({
      'status': isWin ? 'WIN' : 'LOSS',
      'closePrice': closePrice,
      'closeTime': Timestamp.fromDate(DateTime.now()),
    });
  }

  // Load all historical trades from Firestore
  Future<List<TradeResult>> getAllTrades() async {
    final snapshot = await _db.collection('trades')
        .where('status', isNotEqualTo: 'OPEN')
        .orderBy('closeTime', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return TradeResult(
        setup: TradeSetup(
          type: data['type'] == 'BUY' ? SignalType.strongBuy : SignalType.strongSell,
          entryTime: (data['entryTime'] as Timestamp).toDate(),
          entryPrice: (data['entryPrice'] as num).toDouble(),
          targetPrice: (data['targetPrice'] as num).toDouble(),
          reasoning: data['reasoning'] ?? '',
        ),
        isWin: data['status'] == 'WIN',
        closeTime: (data['closeTime'] as Timestamp).toDate(),
        closePrice: (data['closePrice'] as num).toDouble(),
      );
    }).toList();
  }

  // Get overall success rate
  Future<Map<String, dynamic>> getStats() async {
    final snapshot = await _db.collection('trades')
        .where('status', isNotEqualTo: 'OPEN')
        .get();

    int total = snapshot.docs.length;
    int wins = snapshot.docs.where((d) => d.data()['status'] == 'WIN').length;
    double winRate = total > 0 ? (wins / total) * 100 : 0;

    return {
      'total': total,
      'wins': wins,
      'losses': total - wins,
      'winRate': winRate,
    };
  }
}
