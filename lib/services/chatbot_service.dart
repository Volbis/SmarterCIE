import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../models/chat_message.dart';
import '../services/mistral_ai/mistral_ai.dart'; // 🆕 Import du service Mistral
import '../services/user_data_manage/user_data_manage.dart'; // 🆕 Import UserService

class ChatbotService extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  
  List<ChatMessage> get messages => _messages;
  bool get isTyping => _isTyping;

  void addMessage(String content, bool isUser) {
    _messages.add(ChatMessage(
      content: content,
      isUser: isUser,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }


Future<void> processMessage(String userMessage, UserService userService) async {
  // Ajouter le message utilisateur
  addMessage(userMessage, true);
  
  // Afficher l'indicateur de frappe
  _isTyping = true;
  notifyListeners();

  try {
    // 🆕 Créer un prompt enrichi avec les données Firestore
    final String enrichedPrompt = _buildEnrichedPrompt(userMessage, userService);
    
    debugPrint('🤖 Envoi du message à Mistral...');
    
    // Appeler Mistral avec le prompt enrichi
    final String response = await getAdviceFromMistral(enrichedPrompt);
    
    // Ajouter la réponse IA
    addMessage(response, false);
    debugPrint('✅ Réponse ajoutée avec succès');
    
  } catch (e) {
    debugPrint('❌ Erreur ChatbotService: $e');
    
    // 🔧 Messages d'erreur plus spécifiques
    String errorMessage = 'Désolé, je rencontre un problème technique.';
    
    if (e.toString().contains('API')) {
      errorMessage = '🔑 Problème de configuration API. Contactez le support.';
    } else if (e.toString().contains('429')) {
      errorMessage = '⏳ Trop de requêtes. Attendez quelques secondes et réessayez.';
    } else if (e.toString().contains('réseau') || e.toString().contains('network')) {
      errorMessage = '📶 Problème de connexion. Vérifiez votre internet.';
    }
    
    addMessage(errorMessage, false);
  } finally {
    _isTyping = false;
    notifyListeners();
  }
}
  // 🆕 Construction du prompt avec données utilisateur
  String _buildEnrichedPrompt(String userMessage, UserService userService) {
    final String contextualPrompt = '''
CONTEXTE UTILISATEUR :
- Nom: ${userService.displayName}
- Puissance actuelle: ${userService.currentPower} kW
- Énergie consommée aujourd'hui: ${userService.energie} kWh
- Courant: ${userService.courant} A
- Tension: ${userService.tension} V
- Coût actuel: ${userService.cout} FCFA
- Objectif quotidien: ${userService.dailyTarget} kWh
- Progression: ${userService.targetProgressPercentage}

INSTRUCTION :
Tu es un assistant énergétique expert en Côte d'Ivoire. 
Réponds en français ou en nouchi selon le style de l'utilisateur.
Base tes conseils sur les données réelles ci-dessus.
Sois concret, personnalisé et bienveillant.

QUESTION DE L'UTILISATEUR :
${userMessage}
''';

    return contextualPrompt;
  }

  // 🆕 Réponses rapides intelligentes
  Future<void> processQuickResponse(String quickMessage, UserService userService) async {
    switch (quickMessage) {
      case '💡 Combien je consomme maintenant ?':
        final response = _generateConsumptionResponse(userService);
        addMessage(response, false);
        break;
        
      case '⚠️ Est-ce que je dépasse le seuil ?':
        final response = _generateThresholdResponse(userService);
        addMessage(response, false);
        break;
        
      case '💰 Donne-moi des astuces pour économiser':
        await processMessage('Donne-moi 3 conseils personnalisés pour réduire ma consommation', userService);
        break;
        
      case '📊 Quel est mon bilan énergétique du jour ?':
        final response = _generateDailySummary(userService);
        addMessage(response, false);
        break;
        
      default:
        await processMessage(quickMessage, userService);
    }
  }

  String _generateConsumptionResponse(UserService userService) {
    if (userService.currentPower > 3000) {
      return '⚡ Vous consommez actuellement ${userService.currentPower.toStringAsFixed(0)} kW. '
             'C\'est assez élevé ! Vérifiez vos gros appareils (clim, chauffe-eau...).';
    } else {
      return '💚 Votre consommation actuelle est de ${userService.currentPower.toStringAsFixed(0)} kW. '
             'C\'est dans la normale !';
    }
  }

  String _generateThresholdResponse(UserService userService) {
    if (userService.targetProgress > 1.0) {
      return '🔴 Attention ! Vous avez dépassé votre objectif de ${userService.dailyTarget} kWh. '
             'Vous êtes à ${userService.targetProgressPercentage}. Réduisez votre consommation !';
    } else {
      return '✅ Vous êtes à ${userService.targetProgressPercentage} de votre objectif quotidien. '
             'Continuez ainsi !';
    }
  }

  String _generateDailySummary(UserService userService) {
    return '''📊 **Bilan du jour**
• Consommé: ${userService.energie.toStringAsFixed(1)} kWh
• Objectif: ${userService.dailyTarget} kWh  
• Progression: ${userService.targetProgressPercentage}
• Coût actuel: ${userService.cout.toStringAsFixed(0)} FCFA

${userService.targetProgress > 0.8 ? '⚠️ Attention à ne pas dépasser !' : '💚 Vous maîtrisez bien !'}''';
  }
}