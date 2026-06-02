import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../models/transaction_model.dart';
import '../../models/category_model.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class OcrScreen extends StatefulWidget {
  const OcrScreen({super.key});

  @override
  State<OcrScreen> createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  bool _isScanning = false;
  bool _isScanned = false;
  Map<String, dynamic>? _result;
  String? _error;

  // Contrôleurs
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  CategoryModel? _selectedCategory;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickAndScan(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image == null) return;

      setState(() {
        _isScanning = true;
        _error = null;
      });

      final bytes = await image.readAsBytes();
      final fileName = image.name;

      final result = await ApiService.scanReceipt(bytes, fileName);

      if (!mounted) return;

      if (result['success'] == true) {
        final extractedResult = result['result'];
        setState(() {
          _result = extractedResult;
          _titleController.text = extractedResult['title'] ?? '';
          _amountController.text =
              extractedResult['amount']?.toString() ?? '0';
          _isScanned = true;
          _isScanning = false;

          // Sélectionner la catégorie suggérée
          final suggestedCat = extractedResult['suggested_category'];
          if (suggestedCat != null && suggestedCat['id'] != null) {
            final categories =
                context.read<TransactionProvider>().categories;
            try {
              _selectedCategory = categories.firstWhere(
                (c) => c.id == suggestedCat['id'],
              );
            } catch (e) {
              _selectedCategory = categories.isNotEmpty
                  ? categories.first
                  : null;
            }
          }
        });
      } else {
        setState(() {
          _error = result['error'] ?? 'Erreur lors du scan';
          _isScanning = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Erreur : $e';
        _isScanning = false;
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (_titleController.text.isEmpty ||
        _amountController.text.isEmpty ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs !'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Montant invalide !'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final transaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      amount: amount,
      type: TransactionType.expense,
      category: _selectedCategory!,
      date: DateTime.now(),
    );

    await context.read<TransactionProvider>().addTransactionApi(
          auth.user!.uid,
          transaction,
        );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Dépense ajoutée avec succès !'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categories = context
        .read<TransactionProvider>()
        .categories
        .where((c) => !c.isIncome)
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        title: const Text(
          'Scanner un reçu 📸',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Info ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.primary),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Prenez une photo de votre reçu ou facture. L\'IA va extraire automatiquement les informations.',
                      style: TextStyle(
                          color: AppTheme.primary, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Boutons scan ──
            if (!_isScanned) ...[
              const Text(
                'Choisir une image',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildScanButton(
                      icon: Icons.camera_alt_outlined,
                      label: 'Prendre une photo',
                      color: AppTheme.primary,
                      onTap: () => _pickAndScan(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildScanButton(
                      icon: Icons.photo_library_outlined,
                      label: 'Galerie',
                      color: AppTheme.secondary,
                      onTap: () => _pickAndScan(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
            ],

            // ── Loading ──
            if (_isScanning) ...[
              const SizedBox(height: 40),
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppTheme.primary),
                    SizedBox(height: 16),
                    Text(
                      'Analyse du reçu en cours... 🤖',
                      style: TextStyle(color: AppTheme.textGrey),
                    ),
                  ],
                ),
              ),
            ],

            // ── Erreur ──
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppTheme.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_error!,
                          style:
                              const TextStyle(color: AppTheme.error)),
                    ),
                  ],
                ),
              ),
            ],

            // ── Résultat scanné ──
            if (_isScanned && _result != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Text('✅', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 8),
                    Text(
                      'Reçu scanné avec succès !',
                      style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Vérifiez et corrigez les informations',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 16),

              // Titre
              const Text('Titre / Magasin',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark)),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Nom du magasin',
                  hintStyle: TextStyle(color: AppTheme.textGrey),
                  prefixIcon:
                      Icon(Icons.store_outlined, color: AppTheme.textGrey),
                ),
              ),
              const SizedBox(height: 16),

              // Montant
              const Text('Montant (TND)',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark)),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: '0.00',
                  hintStyle: TextStyle(color: AppTheme.textGrey),
                  prefixIcon: Icon(Icons.attach_money,
                      color: AppTheme.textGrey),
                ),
              ),
              const SizedBox(height: 16),

              // Catégorie
              const Text('Catégorie suggérée',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark)),
              const SizedBox(height: 8),
              DropdownButtonFormField<CategoryModel>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Row(
                      children: [
                        Text(cat.icon),
                        const SizedBox(width: 8),
                        Text(cat.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) =>
                    setState(() => _selectedCategory = val),
              ),
              const SizedBox(height: 32),

              // Boutons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _isScanned = false;
                          _result = null;
                          _titleController.clear();
                          _amountController.clear();
                          _selectedCategory = null;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.primary),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Rescanner',
                        style: TextStyle(color: AppTheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveTransaction,
                      child: const Text('Enregistrer'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScanButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}