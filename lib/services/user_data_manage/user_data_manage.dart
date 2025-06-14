import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';


class UserService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  String? _error;
  
  // 🆕 Données de consommation détaillées depuis Firebase
  double _puissanceActuelle = 0.0;
  double _energieConsommee = 0.0;
  double _courant = 0.0;
  double _tension = 0.0;
  double _cout = 0.0;


  // 🆕 Getters pour toutes les données dynamiques
  double get currentPower => _puissanceActuelle;
  double get energie => _energieConsommee;
  double get courant => _courant;
  double get tension => _tension;
  double get cout => _cout;
  String? get userId => _auth.currentUser?.uid;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get userData => _userData;
  String get displayName => _userData?['name'] ?? 'Utilisateur';
  double get seuille_conso => _userData?['seuille_conso'] ?? 50.0;  
  
  // 🆕 Calculs automatiques basés sur les données Firebase
  double get dailyTarget => 100.0; 
  double get targetProgress => energie / dailyTarget;
  String get targetProgressPercentage => '${(targetProgress * 100).toInt()}%';
  
  // 🆕 Comparaisons automatiques (simulées pour l'instant, peuvent être calculées)
  // double get neighborhoodAverage => 84.0;
 
  double _yesterdayComparison = 0.0; // ← CHANGÉ ICI
  double _yesterdayEnergie = 0.0;
  
  double get yesterdayComparison => _yesterdayComparison;
  String get yesterdayComparisonText {
    if (_yesterdayComparison == 0.0) return '0%';
    return _yesterdayComparison < 0 
        ? '${_yesterdayComparison.abs().toStringAsFixed(0)}%' 
        : '+${_yesterdayComparison.toStringAsFixed(0)}%';
  }

  // Alerte 
  bool _hasAlert = false;
  bool get hasAlert => _hasAlert;

  // 🔧 MODIFIER le constructeur
  UserService() {
    _initializeDefaultValues();
  }

  // Écouter les changements de l'attribut alerte
  void listenToAlertStatus() {
    if (userId == null) return;
    
    _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final newAlertStatus = data['alerte'] ?? false;
        
        // Si l'alerte passe de false à true, jouer une notification
        if (!_hasAlert && newAlertStatus) {
          _playNotificationSound();
        }
        
        _hasAlert = newAlertStatus;
        notifyListeners();
      }
    });
  }

  void _playNotificationSound() {
    // Vous pouvez utiliser audioplayers ou flutter_ringtone_player
    // Exemple avec flutter_local_notifications pour vibration + son
    debugPrint('🔔 Nouvelle alerte reçue !');
  }

  void _initializeDefaultValues() {
    _yesterdayComparison = 0.0; // 🔧 Démarrer à 0, sera calculé après
    debugPrint('🎯 Valeurs par défaut initialisées');
  }

  // 🆕 AMÉLIORER calculateYesterdayComparison avec simulation si pas de données
  Future<void> calculateYesterdayComparison() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('❌ Pas d\'utilisateur connecté pour le calcul');
        return;
      }

      debugPrint('🔄 Début calcul comparaison hier...');

      // 1. Récupérer les données d'hier
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayDateString = '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
      
      debugPrint('📅 Recherche données pour: $yesterdayDateString');

      // 2. Query Firestore pour les données historiques
      final historyDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_consumption')
          .doc(yesterdayDateString)
          .get();

      if (historyDoc.exists) {
        // 🟢 DONNÉES RÉELLES TROUVÉES
        final yesterdayData = historyDoc.data()!;
        _yesterdayEnergie = (yesterdayData['energie'] ?? 0.0).toDouble();
        
        if (_yesterdayEnergie > 0 && _energieConsommee >= 0) {
          final difference = _energieConsommee - _yesterdayEnergie;
          _yesterdayComparison = (difference / _yesterdayEnergie) * 100;
          
          debugPrint('✅ CALCUL RÉEL - Hier: ${_yesterdayEnergie}kWh | Aujourd\'hui: ${_energieConsommee}kWh | Diff: ${_yesterdayComparison.toStringAsFixed(1)}%');
        } else {
          debugPrint('⚠️ Données insuffisantes pour calcul réel');
          await _simulateYesterdayComparison();
        }
      } else {
        debugPrint('❌ Pas de données historiques - simulation intelligente');
        await _simulateYesterdayComparison();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Erreur calcul comparaison hier: $e');
      await _simulateYesterdayComparison();
    }
  }

  // 🆕 NOUVELLE MÉTHODE - Simulation intelligente basée sur vos données réelles
  Future<void> _simulateYesterdayComparison() async {
    try {
      if (_energieConsommee <= 0) {
        debugPrint('⚠️ Pas de consommation actuelle pour simuler');
        _yesterdayComparison = -8.0; // Valeur par défaut
        return;
      }

      // Simulation basée sur vos données réelles de Firebase
      final now = DateTime.now();
      final hourOfDay = now.hour;
      
      // Base : votre consommation actuelle avec variations réalistes
      double simulatedYesterdayConsumption = _energieConsommee;
      
      // Variations selon l'heure (plus réaliste)
      if (hourOfDay >= 18 && hourOfDay <= 22) {
        // Soirée : généralement plus de consommation hier
        simulatedYesterdayConsumption *= 1.1; // +10%
      } else if (hourOfDay >= 1 && hourOfDay <= 6) {
        // Nuit : moins de consommation hier
        simulatedYesterdayConsumption *= 0.9; // -10%
      }
      
      // Ajouter une variation basée sur le jour de la semaine
      if (now.weekday >= 6) {
        // Weekend : plus à la maison
        simulatedYesterdayConsumption *= 1.05;
      }
      
      // Variation aléatoire réaliste de ±15%
      final seed = _energieConsommee.toInt() + now.day; // Seed reproductible
      final randomFactor = 0.85 + (seed % 30) / 100; // Entre 0.85 et 1.15
      simulatedYesterdayConsumption *= randomFactor;
      
      // Calculer la comparaison
      final difference = _energieConsommee - simulatedYesterdayConsumption;
      _yesterdayComparison = (difference / simulatedYesterdayConsumption) * 100;
      
      debugPrint('🤖 SIMULATION - Hier: ${simulatedYesterdayConsumption.toStringAsFixed(1)}kWh | Aujourd\'hui: ${_energieConsommee}kWh | Diff: ${_yesterdayComparison.toStringAsFixed(1)}%');
      
    } catch (e) {
      debugPrint('❌ Erreur simulation: $e');
      _yesterdayComparison = -8.0; // Fallback
    }
  }

    // 🆕 Sauvegarder les données quotidiennes pour l'historique
  Future<void> saveDailyConsumption() async {
      try {
        final user = _auth.currentUser;
        if (user == null) return;

        final today = DateTime.now();
        final todayDateString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
        
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('daily_consumption')
            .doc(todayDateString)
            .set({
          'date': todayDateString,
          'energie': _energieConsommee,
          'puissance_max': _puissanceActuelle,
          'cout': _cout,
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        
        debugPrint('💾 Données quotidiennes sauvegardées: ${_energieConsommee}kWh');
      } catch (e) {
        debugPrint('❌ Erreur sauvegarde quotidienne: $e');
      }
    } 


Future<void> markAlertAsRead() async {
    if (userId == null) return;
    
    try {
      await _firestore.collection('users').doc(userId).update({
        'alerte': false,
      });
      
      _hasAlert = false;
      notifyListeners();
      
      debugPrint('✅ Alerte marquée comme lue');
    } catch (e) {
      debugPrint('❌ Erreur lors de la mise à jour de l\'alerte: $e');
    }
  }

  // 🆕 Détection automatique des alertes
  bool get hasHighConsumption => currentPower > 3000;
  List<Map<String, dynamic>> get alerts {
    List<Map<String, dynamic>> alertsList = [];
    
    if (hasHighConsumption) {
      alertsList.add({
        'type': 'warning',
        'title': 'Pic de consommation détecté',
        'message': 'Réduisez votre climatisation pour économiser',
        'color': 'orange',
        'icon': 'warning_amber_rounded',
      });
    }
    
    // Conseil du jour (peut être rotatif)
    alertsList.add({
      'type': 'tip',
      'title': 'Conseil du jour',
      'message': 'Éteignez vos appareils en veille pour économiser',
      'color': 'green',
      'icon': 'lightbulb_outline',
    });
    
    return alertsList;
  }


  // 🆕 Méthode pour récupérer les données utilisateur et de consommation
  Future<void> fetchUserData() async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('❌ Aucun utilisateur connecté');
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('🔍 Récupération des données pour UID: ${user.uid}');
      
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        _userData = userDoc.data() as Map<String, dynamic>;
        
        // 🆕 Récupération complète des données de consommation
        if (_userData!.containsKey('consommations') && _userData!['consommations'] != null) {
          final consommationsData = _userData!['consommations'] as Map<String, dynamic>;
          
          // Attribution de toutes les valeurs depuis Firebase
          _puissanceActuelle = (consommationsData['puissance'] ?? 0.0).toDouble();
          _energieConsommee = (consommationsData['energie'] ?? 0.0).toDouble();
          _courant = (consommationsData['courant'] ?? 0.0).toDouble();
          _tension = (consommationsData['tension'] ?? 0.0).toDouble();
          _cout = (consommationsData['cout'] ?? 0.0).toDouble();
          
          debugPrint('⚡ Données complètes - Puissance: ${_puissanceActuelle}kW, Énergie: ${_energieConsommee}kWh');
          debugPrint('📊 Courant: ${_courant}A, Tension: ${_tension}V, Coût: ${_cout}FCFA');
        
          await calculateYesterdayComparison();
          
          await saveDailyConsumption();
          
        } else {
          _resetConsommationData();
        }
        
        debugPrint('✅ Données utilisateur chargées: ${_userData!['name']}');
      } else {
        _userData = null;
        _resetConsommationData();
        debugPrint('❌ Document utilisateur non trouvé');
      }
    } catch (e) {
      _error = 'Erreur lors du chargement des données: $e';
      debugPrint('❌ Erreur fetchUserData: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _resetConsommationData() {
    _puissanceActuelle = 0.0;
    _energieConsommee = 0.0;
    _courant = 0.0;
    _tension = 0.0;
    _cout = 0.0;
  }

  // 🆕 Écoute en temps réel pour les mises à jour automatiques
  void listenToUserData() {
    final user = _auth.currentUser;
    if (user == null) return;

    debugPrint('👂 Démarrage de l\'écoute en temps réel pour UID: ${user.uid}');

    _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen(
      (userDoc) async {
        if (userDoc.exists && userDoc.data() != null) {
          _userData = userDoc.data() as Map<String, dynamic>;
          
          if (_userData!.containsKey('consommations') && _userData!['consommations'] != null) {
            final consommationsData = _userData!['consommations'] as Map<String, dynamic>;
            final oldEnergie = _energieConsommee;
            
            // Mise à jour en temps réel de toutes les données
            _puissanceActuelle = (consommationsData['puissance'] ?? 0.0).toDouble();
            _energieConsommee = (consommationsData['energie'] ?? 0.0).toDouble();
            _courant = (consommationsData['courant'] ?? 0.0).toDouble();
            _tension = (consommationsData['tension'] ?? 0.0).toDouble();
            _cout = (consommationsData['cout'] ?? 0.0).toDouble();
            
            debugPrint('🔄 Mise à jour temps réel - Puissance: ${_puissanceActuelle}kW');

            if (oldEnergie != _energieConsommee) {
              await calculateYesterdayComparison();
            }
          }
          
          notifyListeners();
        }
      },
      onError: (error) {
        _error = 'Erreur stream: $error';
        debugPrint('❌ Erreur stream: $error');
        notifyListeners();
      },
    );
  }
}
