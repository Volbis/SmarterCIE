import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import 'api_service.dart';

class ChatbotService extends ChangeNotifier {
  final ApiService apiService;
  List<ChatMessage> _messages = [];
  
  ChatbotService(this.apiService);
  
  List<ChatMessage> get messages => _messages;

  void addMessage(String text, bool isUser) {
    _messages.add(ChatMessage(
      text: text,
      isUser: isUser,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  Future<void> processMessage(String userMessage) async {
    addMessage(userMessage, true);
    
    // Simulate thinking
    await Future.delayed(Duration(milliseconds: 500));
    
    String response = _generateResponse(userMessage.toLowerCase());
    addMessage(response, false);
  }

  String _generateResponse(String message) {
    // Détection d'intention simple
    if (message.contains('consomm') || message.contains('combien')) {
      double power = apiService.getCurrentPower();
      double energy = apiService.getTodayEnergy();
      return 'Actuellement vous consommez ${power.toStringAsFixed(1)}W. '
             'Aujourd\'hui vous avez consommé ${energy.toStringAsFixed(2)} kWh. '
             '${_getConsumptionAdvice(power)}';
    }
    
    if (message.contains('dépasse') || message.contains('alerte') || message.contains('limite')) {
      double power = apiService.getCurrentPower();
      if (power > 1500) {
        return '⚠️ Oui, vous dépassez le seuil recommandé de 1500W. '
               'Votre consommation actuelle est de ${power.toStringAsFixed(1)}W. '
               'Je vous conseille d\'éteindre quelques appareils.';
      } else {
        return '✅ Non, votre consommation est normale (${power.toStringAsFixed(1)}W). '
               'Le seuil d\'alerte est fixé à 1500W.';
      }
    }
    
    if (message.contains('économ') || message.contains('astuce') || message.contains('conseil')) {
      return _getRandomTip();
    }
    
    if (message.contains('salut') || message.contains('bonjour') || message.contains('hello')) {
      return 'Bonjour ! 👋 Je suis votre assistant énergie. '
             'Je peux vous aider à suivre votre consommation électrique. '
             'Demandez-moi "Combien je consomme ?" ou "Donne-moi des astuces" !';
    }
    
    // Détection Nouchi
    if (message.contains('wassa') || message.contains('comment ça va')) {
      return 'Ça va bien merci ! 😊 Ton courant là, ça consomme '
             '${apiService.getCurrentPower().toStringAsFixed(1)}W maintenant même. '
             'Tu veux que je te donne conseil pour économiser ?';
    }
    
    if (message.contains('yako') || message.contains('merci')) {
      return 'De rien mon ami ! 😊 N\'hésite pas à me demander si tu veux savoir quelque chose sur ton courant.';
    }
    
    // Réponse par défaut
    return 'Je peux vous aider avec :\n'
           '• "Combien je consomme ?"\n'
           '• "Est-ce que je dépasse ?"\n'
           '• "Donne-moi des astuces"\n'
           '• "Comment économiser ?"';
  }

  String _getConsumptionAdvice(double power) {
    if (power > 2000) return '🔴 Consommation très élevée !';
    if (power > 1500) return '🟡 Consommation élevée, attention !';
    if (power > 1000) return '🟢 Consommation modérée.';
    return '🟢 Excellente consommation !';
  }

  String _getRandomTip() {
    final tips = [
      '💡 Remplacez les ampoules classiques par des LED : -80% de consommation !',
      '❄️ Dégivrez votre frigo régulièrement : il consommera 30% de moins.',
      '🌡️ 19°C dans les chambres et 20°C dans le salon suffisent.',
      '🔌 Une box internet consomme 200W/jour : éteignez-la la nuit !',
      '👔 Lavez à 30°C : votre linge sera propre et vous économiserez 60% d\'énergie.',
      '☀️ Profitez de la lumière naturelle : ouvrez vos rideaux !',
    ];
    return tips[DateTime.now().millisecond % tips.length];
  }
}