import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    try {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      final userId = auth.user?.uid;
      if (userId == null) return;

      final data = await ApiService.getRecommendations(userId);
      if (!mounted) return;
      setState(() {
        _data = data;
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
          'Recommandations',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: AppTheme.textGrey),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_data?['summary'] != null)
                        _buildSummaryCard(_data!['summary']),
                      const SizedBox(height: 24),
                      const Text(
                        'Conseils personnalisés 🤖',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_data?['recommendations'] != null)
                        ...(_data!['recommendations'] as List)
                            .map((rec) => _buildRecommendationCard(rec)),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSummaryCard(Map<String, dynamic> summary) {
    final balance = (summary['balance'] ?? 0.0).toDouble();
    final savingsRate = (summary['savings_rate'] ?? 0.0).toDouble();
    final totalIncome = (summary['total_income'] ?? 0.0).toDouble();
    final totalExpense = (summary['total_expense'] ?? 0.0).toDouble();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Votre santé financière',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            '${balance.toStringAsFixed(2)} TND',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Revenus',
                  '${totalIncome.toStringAsFixed(2)} TND',
                  Icons.arrow_upward_rounded, Colors.greenAccent),
              Container(width: 1, height: 40,
                  color: Colors.white.withValues(alpha: 0.2)),
              _buildSummaryItem('Dépenses',
                  '${totalExpense.toStringAsFixed(2)} TND',
                  Icons.arrow_downward_rounded, Colors.redAccent),
              Container(width: 1, height: 40,
                  color: Colors.white.withValues(alpha: 0.2)),
              _buildSummaryItem('Épargne',
                  '${savingsRate.toStringAsFixed(1)}%',
                  Icons.savings_outlined, Colors.amberAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _buildRecommendationCard(Map<String, dynamic> rec) {
    Color color;
    Color bgColor;

    switch (rec['type']) {
      case 'danger':
        color = Colors.red;
        bgColor = Colors.red.withValues(alpha: 0.08);
        break;
      case 'warning':
        color = Colors.orange;
        bgColor = Colors.orange.withValues(alpha: 0.08);
        break;
      case 'success':
        color = Colors.green;
        bgColor = Colors.green.withValues(alpha: 0.08);
        break;
      default:
        color = AppTheme.primary;
        bgColor = AppTheme.primary.withValues(alpha: 0.08);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(rec['icon'] ?? '💡',
              style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rec['title'] ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  rec['message'] ?? '',
                  style: TextStyle(
                    color: color.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    rec['priority'] == 'high'
                        ? '🔴 Priorité haute'
                        : rec['priority'] == 'medium'
                            ? '🟡 Priorité moyenne'
                            : '🟢 Priorité basse',
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}