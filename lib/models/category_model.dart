class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final bool isEssential;
  final bool isIncome;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.isEssential,
    required this.isIncome,
  });

  static List<CategoryModel> defaultCategories = [
    // Dépenses essentielles
    CategoryModel(id: 'cat_1', name: 'Alimentation', icon: '🛒', isEssential: true, isIncome: false),
    CategoryModel(id: 'cat_2', name: 'Logement', icon: '🏠', isEssential: true, isIncome: false),
    CategoryModel(id: 'cat_3', name: 'Transport', icon: '🚗', isEssential: true, isIncome: false),
    CategoryModel(id: 'cat_4', name: 'Santé', icon: '💊', isEssential: true, isIncome: false),
    CategoryModel(id: 'cat_5', name: 'Éducation', icon: '📚', isEssential: true, isIncome: false),
    // Dépenses non essentielles
    CategoryModel(id: 'cat_6', name: 'Loisirs', icon: '🎮', isEssential: false, isIncome: false),
    CategoryModel(id: 'cat_7', name: 'Restaurants', icon: '🍽️', isEssential: false, isIncome: false),
    CategoryModel(id: 'cat_8', name: 'Shopping', icon: '🛍️', isEssential: false, isIncome: false),
    CategoryModel(id: 'cat_9', name: 'Voyages', icon: '✈️', isEssential: false, isIncome: false),
    CategoryModel(id: 'cat_10', name: 'Autres dépenses', icon: '📦', isEssential: false, isIncome: false),
    // Revenus
    CategoryModel(id: 'cat_11', name: 'Salaire', icon: '💰', isEssential: false, isIncome: true),
    CategoryModel(id: 'cat_12', name: 'Freelance', icon: '💻', isEssential: false, isIncome: true),
    CategoryModel(id: 'cat_13', name: 'Investissement', icon: '📈', isEssential: false, isIncome: true),
    CategoryModel(id: 'cat_14', name: 'Autres revenus', icon: '🏦', isEssential: false, isIncome: true),
  ];
}