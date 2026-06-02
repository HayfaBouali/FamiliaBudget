import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../services/api_service.dart';

class TransactionProvider extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  List<CategoryModel> _categories = CategoryModel.defaultCategories;
  bool _isLoading = false;
  String? _errorMessage;

  List<TransactionModel> get transactions => _transactions;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Total revenus
  double get totalIncome => _transactions
      .where((t) => t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  // Total dépenses
  double get totalExpense => _transactions
      .where((t) => t.isExpense)
      .fold(0, (sum, t) => sum + t.amount);

  // Solde
  double get balance => totalIncome - totalExpense;

  // Transactions récentes
  List<TransactionModel> get recentTransactions {
    final sorted = [..._transactions]
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(5).toList();
  }

  // ── Charger les transactions depuis l'API ──
  Future<void> loadTransactions(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiService.getTransactions(userId);
      _transactions = data.map((t) {
        // Trouver la catégorie correspondante
        final category = _categories.firstWhere(
          (c) => c.id == t['category_id'],
          orElse: () => _categories.last,
        );

        return TransactionModel(
          id: t['id'],
          title: t['title'],
          amount: t['amount'].toDouble(),
          type: t['type'] == 'income'
              ? TransactionType.income
              : TransactionType.expense,
          category: category,
          date: DateTime.parse(t['date']),
          note: t['note'],
        );
      }).toList();

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Erreur de chargement des transactions';
      // Charger les données mock en cas d'erreur
      _transactions = TransactionModel.mockTransactions;
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Charger les catégories depuis l'API ──
  Future<void> loadCategories() async {
    try {
      final data = await ApiService.getCategories();
      if (data.isNotEmpty) {
        _categories = data.map((c) => CategoryModel(
          id: c['id'],
          name: c['name'],
          icon: c['icon'],
          isEssential: c['is_essential'],
          isIncome: c['is_income'],
        )).toList();
        notifyListeners();
      }
    } catch (e) {
      // Garder les catégories par défaut
      _categories = CategoryModel.defaultCategories;
    }
  }

  // ── Ajouter une transaction via API ──
  Future<bool> addTransactionApi(
    String userId,
    TransactionModel transaction,
  ) async {
    try {
      final data = {
        'title': transaction.title,
        'amount': transaction.amount,
        'type': transaction.isIncome ? 'income' : 'expense',
        'category_id': transaction.category.id,
        'date': transaction.date.toIso8601String(),
        'note': transaction.note,
      };

      final response = await ApiService.addTransaction(userId, data);

      if (response.containsKey('id')) {
        _transactions.add(transaction);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      // Fallback : ajouter localement
      _transactions.add(transaction);
      notifyListeners();
      return true;
    }
  }

  // ── Supprimer une transaction ──
  Future<void> deleteTransaction(String id) async {
    try {
      await ApiService.deleteTransaction(id);
    } catch (e) {
      // Continuer même si l'API échoue
    }
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  // ── Ajouter une catégorie ──
  Future<void> addCategoryApi(CategoryModel category) async {
    try {
      await ApiService.addCategory({
        'name': category.name,
        'icon': category.icon,
        'is_essential': category.isEssential,
        'is_income': category.isIncome,
      });
    } catch (e) {
      // Continuer même si l'API échoue
    }
    _categories.add(category);
    notifyListeners();
  }

  // ── Charger mock data (fallback) ──
  void loadMockData() {
    _transactions = TransactionModel.mockTransactions;
    notifyListeners();
  }

  // ── Filtrer par type ──
  List<TransactionModel> getByType(TransactionType type) {
    return _transactions.where((t) => t.type == type).toList();
  }

  // ── Filtrer par catégorie ──
  List<TransactionModel> getByCategory(String categoryId) {
    return _transactions
        .where((t) => t.category.id == categoryId)
        .toList();
  }

  void addCategory(CategoryModel category) {
    _categories.add(category);
    notifyListeners();
  }

  void addTransaction(TransactionModel transaction) {
    _transactions.add(transaction);
    notifyListeners();
  }

  // ── Filtrer par période ──
  List<TransactionModel> getByPeriod(int period) {
    final now = DateTime.now();
    DateTime startDate;

    switch (period) {
      case 0: // Semaine
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 1: // Mois
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 2: // Année
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        return _transactions;
    }

    return _transactions.where((t) => t.date.isAfter(startDate)).toList();
  }

  // ── Totaux par période ──
  double getTotalIncomeByPeriod(int period) {
    return getByPeriod(period)
        .where((t) => t.isIncome)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double getTotalExpenseByPeriod(int period) {
    return getByPeriod(period)
        .where((t) => t.isExpense)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double getBalanceByPeriod(int period) {
    return getTotalIncomeByPeriod(period) - getTotalExpenseByPeriod(period);
  }
}