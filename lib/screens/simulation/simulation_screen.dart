import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {

  bool _isLoading = true;
  String? _error;
  double _simulatedIncome = 0;
  double _simulatedExpense = 0;

  @override
  void initState() {
    super.initState();
    _loadSimulation();
  }

  Future<void> _loadSimulation() async {
    try {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      final userId = auth.user?.uid;
      if (userId == null) return;

      final data = await ApiService.getSimulation(userId);
      if (!mounted) return;
      setState(() {
        
        _simulatedIncome =
            (data['current']['total_income'] ?? 0.0).toDouble();
        _simulatedExpense =
            (data['current']['total_expense'] ?? 0.0).toDouble();
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

  double get _simulatedBalance => _simulatedIncome - _simulatedExpense;
  double get _simulatedSavings => _simulatedIncome * 0.20;
  double get _simulatedEssential => _simulatedIncome * 0.50;
  double get _simulatedNonEssential => _simulatedIncome * 0.30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        title: const Text(
          'Simulation budget',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary))
          : _error != null
              ? Center(
                  child: Text(_error!,
                      style: const TextStyle(color: AppTheme.textGrey)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Intro ──
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppTheme.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: AppTheme.primary),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Simulez votre budget en modifiant vos revenus et dépenses pour voir l\'impact sur votre épargne.',
                                style: TextStyle(
                                  color: AppTheme.primary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Résultat simulé ──
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
                              'Solde simulé',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_simulatedBalance.toStringAsFixed(2)} TND',
                              style: TextStyle(
                                color: _simulatedBalance >= 0
                                    ? Colors.white
                                    : Colors.redAccent,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                              children: [
                                _buildBalanceItem(
                                  'Revenus',
                                  _simulatedIncome,
                                  Colors.greenAccent,
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color:
                                      Colors.white.withValues(alpha: 0.2),
                                ),
                                _buildBalanceItem(
                                  'Dépenses',
                                  _simulatedExpense,
                                  Colors.redAccent,
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color:
                                      Colors.white.withValues(alpha: 0.2),
                                ),
                                _buildBalanceItem(
                                  'Épargne',
                                  _simulatedBalance,
                                  Colors.amberAccent,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Sliders ──
                      const Text(
                        'Ajuster les paramètres',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Slider revenus
                      _buildSlider(
                        label: 'Revenus mensuels',
                        value: _simulatedIncome,
                        min: 0,
                        max: 10000,
                        color: Colors.green,
                        icon: Icons.arrow_upward_rounded,
                        onChanged: (val) =>
                            setState(() => _simulatedIncome = val),
                      ),
                      const SizedBox(height: 16),

                      // Slider dépenses
                      _buildSlider(
                        label: 'Dépenses mensuelles',
                        value: _simulatedExpense,
                        min: 0,
                        max: 10000,
                        color: Colors.red,
                        icon: Icons.arrow_downward_rounded,
                        onChanged: (val) =>
                            setState(() => _simulatedExpense = val),
                      ),
                      const SizedBox(height: 24),

                      // ── Règle 50/30/20 simulée ──
                      const Text(
                        'Répartition 50/30/20 simulée',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildBudgetRow(
                        '🏠 Essentiels (50%)',
                        _simulatedEssential,
                        Colors.blue,
                      ),
                      const SizedBox(height: 10),
                      _buildBudgetRow(
                        '🎮 Loisirs (30%)',
                        _simulatedNonEssential,
                        Colors.orange,
                      ),
                      const SizedBox(height: 10),
                      _buildBudgetRow(
                        '💰 Épargne (20%)',
                        _simulatedSavings,
                        Colors.green,
                      ),
                      const SizedBox(height: 24),

                      // ── Conseil simulé ──
                      _buildAdvice(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }

  Widget _buildBalanceItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text(
          '${amount.toStringAsFixed(0)} TND',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required Color color,
    required IconData icon,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
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
              Row(
                children: [
                  Icon(icon, color: color, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
              Text(
                '${value.toStringAsFixed(0)} TND',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: 100,
            activeColor: color,
            inactiveColor: color.withValues(alpha: 0.2),
            onChanged: onChanged,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${min.toStringAsFixed(0)} TND',
                  style: const TextStyle(
                      color: AppTheme.textGrey, fontSize: 11)),
              Text('${max.toStringAsFixed(0)} TND',
                  style: const TextStyle(
                      color: AppTheme.textGrey, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetRow(String label, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E4F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
              fontSize: 14,
            ),
          ),
          Text(
            '${amount.toStringAsFixed(2)} TND',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvice() {
    String message;
    Color color;
    String icon;

    if (_simulatedBalance < 0) {
      message =
          'Attention ! Vos dépenses dépassent vos revenus de ${_simulatedBalance.abs().toStringAsFixed(2)} TND. Réduisez vos dépenses.';
      color = Colors.red;
      icon = '🚨';
    } else if (_simulatedBalance < _simulatedSavings) {
      message =
          'Votre épargne simulée est en dessous de l\'objectif de 20% (${_simulatedSavings.toStringAsFixed(2)} TND). Essayez d\'augmenter vos revenus.';
      color = Colors.orange;
      icon = '⚠️';
    } else {
      message =
          'Excellent ! Avec ce budget vous atteignez votre objectif d\'épargne de ${_simulatedSavings.toStringAsFixed(2)} TND par mois.';
      color = Colors.green;
      icon = '🎉';
    }

    return Container(
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
                  'Résultat de la simulation',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: TextStyle(
                    color: color.withValues(alpha: 0.8),
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