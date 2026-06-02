import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/transaction_provider.dart';
import '../../models/transaction_model.dart';
import '../../theme/app_theme.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  int _selectedPeriod = 0; // 0=semaine, 1=mois, 2=année

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    // Utiliser les données filtrées par période
    final totalIncome = provider.getTotalIncomeByPeriod(_selectedPeriod);
    final totalExpense = provider.getTotalExpenseByPeriod(_selectedPeriod);
    final balance = provider.getBalanceByPeriod(_selectedPeriod);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        title: const Text(
          'Analyse financière',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Résumé cards ──
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Revenus',
                    totalIncome,
                    Icons.arrow_upward_rounded,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Dépenses',
                    totalExpense,
                    Icons.arrow_downward_rounded,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildSummaryCard(
              'Solde net',
              balance,
              Icons.account_balance_wallet_outlined,
              balance >= 0 ? Colors.green : Colors.red,
              fullWidth: true,
            ),
            const SizedBox(height: 24),

            // ── Filtre période ──
            const Text(
              'Période',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildPeriodButton('Semaine', 0),
                const SizedBox(width: 8),
                _buildPeriodButton('Mois', 1),
                const SizedBox(width: 8),
                _buildPeriodButton('Année', 2),
              ],
            ),
            const SizedBox(height: 24),

            // ── Graphique barres ──
            const Text(
              'Revenus vs Dépenses',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE0E4F0)),
              ),
              child: SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: (totalIncome > totalExpense
                            ? totalIncome
                            : totalExpense) *
                        1.2,
                    barTouchData: BarTouchData(enabled: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) => Text(
                            '${value.toInt()}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.textGrey,
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const labels = ['Rev.', 'Dép.', 'Solde'];
                            return Text(
                              labels[value.toInt()],
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textGrey,
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      BarChartGroupData(x: 0, barRods: [
                        BarChartRodData(
                          toY: totalIncome,
                          color: Colors.green,
                          width: 40,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ]),
                      BarChartGroupData(x: 1, barRods: [
                        BarChartRodData(
                          toY: totalExpense,
                          color: Colors.red,
                          width: 40,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ]),
                      BarChartGroupData(x: 2, barRods: [
                        BarChartRodData(
                          toY: balance.abs(),
                          color: balance >= 0
                              ? AppTheme.primary
                              : Colors.orange,
                          width: 40,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Graphique camembert dépenses ──
            const Text(
              'Dépenses par catégorie',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE0E4F0)),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: _buildPieChart(provider),
                  ),
                  const SizedBox(height: 16),
                  _buildPieLegend(provider),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Liste dépenses par catégorie ──
            const Text(
              'Détail par catégorie',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),
            ..._buildCategoryList(provider),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String label,
    double amount,
    IconData icon,
    Color color, {
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E4F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textGrey,
                  fontSize: 12,
                ),
              ),
              Text(
                '${amount.toStringAsFixed(2)} TND',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, int index) {
    final isSelected = _selectedPeriod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primary : const Color(0xFFE0E4F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textGrey,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart(TransactionProvider provider) {
    final expenses = provider.getByPeriod(_selectedPeriod)
        .where((t) => t.type == TransactionType.expense)
        .toList();
    if (expenses.isEmpty) {
      return const Center(
        child: Text(
          'Aucune dépense',
          style: TextStyle(color: AppTheme.textGrey),
        ),
      );
    }

    final Map<String, double> categoryTotals = {};
    for (final t in expenses) {
      categoryTotals[t.category.name] =
          (categoryTotals[t.category.name] ?? 0) + t.amount;
    }

    final colors = [
      AppTheme.primary,
      Colors.orange,
      Colors.green,
      Colors.red,
      Colors.teal,
      Colors.pink,
    ];

    final totalExpenseFiltered = provider.getTotalExpenseByPeriod(_selectedPeriod);
    final sections = categoryTotals.entries.toList().asMap().entries.map((e) {
      final index = e.key;
      final entry = e.value;
      return PieChartSectionData(
        value: entry.value,
        color: colors[index % colors.length],
        radius: 60,
        title: totalExpenseFiltered > 0
            ? '${(entry.value / totalExpenseFiltered * 100).toStringAsFixed(0)}%'
            : '0%',
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();

    return PieChart(PieChartData(sections: sections));
  }

  Widget _buildPieLegend(TransactionProvider provider) {
    final expenses = provider.getByPeriod(_selectedPeriod)
        .where((t) => t.type == TransactionType.expense)
        .toList();
    final Map<String, double> categoryTotals = {};
    for (final t in expenses) {
      categoryTotals[t.category.name] =
          (categoryTotals[t.category.name] ?? 0) + t.amount;
    }

    final colors = [
      AppTheme.primary,
      Colors.orange,
      Colors.green,
      Colors.red,
      Colors.teal,
      Colors.pink,
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: categoryTotals.entries.toList().asMap().entries.map((e) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: colors[e.key % colors.length],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              e.value.key,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textGrey,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  List<Widget> _buildCategoryList(TransactionProvider provider) {
    final expenses = provider.getByPeriod(_selectedPeriod)
        .where((t) => t.type == TransactionType.expense)
        .toList();
    final Map<String, double> categoryTotals = {};
    final Map<String, String> categoryIcons = {};

    for (final t in expenses) {
      categoryTotals[t.category.name] =
          (categoryTotals[t.category.name] ?? 0) + t.amount;
      categoryIcons[t.category.name] = t.category.icon;
    }

    final sorted = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalExpenseFiltered = provider.getTotalExpenseByPeriod(_selectedPeriod);

    return sorted.map((entry) {
      final percentage = totalExpenseFiltered > 0
          ? entry.value / totalExpenseFiltered
          : 0.0;

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
            Text(
              categoryIcons[entry.key] ?? '📦',
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${entry.value.toStringAsFixed(2)} TND',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: const Color(0xFFE0E4F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primary,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(percentage * 100).toStringAsFixed(0)}% des dépenses',
                    style: const TextStyle(
                      color: AppTheme.textGrey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}