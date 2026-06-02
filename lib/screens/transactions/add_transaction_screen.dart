import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../models/transaction_model.dart';
import '../../models/category_model.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  CategoryModel? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

   Future<void> _save() async {
    if (_titleController.text.isEmpty) {
      _showError('Veuillez saisir un titre');
      return;
    }
    if (_amountController.text.isEmpty) {
      _showError('Veuillez saisir un montant');
      return;
    }
    if (_selectedCategory == null) {
      _showError('Veuillez choisir une catégorie');
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showError('Montant invalide');
      return;
    }
    final auth = context.read<AuthProvider>();
    if (auth.user == null) {
      _showError("Utilisateur non connecté");
      return;
    }
final transaction = TransactionModel(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  title: _titleController.text.trim(),
  amount: amount,
  type: _selectedType,
  category: _selectedCategory!,
  date: _selectedDate,
  note: _noteController.text.isEmpty ? null : _noteController.text.trim(),
);
 try {
await context.read<TransactionProvider>().addTransactionApi(
  auth.user!.uid,
  transaction,
);
if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showError("Erreur lors de l'ajout");
    }
  }
  

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allCategories= context.read<TransactionProvider>().categories;
    final categories = allCategories
      .where((c) => _selectedType == TransactionType.income
           ? c.isIncome
           : !c.isIncome)
    .toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        title: const Text(
          'Ajouter une transaction',
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
            // ── Type revenu / dépense ──
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE0E4F0)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(
                          () => _selectedType = TransactionType.expense),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: _selectedType == TransactionType.expense
                              ? AppTheme.error
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_downward_rounded,
                              color: _selectedType == TransactionType.expense
                                  ? Colors.white
                                  : AppTheme.textGrey,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Dépense',
                              style: TextStyle(
                                color: _selectedType == TransactionType.expense
                                    ? Colors.white
                                    : AppTheme.textGrey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(
                          () => _selectedType = TransactionType.income),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: _selectedType == TransactionType.income
                              ? Colors.green
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_upward_rounded,
                              color: _selectedType == TransactionType.income
                                  ? Colors.white
                                  : AppTheme.textGrey,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Revenu',
                              style: TextStyle(
                                color: _selectedType == TransactionType.income
                                    ? Colors.white
                                    : AppTheme.textGrey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Titre ──
            const Text(
              'Titre',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Ex: Courses, Salaire...',
                hintStyle: TextStyle(color: AppTheme.textGrey),
                prefixIcon: Icon(Icons.title, color: AppTheme.textGrey),
              ),
            ),
            const SizedBox(height: 20),

            // ── Montant ──
            const Text(
              'Montant (TND)',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '0.00',
                hintStyle: TextStyle(color: AppTheme.textGrey),
                prefixIcon: Icon(Icons.attach_money, color: AppTheme.textGrey),
              ),
            ),
            const SizedBox(height: 20),

            // ── Catégorie ──
            const Text(
              'Catégorie',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((cat) {
                final isSelected = _selectedCategory?.id == cat.id;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primary
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primary
                            : const Color(0xFFE0E4F0),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(cat.icon),
                        const SizedBox(width: 4),
                        Text(
                          cat.name,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppTheme.textDark,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // ── Date ──
            const Text(
              'Date',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE0E4F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        color: AppTheme.textGrey, size: 18),
                    const SizedBox(width: 12),
                    Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: const TextStyle(color: AppTheme.textDark),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Note ──
            const Text(
              'Note (optionnel)',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Ajouter une note...',
                hintStyle: TextStyle(color: AppTheme.textGrey),
              ),
            ),
            const SizedBox(height: 32),

            // ── Bouton sauvegarder ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Sauvegarder'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}