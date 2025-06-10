import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class GoogleAuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    
    // Utilisez votre Web Client ID depuis Firebase Console
    clientId: dotenv.env['GOOGLE_CLIENT_ID'],
  );

  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => currentUser != null;

  // Connexion avec Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Déclencher le flux d'authentification
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // L'utilisateur a annulé la connexion
        return null;
      }

      // Obtenir les détails d'authentification de la requête
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      // Créer un nouvel identifiant
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Une fois connecté, retourner UserCredential
      final UserCredential userCredential = 
          await _auth.signInWithCredential(credential);
      
      notifyListeners();
      return userCredential;
    } catch (e) {
      print('Erreur lors de la connexion Google: $e');
      rethrow;
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
      rethrow;
    }
  }

  // Écouter les changements d'état d'authentification
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}