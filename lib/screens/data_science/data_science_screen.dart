import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class DataScienceScreen extends StatefulWidget {
  const DataScienceScreen({super.key});

  @override
  State<DataScienceScreen> createState() => _DataScienceScreenState();
}

class _DataScienceScreenState extends State<DataScienceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _scoreData;
  Map<String, dynamic>? _trendsData;
  Map<String, dynamic>? _predictionData;
  Map<String, dynamic>? _anomaliesData;
  Map<String, dynamic>? _clusteringData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      final userId = auth.user?.uid;
      if (userId == null) return;

      final results = await Future.wait([
        ApiService.getFinancialScore(userId),
        ApiService.getTrends(userId),
        ApiService.getPrediction(userId),
        ApiService.getAnomalies(userId),
        ApiService.getClustering(userId),
      ]);

      if (!mounted) return;
      setState(() {
        _scoreData = results[0];
        _trendsData = results[1];
        _predictionData = results[2];
        _anomaliesData = results[3];
        _clusteringData = results[4];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Erreur de chargement';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        title: const Text(
          'Data Science 🤖',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadData();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: '🏆 Score'),
            Tab(text: '📈 Tendances'),
            Tab(text: '🔮 Prédiction'),
            Tab(text: '⚠️ Anomalies'),
            Tab(text: '👤 Profil'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary))
          : _error != null
              ? Center(child: Text(_error!))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildScoreTab(),
                    _buildTrendsTab(),
                    _buildPredictionTab(),
                    _buildAnomaliesTab(),
                    _buildClusteringTab(),
                  ],
                ),
    );
  }

  // ── Tab Score ──
  Widget _buildScoreTab() {
    if (_scoreData == null) return const Center(child: Text('Pas de données'));
    final score = _scoreData!['score'] ?? 0;
    final level = _scoreData!['level'] ?? '';
    final message = _scoreData!['message'] ?? '';
    final stats = _scoreData!['stats'] ?? {};
    final details = _scoreData!['details'] as Map<String, dynamic>? ?? {};

    Color scoreColor;
    switch (_scoreData!['color']) {
      case 'green': scoreColor = Colors.green; break;
      case 'blue': scoreColor = Colors.blue; break;
      case 'orange': scoreColor = Colors.orange; break;
      default: scoreColor = Colors.red;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Cercle score
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
                    border: Border.all(color: scoreColor, width: 4),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$score',
                          style: TextStyle(
                              color: scoreColor,
                              fontSize: 40,
                              fontWeight: FontWeight.bold)),
                      Text('/ 100',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(level,
                    style: TextStyle(
                        color: scoreColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statItem('Revenus',
                        '${stats['total_income']?.toStringAsFixed(0)} TND',
                        Colors.greenAccent),
                    _statItem('Dépenses',
                        '${stats['total_expense']?.toStringAsFixed(0)} TND',
                        Colors.redAccent),
                    _statItem('Épargne',
                        '${stats['savings_rate']}%',
                        Colors.amberAccent),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Détail du score',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark)),
          ),
          const SizedBox(height: 12),
          ...details.entries.map((e) {
            final detail = e.value as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE0E4F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.key.toUpperCase(),
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                          fontSize: 12)),
                  Row(
                    children: [
                      Text(detail['status'] ?? ''),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('${detail['points']} pts',
                            style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Tab Tendances ──
  Widget _buildTrendsTab() {
    if (_trendsData == null) return const Center(child: Text('Pas de données'));
    final trends = _trendsData!['monthly_trends'] as List? ?? [];
    final topCats = _trendsData!['top_categories'] as List? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tendances mensuelles 📅',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark)),
          const SizedBox(height: 12),
          if (trends.isEmpty)
            const Center(child: Text('Pas de données mensuelles'))
          else
            ...trends.map((t) {
              final income = (t['income'] ?? 0.0).toDouble();
              final expense = (t['expense'] ?? 0.0).toDouble();
              final balance = (t['balance'] ?? 0.0).toDouble();
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE0E4F0)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(t['month'] ?? '',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: balance >= 0
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${balance >= 0 ? '+' : ''}${balance.toStringAsFixed(2)} TND',
                            style: TextStyle(
                                color: balance >= 0
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                            child: _trendBar('Revenus', income,
                                income + expense > 0
                                    ? income / (income + expense)
                                    : 0,
                                Colors.green)),
                        const SizedBox(width: 8),
                        Expanded(
                            child: _trendBar('Dépenses', expense,
                                income + expense > 0
                                    ? expense / (income + expense)
                                    : 0,
                                Colors.red)),
                      ],
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 20),
          const Text('Top catégories 🏆',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark)),
          const SizedBox(height: 12),
          ...topCats.asMap().entries.map((e) {
            final medals = ['🥇', '🥈', '🥉', '4️⃣', '5️⃣'];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE0E4F0)),
              ),
              child: Row(
                children: [
                  Text(medals[e.key],
                      style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(e.value['category'] ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textDark))),
                  Text('${e.value['amount']?.toStringAsFixed(2)} TND',
                      style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Tab Prédiction ──
  Widget _buildPredictionTab() {
    if (_predictionData == null)
      return const Center(child: Text('Pas de données'));

    final prediction = (_predictionData!['prediction'] ?? 0.0).toDouble();
    final current =
        (_predictionData!['current_month_expense'] ?? 0.0).toDouble();
    final difference = (_predictionData!['difference'] ?? 0.0).toDouble();
    final trend = _predictionData!['trend'] ?? '';
    final confidence = _predictionData!['confidence'] ?? 0;
    final message = _predictionData!['message'] ?? '';
    final nbMonths = _predictionData!['nb_months_analyzed'] ?? 0;

    final isHausse = trend == 'hausse';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text('Prédiction mois prochain 🔮',
                    style:
                        TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 12),
                Text('${prediction.toStringAsFixed(2)} TND',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                        isHausse
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        color: isHausse
                            ? Colors.redAccent
                            : Colors.greenAccent,
                        size: 18),
                    const SizedBox(width: 4),
                    Text(
                        '${difference.toStringAsFixed(2)} TND ($trend)',
                        style: TextStyle(
                            color: isHausse
                                ? Colors.redAccent
                                : Colors.greenAccent,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _infoCard('💡 Message', message, AppTheme.primary),
          const SizedBox(height: 12),
          _infoCard('📊 Mois actuel',
              '${current.toStringAsFixed(2)} TND', Colors.blue),
          const SizedBox(height: 12),
          _infoCard('🎯 Confiance', '$confidence%', Colors.green),
          const SizedBox(height: 12),
          _infoCard('📅 Mois analysés', '$nbMonths mois', Colors.orange),
        ],
      ),
    );
  }

  // ── Tab Anomalies ──
  Widget _buildAnomaliesTab() {
    if (_anomaliesData == null)
      return const Center(child: Text('Pas de données'));

    final anomalies = _anomaliesData!['anomalies'] as List? ?? [];
    final stats = _anomaliesData!['stats'] as Map<String, dynamic>? ?? {};
    final message = _anomaliesData!['message'] ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: anomalies.isEmpty
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: anomalies.isEmpty
                      ? Colors.green.withValues(alpha: 0.3)
                      : Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Text(anomalies.isEmpty ? '✅' : '⚠️',
                    style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(message,
                        style: TextStyle(
                            color: anomalies.isEmpty
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          if (stats.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _infoCard('📊 Moyenne',
                        '${stats['mean_expense']?.toStringAsFixed(2)} TND',
                        Colors.blue)),
                const SizedBox(width: 12),
                Expanded(
                    child: _infoCard('📋 Total',
                        '${stats['total_transactions']} transactions',
                        Colors.purple)),
              ],
            ),
          ],
          if (anomalies.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text('Transactions anormales',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark)),
            const SizedBox(height: 12),
            ...anomalies.map((a) {
              final deviation = (a['deviation'] ?? 0.0).toDouble();
              final isAbove = deviation > 0;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(a['title'] ?? '',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark)),
                        Text(
                            '${(a['amount'] ?? 0.0).toStringAsFixed(2)} TND',
                            style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(a['category'] ?? '',
                        style: const TextStyle(
                            color: AppTheme.textGrey, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(a['message'] ?? '',
                        style: TextStyle(
                            color:
                                isAbove ? Colors.red : Colors.green,
                            fontSize: 12)),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  // ── Tab Clustering ──
  Widget _buildClusteringTab() {
    if (_clusteringData == null)
      return const Center(child: Text('Pas de données'));

    final profile = _clusteringData!['profile'] ?? '';
    final description = _clusteringData!['description'] ?? '';
    final icon = _clusteringData!['icon'] ?? '❓';
    final advice = _clusteringData!['advice'] ?? '';
    final stats =
        _clusteringData!['stats'] as Map<String, dynamic>? ?? {};

    Color profileColor;
    switch (_clusteringData!['color']) {
      case 'green': profileColor = Colors.green; break;
      case 'blue': profileColor = Colors.blue; break;
      case 'orange': profileColor = Colors.orange; break;
      default: profileColor = Colors.red;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: profileColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: profileColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Text(icon,
                    style: const TextStyle(fontSize: 60)),
                const SizedBox(height: 12),
                Text(profile,
                    style: TextStyle(
                        color: profileColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: profileColor.withValues(alpha: 0.8),
                        fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _infoCard('💡 Conseil', advice, AppTheme.primary),
          const SizedBox(height: 20),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Statistiques',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark)),
          ),
          const SizedBox(height: 12),
          if (stats.isNotEmpty) ...[
            _statRow('💰 Revenus',
                '${stats['total_income']?.toStringAsFixed(2)} TND'),
            _statRow('💸 Dépenses',
                '${stats['total_expense']?.toStringAsFixed(2)} TND'),
            _statRow('🏠 Essentiels',
                '${stats['essential_rate']}% du revenu'),
            _statRow('🎮 Non essentiels',
                '${stats['non_essential_rate']}% du revenu'),
            _statRow('💎 Taux d\'épargne',
                '${stats['savings_rate']}%'),
          ],
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13)),
        Text(label,
            style:
                const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _trendBar(
      String label, double amount, double ratio, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${amount.toStringAsFixed(0)} TND',
            style: TextStyle(color: color, fontSize: 11)),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: ratio,
          backgroundColor: color.withValues(alpha: 0.1),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          borderRadius: BorderRadius.circular(4),
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _infoCard(String title, String value, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                const SizedBox(height: 4),
                Text(value,
                    style: TextStyle(
                        color: color.withValues(alpha: 0.8),
                        fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E4F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.w500)),
          Text(value,
              style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}