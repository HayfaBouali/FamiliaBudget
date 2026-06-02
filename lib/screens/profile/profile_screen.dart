import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<TransactionProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        title: const Text(
          'Mon profil',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header profil ──
            Container(
              width: double.infinity,
              color: AppTheme.primary,
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Text(
                      user?.name.isNotEmpty == true
                          ? user!.name[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? 'Utilisateur',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stats rapides
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(
                        '${provider.transactions.length}',
                        'Transactions',
                      ),
                      _buildStatItem(
                        '${provider.totalIncome.toStringAsFixed(0)} TND',
                        'Revenus',
                      ),
                      _buildStatItem(
                        '${provider.totalExpense.toStringAsFixed(0)} TND',
                        'Dépenses',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Informations personnelles ──
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informations personnelles',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildInfoCard(
                    icon: Icons.person_outline,
                    label: 'Nom complet',
                    value: user?.name ?? 'Non défini',
                  ),
                  const SizedBox(height: 10),
                  _buildInfoCard(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: user?.email ?? 'Non défini',
                  ),
                  const SizedBox(height: 10),
                  _buildInfoCard(
                    icon: Icons.calendar_today_outlined,
                    label: 'Membre depuis',
                    value: user?.createdAt != null
                        ? '${user!.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}'
                        : 'Non défini',
                  ),
                  const SizedBox(height: 24),

                  // ── Paramètres ──
                  const Text(
                    'Paramètres',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildMenuButton(
                    icon: Icons.edit_outlined,
                    label: 'Modifier le profil',
                    color: AppTheme.primary,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fonctionnalité en développement'),
                          backgroundColor: AppTheme.primary,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildMenuButton(
                    icon: Icons.lock_outline,
                    label: 'Changer le mot de passe',
                    color: AppTheme.primary,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fonctionnalité en développement'),
                          backgroundColor: AppTheme.primary,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildMenuButton(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    color: AppTheme.primary,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fonctionnalité en développement'),
                          backgroundColor: AppTheme.primary,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildMenuButton(
                    icon: Icons.language_outlined,
                    label: 'Langue',
                    color: AppTheme.primary,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fonctionnalité en développement'),
                          backgroundColor: AppTheme.primary,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // ── Déconnexion ──
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await auth.logout();
                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.logout, color: AppTheme.error),
                      label: const Text(
                        'Se déconnecter',
                        style: TextStyle(color: AppTheme.error),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.error),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E4F0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 22),
          const SizedBox(width: 14),
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
                value,
                style: const TextStyle(
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE0E4F0)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.textGrey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}