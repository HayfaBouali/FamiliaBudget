import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/google_auth_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  // ── Inscription ──
  Future<bool> register(String name, String email, String password) async {
    _setLoading(true);
    try {
      final response = await ApiService.register(name, email, password);

      if (response.containsKey('id')) {
        // Inscription réussie → connecter directement
        return await login(email, password);
      } else {
        _errorMessage = response['detail'] ?? 'Erreur lors de l\'inscription';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erreur de connexion au serveur';
      _setLoading(false);
      return false;
    }
  }

  // ── Connexion ──
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final response = await ApiService.login(email, password);

      if (response.containsKey('access_token')) {
        // Sauvegarder le token
        await ApiService.saveToken(response['access_token']);

        // Récupérer le profil
        final profile = await ApiService.getProfile();

        _user = UserModel(
          uid: profile['id'],
          name: profile['name'],
          email: profile['email'],
          createdAt: DateTime.parse(profile['created_at']),
        );

        _errorMessage = null;
        _setLoading(false);
        return true;
      } else {
        _errorMessage = response['detail'] ?? 'Email ou mot de passe incorrect';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erreur de connexion au serveur';
      _setLoading(false);
      return false;
    }
  }

  // ── Connexion avec Google ──
  Future<bool> loginWithGoogle() async {
    _setLoading(true);
    try {
      final googleUser = await GoogleAuthService.signInWithGoogle();
      
      if (googleUser == null) {
        _errorMessage = 'Connexion Google annulée';
        _setLoading(false);
        return false;
      }

      // Envoyer les infos Google au backend pour créer/connecter l'utilisateur
      final response = await ApiService.loginWithGoogle(
        googleUser['email']!,
        googleUser['name']!,
        googleUser['id']!,
      );

      if (response.containsKey('access_token')) {
        await ApiService.saveToken(response['access_token']);
        
        final profile = await ApiService.getProfile();
        
        _user = UserModel(
          uid: profile['id'],
          name: profile['name'],
          email: profile['email'],
          createdAt: DateTime.parse(profile['created_at']),
        );

        _errorMessage = null;
        _setLoading(false);
        return true;
      } else {
        _errorMessage = response['detail'] ?? 'Erreur de connexion Google';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erreur de connexion Google';
      _setLoading(false);
      return false;
    }
  }

  // ── Déconnexion ──
  Future<void> logout() async {
    try {
      await ApiService.deleteToken();
      await GoogleAuthService.signOut();
    } catch (e) {
      // Continuer même en cas d'erreur
    }
    _user = null;
    notifyListeners();
  }

  // ── Vérifier si déjà connecté ──
  Future<void> checkAuth() async {
    final token = await ApiService.getToken();
    if (token != null) {
      try {
        final profile = await ApiService.getProfile();
        _user = UserModel(
          uid: profile['id'],
          name: profile['name'],
          email: profile['email'],
          createdAt: DateTime.parse(profile['created_at']),
        );
        notifyListeners();
      } catch (e) {
        await ApiService.deleteToken();
      }
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}