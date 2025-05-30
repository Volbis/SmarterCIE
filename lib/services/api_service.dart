import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/energy_data.dart';

class ApiService extends ChangeNotifier {
  static const String baseUrl = 'http://192.168.1.100:5000'; // IP de votre API
  
  List<EnergyData> _readings = [];
  EnergyStats? _stats;
  bool _isLoading = false;

  List<EnergyData> get readings => _readings;
  EnergyStats? get stats => _stats;
  bool get isLoading => _isLoading;

  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Récupérer les lectures
      final readingsResponse = await http.get(Uri.parse('$baseUrl/data'));
      if (readingsResponse.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(readingsResponse.body);
        _readings = jsonData.map((item) => EnergyData.fromJson(item)).toList();
      }

      // Récupérer les statistiques
      final statsResponse = await http.get(Uri.parse('$baseUrl/stats'));
      if (statsResponse.statusCode == 200) {
        _stats = EnergyStats.fromJson(json.decode(statsResponse.body));
      }
    } catch (e) {
      print('Erreur API: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  double getCurrentPower() {
    return _readings.isNotEmpty ? _readings.first.power : 0.0;
  }

  double getTodayEnergy() {
    return _stats?.totalEnergy ?? 0.0;
  }
}