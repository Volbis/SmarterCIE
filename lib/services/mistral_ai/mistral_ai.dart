import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

Future<String> getAdviceFromMistral(String userPrompt) async {
  try {
    final String? apiKey = dotenv.env['OPEN_ROUTER_API_KEY'];
    
    // 🔧 Debug de la clé API
    debugPrint('🔑 API Key présente: ${apiKey != null ? "OUI" : "NON"}');
    debugPrint('🔑 API Key longueur: ${apiKey?.length ?? 0}');
    
    if (apiKey == null || apiKey.isEmpty) {
      debugPrint('❌ ERREUR: Clé API manquante dans .env');
      throw Exception('OPEN_ROUTER_API_KEY non configurée dans .env');
    }
    
    const String model = 'mistralai/mistral-small-24b-instruct-2501:free';
    final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');
    
    debugPrint('🚀 Envoi de la requête à OpenRouter...');
    debugPrint('📝 Prompt: ${userPrompt.substring(0, 100)}...');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://smartmetter.com', 
        'X-Title': 'SmartMeterAI'
      },
      body: jsonEncode({
        "model": model,
        "messages": [
          {
            "role": "system", 
            "content": "Tu es un assistant énergétique expert. Donne des conseils personnalisés en fonction des données du compteur intelligent."
          },
          {
            "role": "user", 
            "content": userPrompt
          }
        ],
        "temperature": 0.7
      }),
    );

    debugPrint('📡 Status Code: ${response.statusCode}');
    debugPrint('📄 Response Headers: ${response.headers}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      debugPrint('✅ Réponse reçue: ${content.substring(0, 50)}...');
      return content;
    } else {
      debugPrint('❌ Erreur HTTP ${response.statusCode}');
      debugPrint('📄 Response Body: ${response.body}');
      
      // 🔧 Messages d'erreur plus spécifiques
      switch (response.statusCode) {
        case 401:
          throw Exception('Clé API invalide ou expirée');
        case 429:
          throw Exception('Limite de requêtes atteinte. Attendez un moment.');
        case 500:
          throw Exception('Erreur serveur OpenRouter. Réessayez plus tard.');
        default:
          throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    }
  } catch (e) {
    debugPrint('❌ Exception dans getAdviceFromMistral: $e');
    rethrow; // Relancer l'exception pour que le ChatbotService la gère
  }
}