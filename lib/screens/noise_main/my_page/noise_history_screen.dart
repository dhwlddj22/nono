// noise_history_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class NoiseHistoryScreen extends StatefulWidget {
  const NoiseHistoryScreen({Key? key}) : super(key: key);

  @override
  _NoiseHistoryScreenState createState() => _NoiseHistoryScreenState();
}

class _NoiseHistoryScreenState extends State<NoiseHistoryScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _user      = FirebaseAuth.instance.currentUser!;
  final int _limit  = 10;

  final List<DocumentSnapshot> _docs = [];
  bool _isLoading   = false;
  bool _hasMore     = true;
  DocumentSnapshot? _lastDoc;
  late ScrollController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = ScrollController()..addListener(_onScroll);
    _fetchRecords();
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onScroll);
    _ctrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_isLoading &&
        _hasMore &&
        _ctrl.position.pixels >= _ctrl.position.maxScrollExtent - 200) {
      _fetchRecords();
    }
  }

  Future<void> _fetchRecords() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    Query q = _firestore
        .collection('decibel_analysis')
        .where('userId', isEqualTo: _user.uid)
        .orderBy('timestamp', descending: true)
        .limit(_limit);

    if (_lastDoc != null) {
      q = q.startAfterDocument(_lastDoc!);
    }

    final snap = await q.get();
    final docs = snap.docs;
    if (docs.length < _limit) _hasMore = false;
    if (docs.isNotEmpty) {
      _lastDoc = docs.last;
      _docs.addAll(docs);
    }

    setState(() => _isLoading = false);
  }

  LineChartData _buildChartData(List<dynamic> values) {
    final spots = <FlSpot>[];
    for (var i = 0; i < values.length; i++) {
      final y = (values[i] as num).toDouble();
      spots.add(FlSpot(i.toDouble(), y));
    }
    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
            show: true,
            color: Colors.green.withOpacity(0.3),
        ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('소음측정 기록'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: _docs.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        controller: _ctrl,
        itemCount: _docs.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, idx) {
          if (idx >= _docs.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final data   = _docs[idx].data()! as Map<String, dynamic>;
          final avg    = data['average_db'];
          final peak   = data['peak_db'];
          final values = data['decibel_values'] as List<dynamic>;
          final ts     = (data['timestamp'] as Timestamp).toDate();
          final timeStr = DateFormat('yyyy-MM-dd HH:mm').format(ts);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[900],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timeStr,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '평균: $avg dB   최고: $peak dB',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: LineChart(_buildChartData(values)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
