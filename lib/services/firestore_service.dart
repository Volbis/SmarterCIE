import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final CollectionReference _usersCollection = _db.collection('users');

  // 🧪 MODE TEST - Logs détaillés
  static void _logOperation(String operation, String details) {
    print('🔥 Firestore $operation: $details');
  }

  // Vérifier si le profil est complet
  static Future<bool> isProfileComplete(String uid) async {
    try {
      _logOperation('READ', 'Vérification profil pour UID: $uid');
      
      final doc = await _usersCollection.doc(uid).get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        final isComplete = data?['profileCompleted'] ?? false;
        
        _logOperation('READ_SUCCESS', 'Profil trouvé - Complet: $isComplete');
        return isComplete;
      }
      
      _logOperation('READ_SUCCESS', 'Aucun profil trouvé - Considéré comme incomplet');
      return false;
      
    } catch (e) {
      _logOperation('READ_ERROR', 'Erreur: $e');
      return false;
    }
  }

  // Sauvegarder le profil utilisateur
  static Future<void> saveUserProfile(UserProfile profile) async {
    try {
      _logOperation('WRITE', 'Sauvegarde profil pour UID: ${profile.uid}');
      
      final data = profile.toMap();
      await _usersCollection.doc(profile.uid).set(data);
      
      _logOperation('WRITE_SUCCESS', 'Profil sauvegardé avec succès');
      
    } catch (e) {
      _logOperation('WRITE_ERROR', 'Erreur sauvegarde: $e');
      rethrow;
    }
  }

  // Récupérer le profil utilisateur
  static Future<UserProfile?> getUserProfile(String uid) async {
    try {
      _logOperation('READ', 'Récupération profil pour UID: $uid');
      
      final doc = await _usersCollection.doc(uid).get();
      
      if (doc.exists && doc.data() != null) {
        final profile = UserProfile.fromMap(doc.data() as Map<String, dynamic>);
        _logOperation('READ_SUCCESS', 'Profil récupéré: ${profile.name}');
        return profile;
      }
      
      _logOperation('READ_SUCCESS', 'Aucun profil trouvé');
      return null;
      
    } catch (e) {
      _logOperation('READ_ERROR', 'Erreur récupération: $e');
      return null;
    }
  }

  // 🧪 MODE TEST - Méthodes de debug
  static Future<void> clearAllTestData() async {
    try {
      _logOperation('DELETE', 'Suppression de toutes les données de test');
      
      final batch = _db.batch();
      final querySnapshot = await _usersCollection.get();
      
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      _logOperation('DELETE_SUCCESS', 'Toutes les données supprimées');
      
    } catch (e) {
      _logOperation('DELETE_ERROR', 'Erreur suppression: $e');
    }
  }

  // Vérifier la connexion Firestore
  static Future<bool> testConnection() async {
    try {
      _logOperation('TEST', 'Test de connexion Firestore');
      
      await _db.collection('test').doc('connection').set({
        'timestamp': FieldValue.serverTimestamp(),
        'test': true,
      });
      
      await _db.collection('test').doc('connection').delete();
      
      _logOperation('TEST_SUCCESS', 'Connexion Firestore OK');
      return true;
      
    } catch (e) {
      _logOperation('TEST_ERROR', 'Connexion Firestore échouée: $e');
      return false;
    }
  }

  // Lister tous les utilisateurs (MODE TEST uniquement)
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      _logOperation('READ_ALL', 'Récupération de tous les utilisateurs');
      
      final querySnapshot = await _usersCollection.get();
      final users = querySnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
      
      _logOperation('READ_ALL_SUCCESS', 'Nombre d\'utilisateurs: ${users.length}');
      return users;
      
    } catch (e) {
      _logOperation('READ_ALL_ERROR', 'Erreur: $e');
      return [];
    }
  }
}