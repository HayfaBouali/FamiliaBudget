import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../models/transaction_model.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';
import '../transactions/add_transaction_screen.dart';
import '../transactions/transactions_screen.dart';
import '../categories/categories_screen.dart';
import '../couser/couser_screen.dart';
import '../analysis/analysis_screen.dart';
import '../budget/budget_screen.dart';
import '../profile/profile_screen.dart';
import '../recommendations/recommendations_screen.dart';
import '../simulation/simulation_screen.dart';
import '../data_science/data_science_screen.dart';
import '../ocr/ocr_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
@override
void initState() {
  super.initState();
  Future.microtask(() async {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    final transProvider = context.read<TransactionProvider>();
    
    await transProvider.loadCategories();
    
    if (!mounted) return;
    if (auth.user != null) {
      await transProvider.loadTransactions(auth.user!.uid);
    }
  });
}

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final transactions = context.watch<TransactionProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ───────── HEADER ─────────
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                child: Column(
                  children: [
                    // Top row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bonjour 👋',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              user?.name ?? 'Utilisateur',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const ProfileScreen()),
                              ),
                              child: CircleAvatar(
                                radius: 22,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.2),
                                child: Text(
                                  user?.name.isNotEmpty == true
                                      ? user!.name[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.logout,
                                  color: Colors.white70),
                              onPressed: () async {
                                await auth.logout();
                                if (context.mounted) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const LoginScreen()),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ───── CARD SOLDE ─────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Solde total',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${transactions.balance.toStringAsFixed(2)} TND',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildBalanceInfo(
                                'Revenus',
                                transactions.totalIncome,
                                Icons.arrow_upward_rounded,
                                Colors.greenAccent,
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                              _buildBalanceInfo(
                                'Dépenses',
                                transactions.totalExpense,
                                Icons.arrow_downward_rounded,
                                Colors.redAccent,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ───── ACTIONS RAPIDES ─────
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Actions rapides',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                  children: [
                    _buildActionButton(
                      icon: Icons.add_circle_outline,
                      label: 'Ajouter',
                      color: AppTheme.primary,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const AddTransactionScreen())),
                    ),
                    _buildActionButton(
                      icon: Icons.receipt_long_outlined,
                      label: 'Transactions',
                      color: AppTheme.secondary,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const TransactionsScreen())),
                    ),
                    _buildActionButton(
                      icon: Icons.document_scanner_outlined,
                      label: 'Scanner',
                      color: Colors.teal,
                      onTap: () => Navigator.push(context,
                         
                          MaterialPageRoute(
                             builder: (_) => const OcrScreen(),
                    ),
                  ),
                ),
                    _buildActionButton(
                      icon: Icons.category_outlined,
                      label: 'Catégories',
                      color: Colors.orange,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const CategoriesScreen())),
                    ),
                    _buildActionButton(
                      icon: Icons.people_outline,
                      label: 'Famille',
                      color: Colors.purple,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const CouserScreen())),
                    ),
                    _buildActionButton(
                      icon: Icons.bar_chart_outlined,
                      label: 'Analyse',
                      color: Colors.teal,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const AnalysisScreen())),
                    ),
                    _buildActionButton(
                      icon: Icons.pie_chart_outline,
                      label: 'Budget',
                      color: Colors.indigo,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const BudgetScreen())),
                    ),
                    _buildActionButton(
                      icon: Icons.lightbulb_outline,
                      label: 'Conseils',
                      color: Colors.amber,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                           builder: (_) => const RecommendationsScreen(),
                        ),
                      ),
                    ),   
                        _buildActionButton(
                            icon: Icons.calculate_outlined,
                            label: 'Simulation',
                            color: Colors.deepPurple,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                 builder: (_) => const SimulationScreen(),
                              ),
                            
                        

                         ),
                     ),
                      _buildActionButton(
                          icon: Icons.psychology_outlined,
                          label: 'Data Science',
                          color: Colors.deepOrange,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                               builder: (_) => const DataScienceScreen(),
                            ),
                          ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ───── TRANSACTIONS RÉCENTES ─────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Transactions récentes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const TransactionsScreen())),
                      child: const Text(
                        'Voir tout',
                        style: TextStyle(color: AppTheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Liste ou empty state
              transactions.recentTransactions.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.receipt_long_outlined,
                                size: 34,
                                color: AppTheme.primary,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Aucune transaction',
                              style: TextStyle(
                                color: AppTheme.textDark,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Ajoutez votre première transaction 💡',
                              style: TextStyle(
                                color: AppTheme.textGrey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: transactions.recentTransactions
                          .map((t) => _buildTransactionItem(t))
                          .toList(),
                    ),
              const SizedBox(height: 90),
            ],
          ),
        ),
      ),

      // ───── FLOATING BUTTON ─────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const AddTransactionScreen()),
        ),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Ajouter',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildBalanceInfo(
      String label, double amount, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${amount.toStringAsFixed(2)} TND',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(TransactionModel t) {
    final isIncome = t.isIncome;
    final dateStr = '${t.date.day}/${t.date.month}/${t.date.year}';
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E4F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isIncome
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                t.category.icon,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                    fontSize: 14,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      t.category.name,
                      style: const TextStyle(
                        color: AppTheme.textGrey,
                        fontSize: 12,
                      ),
                    ),
                    const Text(
                      ' • ',
                      style: TextStyle(
                        color: AppTheme.textGrey,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        color: AppTheme.textGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}${t.amount.toStringAsFixed(2)} TND',
            style: TextStyle(
              color: isIncome ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}