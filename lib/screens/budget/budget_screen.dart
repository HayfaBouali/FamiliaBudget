import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../models/transaction_model.dart';
import '../../theme/app_theme.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final income = provider.totalIncome;

    // ── Règle 50/30/20 ──
    final double essential = income * 0.50;
    final double nonEssential = income * 0.30;
    final double savings = income * 0.20;

    // Dépenses réelles par type
    final expenses = provider.getByType(TransactionType.expense);
    double spentEssential = 0;
    double spentNonEssential = 0;

    for (final t in expenses) {
      if (t.category.isEssential) {
        spentEssential += t.amount;
      } else {
        spentNonEssential += t.amount;
      }
    }

    final double spentTotal = spentEssential + spentNonEssential;
    final double actualSavings = income - spentTotal;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        title: const Text(
          'Suivi du budget',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: income == 0
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning_amber_outlined,
                      size: 60, color: AppTheme.textGrey),
                  SizedBox(height: 16),
                  Text(
                    'Ajoutez d\'abord un revenu\npour calculer votre budget',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textGrey,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header règle ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Règle financière 50/30/20',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Basée sur votre revenu mensuel',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${income.toStringAsFixed(2)} TND',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Revenu total',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Explication règle ──
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE0E4F0)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Comment ça fonctionne ?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'La règle 50/30/20 est une méthode internationale reconnue pour gérer son budget efficacement :',
                          style: TextStyle(
                            color: AppTheme.textGrey,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '🏠 50% → Besoins essentiels (loyer, alimentation, santé...)',
                          style: TextStyle(fontSize: 12, color: AppTheme.textDark),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '🎮 30% → Envies personnelles (loisirs, restaurants, shopping...)',
                          style: TextStyle(fontSize: 12, color: AppTheme.textDark),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '💰 20% → Épargne et investissement',
                          style: TextStyle(fontSize: 12, color: AppTheme.textDark),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Les 3 catégories ──
                  const Text(
                    'Votre budget calculé',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 50% Essentiels
                  _buildBudgetCard(
                    icon: '🏠',
                    title: 'Besoins essentiels',
                    subtitle: '50% de votre revenu',
                    budget: essential,
                    spent: spentEssential,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),

                  // 30% Non essentiels
                  _buildBudgetCard(
                    icon: '🎮',
                    title: 'Envies personnelles',
                    subtitle: '30% de votre revenu',
                    budget: nonEssential,
                    spent: spentNonEssential,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 12),

                  // 20% Épargne
                  _buildSavingsCard(
                    budget: savings,
                    actual: actualSavings,
                  ),
                  const SizedBox(height: 24),

                  // ── Conseil ──
                  _buildAdviceCard(
                    spentEssential: spentEssential,
                    essential: essential,
                    spentNonEssential: spentNonEssential,
                    nonEssential: nonEssential,
                    actualSavings: actualSavings,
                    savings: savings,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildBudgetCard({
    required String icon,
    required String title,
    required String subtitle,
    required double budget,
    required double spent,
    required Color color,
  }) {
    final percentage = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    final isOver = spent > budget;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isOver
              ? Colors.red.withValues(alpha: 0.3)
              : const Color(0xFFE0E4F0),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppTheme.textGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${budget.toStringAsFixed(0)} TND',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    'Budget max',
                    style: const TextStyle(
                      color: AppTheme.textGrey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: const Color(0xFFE0E4F0),
            valueColor: AlwaysStoppedAnimation<Color>(
              isOver ? Colors.red : color,
            ),
            borderRadius: BorderRadius.circular(4),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dépensé : ${spent.toStringAsFixed(2)} TND',
                style: TextStyle(
                  color: isOver ? Colors.red : AppTheme.textGrey,
                  fontSize: 12,
                ),
              ),
              Text(
                isOver
                    ? '⚠️ +${(spent - budget).toStringAsFixed(0)} TND'
                    : '✅ Reste ${(budget - spent).toStringAsFixed(0)} TND',
                style: TextStyle(
                  color: isOver ? Colors.red : Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsCard({
    required double budget,
    required double actual,
  }) {
    final isPositive = actual >= 0;
    final percentage = budget > 0
        ? (actual / budget).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPositive
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('💰', style: TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Épargne recommandée',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '20% de votre revenu',
                      style: TextStyle(
                        color: AppTheme.textGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${budget.toStringAsFixed(0)} TND',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const Text(
                    'Objectif',
                    style: TextStyle(
                      color: AppTheme.textGrey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: isPositive ? percentage : 0,
            backgroundColor: const Color(0xFFE0E4F0),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            borderRadius: BorderRadius.circular(4),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Épargne réelle : ${actual.toStringAsFixed(2)} TND',
                style: TextStyle(
                  color: isPositive ? AppTheme.textGrey : Colors.red,
                  fontSize: 12,
                ),
              ),
              Text(
                isPositive
                    ? '✅ Bien !'
                    : '⚠️ Déficit',
                style: TextStyle(
                  color: isPositive ? Colors.green : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceCard({
    required double spentEssential,
    required double essential,
    required double spentNonEssential,
    required double nonEssential,
    required double actualSavings,
    required double savings,
  }) {
    String advice;
    Color color;
    String icon;

    if (spentEssential > essential) {
      advice =
          'Vos dépenses essentielles dépassent 50% de votre revenu. Essayez de réduire certaines dépenses comme l\'alimentation ou le transport.';
      color = Colors.red;
      icon = '⚠️';
    } else if (spentNonEssential > nonEssential) {
      advice =
          'Vos dépenses non essentielles sont trop élevées. Réduisez les loisirs et restaurants pour atteindre l\'objectif de 30%.';
      color = Colors.orange;
      icon = '💡';
    } else if (actualSavings >= savings) {
      advice =
          'Excellent ! Vous respectez parfaitement la règle 50/30/20. Votre épargne est au-dessus de l\'objectif. Continuez ainsi !';
      color = Colors.green;
      icon = '🎉';
    } else {
      advice =
          'Vous êtes sur la bonne voie ! Continuez à surveiller vos dépenses pour optimiser votre épargne.';
      color = Colors.blue;
      icon = '😊';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conseil financier',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  advice,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
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