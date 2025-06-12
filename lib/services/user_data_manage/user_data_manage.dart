import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  String? _error;
  double _currentPower = 0.0; 

  // Getters
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get currentPower => _currentPower;
    
  // Getter pour le nom d'affichage
  String get displayName {
    if (_userData == null) return 'Utilisateur';
    
    // Essayer différents champs selon votre structure de données
    return _userData!['prenom'] ?? 
           _userData!['nom'] ?? 
           _userData!['displayName'] ?? 
           _userData!['name'] ?? 
           'Utilisateur';
  }
  
  // Getter pour le nom complet
  String get fullName {
    if (_userData == null) return 'Utilisateur';
    
    String prenom = _userData!['prenom'] ?? '';
    String nom = _userData!['nom'] ?? '';
    
    if (prenom.isNotEmpty && nom.isNotEmpty) {
      return '$prenom $nom';
    } else if (prenom.isNotEmpty) {
      return prenom;
    } else if (nom.isNotEmpty) {
      return nom;
    }
    
    return _userData!['displayName'] ?? 
           _userData!['name'] ?? 
           'Utilisateur';
  }

  // Récupérer les données utilisateur depuis Firestore
  Future<void> fetchUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _setLoading(true);
    _error = null;

    try {
      // Récupérer depuis la collection 'users' avec l'UID comme document ID
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        _userData = doc.data() as Map<String, dynamic>?;
        _userData!['uid'] = user.uid; // Ajouter l'UID pour référence
      } else {
        // Si le document n'existe pas, créer un profil basique
        _userData = {
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName ?? 'Utilisateur',
          'createdAt': FieldValue.serverTimestamp(),
        };
        
        // Sauvegarder le profil basique
        await _firestore.collection('users').doc(user.uid).set(_userData!);
      }
    } catch (e) {
      _error = 'Erreur lors du chargement du profil: $e';
      debugPrint('Erreur UserService: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Mettre à jour les données utilisateur
  Future<void> updateUserData(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) return;

    _setLoading(true);
    _error = null;

    try {
      await _firestore.collection('users').doc(user.uid).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Mettre à jour localement
      _userData = {..._userData!, ...data};
    } catch (e) {
      _error = 'Erreur lors de la mise à jour: $e';
      debugPrint('Erreur update UserService: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Créer ou mettre à jour le profil utilisateur lors de l'inscription
  Future<void> createUserProfile({
    required String nom,
    required String prenom,
    String? telephone,
    Map<String, dynamic>? additionalData,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    _setLoading(true);
    _error = null;

    try {
      final userData = {
        'uid': user.uid,
        'email': user.email,
        'nom': nom,
        'prenom': prenom,
        'telephone': telephone,
        'displayName': '$prenom $nom',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        ...?additionalData,
      };

      await _firestore.collection('users').doc(user.uid).set(userData);
      _userData = userData;
    } catch (e) {
      _error = 'Erreur lors de la création du profil: $e';
      debugPrint('Erreur createUserProfile: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Méthode helper pour le loading
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Effacer les données (déconnexion)
  void clearUserData() {
    _userData = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  // Écouter les changements en temps réel (optionnel)
  Stream<DocumentSnapshot> getUserDataStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    
    return _firestore.collection('users').doc(user.uid).snapshots();
  }
}