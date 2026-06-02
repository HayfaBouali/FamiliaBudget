import 'category_model.dart';

enum TransactionType { income, expense }

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final CategoryModel category;
  final DateTime date;
  final String? note;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
  });

  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;

  static List<TransactionModel> mockTransactions = [
    TransactionModel(
      id: 't1',
      title: 'Salaire mensuel',
      amount: 2500,
      type: TransactionType.income,
      category: CategoryModel.defaultCategories[10], // Salaire
      date: DateTime.now().subtract(const Duration(days: 1)),
      note: 'Salaire du mois',
    ),
    TransactionModel(
      id: 't2',
      title: 'Courses supermarché',
      amount: 120,
      type: TransactionType.expense,
      category: CategoryModel.defaultCategories[0], // Alimentation
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
    TransactionModel(
      id: 't3',
      title: 'Loyer',
      amount: 800,
      type: TransactionType.expense,
      category: CategoryModel.defaultCategories[1], // Logement
      date: DateTime.now().subtract(const Duration(days: 3)),
    ),
    TransactionModel(
      id: 't4',
      title: 'Restaurant',
      amount: 45,
      type: TransactionType.expense,
      category: CategoryModel.defaultCategories[6], // Restaurants
      date: DateTime.now().subtract(const Duration(days: 4)),
    ),
    TransactionModel(
      id: 't5',
      title: 'Freelance',
      amount: 500,
      type: TransactionType.income,
      category: CategoryModel.defaultCategories[11], // Freelance
      date: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];
}