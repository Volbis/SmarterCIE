import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartmeter_app/models/user_profile.dart';
import '../firestore_service.dart';

class GoogleAuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: dotenv.env['GOOGLE_CLIENT_ID'],
  );

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Setters privés
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

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


/// Envoie un lien d'authentification à l'adresse e-mail
  Future<bool> sendSignInLinkToEmail(String email) async {
    try {
      setLoading(true);
      setError(null);

      // Configuration du lien d'authentification
      final actionCodeSettings = ActionCodeSettings(
        url: 'https://cieapp-2e9f7.firebaseapp.com/finishSignUp', // Remplacez par votre domaine Firebase
        handleCodeInApp: true,
        iOSBundleId: 'com.example.smartmeter_app', // Remplacez par votre bundle ID
        androidPackageName: 'com.example.smartmeter_app', // Remplacez par votre package name
        androidInstallApp: true,
        androidMinimumVersion: '21',
      );

      await _auth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: actionCodeSettings,
      );

      // Sauvegarder l'email localement pour finaliser la connexion
      await _saveEmailForSignIn(email);
      
      setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      setLoading(false);
      setError(_getErrorMessage(e.code));
      return false;
    } catch (e) {
      setLoading(false);
      setError('Erreur lors de l\'envoi du lien: $e');
      return false;
    }
  }

  /// Finalise la connexion avec le lien reçu par e-mail
  Future<bool> signInWithEmailLink(String emailLink, {String? email}) async {
    try {
      setLoading(true);
      setError(null);

      if (!_auth.isSignInWithEmailLink(emailLink)) {
        throw FirebaseAuthException(
          code: 'invalid-link',
          message: 'Le lien fourni n\'est pas valide pour l\'authentification.',
        );
      }

      email ??= await _getSavedEmailForSignIn();
      
      if (email == null || email.isEmpty) {
        throw FirebaseAuthException(
          code: 'missing-email',
          message: 'L\'adresse e-mail est requise pour finaliser la connexion.',
        );
      }

      final UserCredential result = await _auth.signInWithEmailLink(
        email: email,
        emailLink: emailLink,
      );

      _user = result.user;
      await _clearSavedEmailForSignIn();
      
      setLoading(false);
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      setLoading(false);
      setError(_getErrorMessage(e.code));
      return false;
    } catch (e) {
      setLoading(false);
      setError('Erreur lors de la connexion: $e');
      return false;
    }
  }

  /// Inscription avec email et mot de passe
  Future<UserCredential?> signUpWithEmailPassword(String email, String password, String name) async {
    try {
      setLoading(true);
      setError(null);

      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Mettre à jour le nom d'affichage
      await result.user?.updateDisplayName(name);
      
      setLoading(false);
      notifyListeners();
      return result;
    } on FirebaseAuthException catch (e) {
      setLoading(false);
      setError(_getErrorMessage(e.code));
      return null;
    } catch (e) {
      setLoading(false);
      setError('Erreur lors de l\'inscription: $e');
      return null;
    }
  }

  /// Connexion avec email et mot de passe
  Future<UserCredential?> signInWithEmailPassword(String email, String password) async {
    try {
      setLoading(true);
      setError(null);

      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      setLoading(false);
      notifyListeners();
      return result;
    } on FirebaseAuthException catch (e) {
      setLoading(false);
      setError(_getErrorMessage(e.code));
      return null;
    } catch (e) {
      setLoading(false);
      setError('Erreur lors de la connexion: $e');
      return null;
    }
  }

  bool isSignInWithEmailLink(String emailLink) {
    return _auth.isSignInWithEmailLink(emailLink);
  }

  // Méthodes utilitaires privées
  Future<void> _saveEmailForSignIn(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email_for_sign_in', email);
  }

  Future<String?> _getSavedEmailForSignIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email_for_sign_in');
  }

  Future<void> _clearSavedEmailForSignIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email_for_sign_in');
  }

  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'invalid-email':
        return 'L\'adresse e-mail n\'est pas valide.';
      case 'user-disabled':
        return 'Ce compte utilisateur a été désactivé.';
      case 'invalid-action-code':
        return 'Le lien d\'authentification n\'est pas valide ou a expiré.';
      case 'expired-action-code':
        return 'Le lien d\'authentification a expiré.';
      case 'weak-password':
        return 'Le mot de passe est trop faible.';
      case 'email-already-in-use':
        return 'Cette adresse e-mail est déjà utilisée.';
      case 'user-not-found':
        return 'Aucun utilisateur trouvé avec cette adresse e-mail.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'invalid-link':
        return 'Le lien fourni n\'est pas valide.';
      case 'missing-email':
        return 'L\'adresse e-mail est requise.';
      default:
        return 'Une erreur inattendue s\'est produite.';
    }
  }


// GESION DES NOUVEAUX UTILISATEURS

  // Utiliser le service Firestore
  Future<bool> isNewUser(String uid) async {
    return !(await FirestoreService.isProfileComplete(uid));
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    await FirestoreService.saveUserProfile(profile);
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    return await FirestoreService.getUserProfile(uid);
  }
  
  // Créer un profil minimal lors de l'inscription
  Future<void> createMinimalProfile(String uid, String name, String email) async {
    final profile = UserProfile(
      uid: uid,
      name: name,
      email: email,
      householdSize: '',
      averageConsumption: '',
      electricityProvider: '',
      tariffPlan: '',
      appliances: [],
      profileCompleted: false,
      createdAt: DateTime.now(),
      meterNumber: '', 
      monthlyBill: '', 
    );
    
    await FirestoreService.saveUserProfile(profile);
  }
  
  // MODE TEST - Méthode de debug
  Future<void> debugFirestoreConnection() async {
    print('🧪 DEBUG: Test de connexion Firestore...');
    final isConnected = await FirestoreService.testConnection();
    print('🧪 DEBUG: Firestore connecté: $isConnected');
    
    if (currentUser != null) {
      print('🧪 DEBUG: Utilisateur actuel: ${currentUser!.uid}');
      final profile = await getUserProfile(currentUser!.uid);
      print('🧪 DEBUG: Profil trouvé: ${profile?.toString()}');
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