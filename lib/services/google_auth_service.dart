import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  // Remplacez par votre Client ID Google
  static const String _clientId = 'VOTRE_CLIENT_ID.apps.googleusercontent.com';
  
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: _clientId,
    scopes: ['email', 'profile'],
  );

  // Connexion avec Google
  static Future<Map<String, String>?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      
      if (account == null) {
        return null; // L'utilisateur a annulé
      }

      return {
        'id': account.id,
        'name': account.displayName ?? '',
        'email': account.email,
        'photo': account.photoUrl ?? '',
      };
    } catch (e) {
      return null;
    }
  }

  // Déconnexion
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      // Ignorer l'erreur si l'utilisateur n'était pas connecté via Google
    }
  }
}
