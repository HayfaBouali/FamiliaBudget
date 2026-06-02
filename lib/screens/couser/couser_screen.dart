import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class CouserScreen extends StatefulWidget {
  const CouserScreen({super.key});

  @override
  State<CouserScreen> createState() => _CouserScreenState();
}

class _CouserScreenState extends State<CouserScreen> {
  final _emailController = TextEditingController();
  List<Map<String, dynamic>> _cousers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCoUsers();
  }

  Future<void> _loadCoUsers() async {
    try {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      final userId = auth.user?.uid;
      if (userId == null) return;

      final data = await ApiService.getCoUsers(userId);
      if (!mounted) return;
      setState(() {
        _cousers = data.map((c) => {
          'id': c['id'],
          'name': c['name'] ?? c['email'].split('@')[0],
          'email': c['email'],
          'avatar': (c['name'] ?? c['email'])[0].toUpperCase(),
        }).toList().cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cousers = [];
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _addCouser() async {
    if (_emailController.text.isEmpty) return;

    try {
      final auth = context.read<AuthProvider>();
      final userId = auth.user?.uid;
      if (userId == null) return;

      await ApiService.inviteCoUser(userId, _emailController.text.trim());
      
      _emailController.clear();
      if (!mounted) return;
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invitation envoyée avec succès !'),
          backgroundColor: Colors.green,
        ),
      );

      await _loadCoUsers();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'invitation'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _removeCouser(int index) async {
    try {
      final auth = context.read<AuthProvider>();
      final userId = auth.user?.uid;
      if (userId == null) return;

      final coUserId = _cousers[index]['id'];
      await ApiService.removeCoUser(userId, coUserId);
      
      setState(() => _cousers.removeAt(index));
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Co-utilisateur supprimé'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la suppression'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        title: const Text(
          'Co-utilisateurs',
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
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Info card ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Invitez un membre de votre famille à gérer le budget ensemble.',
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

            // ── Compte principal ──
            const Text(
              'Compte principal',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE0E4F0)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.primary,
                    child: Text(
                      auth.user?.name.isNotEmpty == true
                          ? auth.user!.name[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.user?.name ?? 'Utilisateur',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          auth.user?.email ?? '',
                          style: const TextStyle(
                            color: AppTheme.textGrey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Admin',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Co-utilisateurs ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Co-utilisateurs',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showInviteDialog(context),
                  icon: const Icon(Icons.add, color: AppTheme.primary, size: 18),
                  label: const Text(
                    'Inviter',
                    style: TextStyle(color: AppTheme.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Liste co-utilisateurs
            _cousers.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE0E4F0)),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.people_outline,
                            size: 40, color: AppTheme.textGrey),
                        SizedBox(height: 8),
                        Text(
                          'Aucun co-utilisateur',
                          style: TextStyle(color: AppTheme.textGrey),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: _cousers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final couser = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border:
                              Border.all(color: const Color(0xFFE0E4F0)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor:
                                  AppTheme.secondary.withValues(alpha: 0.2),
                              child: Text(
                                couser['avatar']!,
                                style: const TextStyle(
                                  color: AppTheme.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    couser['name']!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                  Text(
                                    couser['email']!,
                                    style: const TextStyle(
                                      color: AppTheme.textGrey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: AppTheme.error,
                              ),
                              onPressed: () => _removeCouser(index),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  void _showInviteDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Inviter un co-utilisateur',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Entrez l\'email de la personne à inviter',
                style: TextStyle(
                  color: AppTheme.textGrey,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'exemple@email.com',
                  hintStyle: TextStyle(color: AppTheme.textGrey),
                  prefixIcon: Icon(Icons.email_outlined,
                      color: AppTheme.textGrey),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addCouser,
                  child: const Text('Envoyer l\'invitation'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}