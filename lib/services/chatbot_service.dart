import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatbotService {
  final ChatOpenAI _llm;
  final ConversationBufferMemory _memory;
  late final ConversationChain _chain;

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

  Future<Map<String, dynamic>> fetchConsumptionData() async {
    try {
      final response = await http
          .get(Uri.parse('http://192.168.1.100:5000/consumption'))
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
      final systemMessage = '''
Tu es un assistant énergétique pour des ménages ivoiriens. Réponds en $language (Français, Nouchi, ou Anglais) avec un ton adapté au contexte local.
Données de consommation actuelles:
- Consommation journalière: ${consumptionData['daily_consumption']} kWh
- Consommation mensuelle: ${consumptionData['monthly_consumption']} kWh  
- Puissance actuelle: ${consumptionData['current_power']} W
- Seuil mensuel: ${consumptionData['threshold']} kWh
- Au-dessus du seuil: ${consumptionData['is_above_threshold'] ? 'Oui' : 'Non'}

Réponds à la question de l'utilisateur en te basant sur ces données.
''';

      await _memory.chatHistory.addChatMessage(
        ChatMessage.system(systemMessage),
      );

      final result = await _chain.invoke({
        'input': userInput,
      });

      return result['response'] as String;
    } catch (e) {
      return "Désolé, je rencontre un problème technique. Veuillez réessayer plus tard.";
    }
  }
}
