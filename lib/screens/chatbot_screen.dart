import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chatbot_service.dart';
import '../services/api_service.dart';
import '../widgets/chat_bubble.dart';
import '../models/chat_message.dart'; // Ajoutez cet import


class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ChatbotService _chatbotService;

  @override
  void initState() {
    super.initState();
    _chatbotService = ChatbotService();
    
    // Message de bienvenue
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatbotService.addMessage(
        'Bonjour ! 👋 Je suis votre assistant énergie intelligent. '
        'Je parle Français, Anglais et Nouchi ! '
        'Que voulez-vous savoir sur votre consommation ?',
        false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _chatbotService,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white,
                child: Text('🤖', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Assistant IA', style: TextStyle(fontSize: 16)),
                  Text('En ligne', style: TextStyle(fontSize: 12, color: Colors.green[100])),
                ],
              ),
            ],
          ),
          backgroundColor: Colors.green,
        ),
        body: Column(
          children: [
            // Boutons suggestions rapides
            Container(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.all(8),
                children: [
                  _buildQuickButton('💡 Ma conso ?', '💡 Combien je consomme maintenant ?'),
                  _buildQuickButton('⚠️ Je dépasse ?', '⚠️ Est-ce que je dépasse le seuil ?'),
                  _buildQuickButton('💰 Astuces éco', '💰 Donne-moi des astuces pour économiser'),
                  _buildQuickButton('📊 Bilan du jour', '📊 Quel est mon bilan énergétique du jour ?'),
                ],
              ),
            ),
            
            Divider(height: 1),
            
            // Messages
            Expanded(
              child: Consumer<ChatbotService>(
                builder: (context, chatService, child) {
                  return ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(16),
                    itemCount: chatService.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatService.messages[index];
                      return ChatBubble(message: message);
                    },
                  );
                },
              ),
            ),
            
            // Zone de saisie
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5)],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Tapez votre message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  SizedBox(width: 8),
                  FloatingActionButton(
                    onPressed: () => _sendMessage(_controller.text),
                    child: Icon(Icons.send),
                    mini: true,
                    backgroundColor: Colors.green,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickButton(String label, String message) {
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: ElevatedButton(
        onPressed: () => _sendMessage(message),
        child: Text(label, style: TextStyle(fontSize: 12)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[100],
          foregroundColor: Colors.green[800],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    
    _controller.clear();
    _chatbotService.processMessage(text);
    
    // Auto-scroll vers le bas
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
