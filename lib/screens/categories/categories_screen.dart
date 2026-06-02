import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../models/category_model.dart';
import '../../theme/app_theme.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final essential = provider.categories
        .where((c) => !c.isIncome && c.isEssential).toList();
    final nonEssential = provider.categories
        .where((c) => !c.isIncome && !c.isEssential).toList();
    final income = provider.categories
        .where((c) => c.isIncome).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        title: const Text(
          'Catégories',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionTitle('Dépenses essentielles 🏠'),
          const SizedBox(height: 10),
          ...essential.map((cat) => _buildCategoryItem(cat)),
          const SizedBox(height: 24),

          _buildSectionTitle('Dépenses non essentielles 🎮'),
          const SizedBox(height: 10),
          ...nonEssential.map((cat) => _buildCategoryItem(cat)),
          const SizedBox(height: 24),

          _buildSectionTitle('Revenus 💰'),
          const SizedBox(height: 10),
          ...income.map((cat) => _buildCategoryItem(cat)),
          const SizedBox(height: 24),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.textDark,
      ),
    );
  }

  Widget _buildCategoryItem(CategoryModel cat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
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
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                cat.icon,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              cat.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
                fontSize: 15,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: cat.isIncome
                  ? Colors.blue.withValues(alpha: 0.1)
                  : cat.isEssential
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              cat.isIncome
                  ? 'Revenu'
                  : cat.isEssential
                      ? 'Essentielle'
                      : 'Non essentielle',
              style: TextStyle(
                color: cat.isIncome
                    ? Colors.blue
                    : cat.isEssential
                        ? Colors.green
                        : Colors.orange,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    String selectedIcon = '📦';
    bool isEssential = false;
    bool isIncome = false;

    final icons = [
      '🛒', '🏠', '🚗', '💊', '📚', '🎮',
      '🍽️', '🛍️', '✈️', '💰', '📦', '💡',
      '📱', '🎵', '🏋️', '🐾', '🎁', '🏦',
      '💻', '📈', '🎓', '🛠️',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                    'Nouvelle catégorie',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: 'Nom de la catégorie',
                      hintStyle: TextStyle(color: AppTheme.textGrey),
                      prefixIcon: Icon(Icons.label_outline,
                          color: AppTheme.textGrey),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Choisir une icône',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: icons.map((icon) {
                      final isSelected = selectedIcon == icon;
                      return GestureDetector(
                        onTap: () =>
                            setModalState(() => selectedIcon = icon),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primary
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primary
                                  : const Color(0xFFE0E4F0),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              icon,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Type revenu ou dépense
                  Row(
                    children: [
                      const Text(
                        'Catégorie de revenu ?',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const Spacer(),
                      Switch(
                        value: isIncome,
                        activeThumbColor: AppTheme.primary,
                        onChanged: (val) =>
                            setModalState(() => isIncome = val),
                      ),
                    ],
                  ),

                  // Essentielle seulement si dépense
                  if (!isIncome)
                    Row(
                      children: [
                        const Text(
                          'Essentielle ?',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: isEssential,
                          activeThumbColor: AppTheme.primary,
                          onChanged: (val) =>
                              setModalState(() => isEssential = val),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isEmpty) return;
                        final newCategory = CategoryModel(
                          id: DateTime.now()
                              .millisecondsSinceEpoch
                              .toString(),
                          name: nameController.text.trim(),
                          icon: selectedIcon,
                          isEssential: isEssential,
                          isIncome: isIncome,
                        );
                        context
                            .read<TransactionProvider>()
                            .addCategory(newCategory);
                        Navigator.pop(context);
                      },
                      child: const Text('Ajouter'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }
}