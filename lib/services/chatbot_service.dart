import 'package:flutter/foundation.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/chat_message.dart'; // Importer la classe UIChatMessage

class ChatbotService extends ChangeNotifier {
  final ChatOpenAI _llm;
  final ConversationBufferMemory _memory;
  late final ConversationChain _chain;
  
  // Liste des messages pour l'interface utilisateur
  final List<UIChatMessage> _messages = []; 
  List<UIChatMessage> get messages => _messages; 
  
  // Indicateur d'état pour l'interface utilisateur
  bool _isTyping = false;
  bool get isTyping => _isTyping;
  
  // Langue courante (peut être modifiée par l'utilisateur)
  String _currentLanguage = 'Français';
  String get currentLanguage => _currentLanguage;
  set currentLanguage(String language) {
    _currentLanguage = language;
    notifyListeners();
  }

  ChatbotService()
      : _llm = ChatOpenAI(
          apiKey: dotenv.env['OPENAI_API_KEY'] ?? '',
          defaultOptions: const ChatOpenAIOptions(
            model: 'gpt-4o-mini',
            temperature: 0.7,
          ),
        ),
        _memory = ConversationBufferMemory(returnMessages: true) {
    _chain = ConversationChain(
      llm: _llm,
      memory: _memory,
    );
  }

  // Méthode pour ajouter un message à la liste des messages
  void addMessage(String text, bool isUser) {
    _messages.add(UIChatMessage(
      text: text,
      isUser: isUser,
    ));
    notifyListeners();
  }

  // Méthode pour traiter un message de l'utilisateur
  Future<void> processMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    // Ajouter le message de l'utilisateur
    addMessage(text, true);
    
    // Indiquer que l'assistant est en train de générer une réponse
    _isTyping = true;
    notifyListeners();
    
    try {
      // Obtenir une réponse du modèle
      final response = await getResponse(text, _currentLanguage);
      
      // Ajouter la réponse de l'assistant
      addMessage(response, false);
    } catch (e) {
      // En cas d'erreur, afficher un message d'erreur
      addMessage("Désolé, je rencontre un problème technique. Veuillez réessayer plus tard.", false);
    } finally {
      // Indiquer que l'assistant a terminé de générer une réponse
      _isTyping = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> fetchConsumptionData() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.100:5000/consumption'))
          .timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return _getMockConsumptionData();
      }
    } catch (e) {
      return _getMockConsumptionData();
    }
  }

  Map<String, dynamic> _getMockConsumptionData() {
    return {
      'daily_consumption': 3.5,
      'monthly_consumption': 105.2,
      'current_power': 420.7,
      'threshold': 150.0,
      'is_above_threshold': false,
    };
  }

  Future<String> getResponse(String userInput, String language) async {
    try {
      final consumptionData = await fetchConsumptionData();
      final contextualInput = '''
Contexte: Tu es un assistant énergétique pour des ménages ivoiriens. Réponds en $language (Français, Nouchi, ou Anglais) avec un ton adapté au contexte local.

Données de consommation actuelles:
- Consommation journalière: ${consumptionData['daily_consumption']} kWh
- Consommation mensuelle: ${consumptionData['monthly_consumption']} kWh  
- Puissance actuelle: ${consumptionData['current_power']} W
- Seuil mensuel: ${consumptionData['threshold']} kWh
- Au-dessus du seuil: ${consumptionData['is_above_threshold'] ? 'Oui' : 'Non'}

Question de l'utilisateur: $userInput
''';

      final result = await _chain.invoke({
        'input': contextualInput,
      });

      return result['response'] as String;
    } catch (e) {
      return "Désolé, je rencontre un problème technique. Veuillez réessayer plus tard.";
    }
  }
}