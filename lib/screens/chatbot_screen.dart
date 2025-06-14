import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chatbot_service.dart';
import '../services/user_data_manage/user_data_manage.dart';
import '../models/chat_message.dart';
import 'package:flutter_markdown/flutter_markdown.dart';


class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ChatbotService _chatbotService;

  // 🎨 Couleurs orange soft et douces
  static const Color primaryOrange = Color(0xFFFF8A50);  // Orange principal doux
  static const Color lightOrange = Color(0xFFFFB380);    // Orange clair
  static const Color softOrange = Color(0xFFFFF4F0);     // Orange très doux pour les backgrounds

  @override
  void initState() {
    super.initState();
    _chatbotService = ChatbotService();
    
    // Message de bienvenue personnalisé
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userService = Provider.of<UserService>(context, listen: false);
      _chatbotService.addMessage(
        'Bonjour ${userService.displayName} ! 👋\n'
        'Votre consommation actuelle: ${userService.energie.toStringAsFixed(0)} kWh\n'
        'Comment puis-je vous aider aujourd\'hui ?',
        false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _chatbotService),
      ],
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primaryOrange, // 🎨 Orange doux
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.smart_toy_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SmartMeter IA',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Consumer<UserService>(
                    builder: (context, userService, child) {
                      return Text(
                        '${userService.currentPower.toStringAsFixed(0)} kW actuels',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            // Messages
            Expanded(
              child: Consumer<ChatbotService>(
                builder: (context, chatService, child) {
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    itemCount: chatService.messages.length + (chatService.isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == chatService.messages.length && chatService.isTyping) {
                        return _buildTypingIndicator();
                      }
                      final message = chatService.messages[index];
                      return _buildMessage(message);
                    },
                  );
                },
              ),
            ),
            
            // Suggestions rapides (seulement si pas de conversation)
            Consumer<ChatbotService>(
              builder: (context, chatService, child) {
                if (chatService.messages.length <= 1) {
                  return _buildQuickSuggestions();
                }
                return const SizedBox.shrink();
              },
            ),
            
            // Zone de saisie
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: softOrange,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.smart_toy_outlined,
                size: 16,
                color: primaryOrange,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser ? primaryOrange : Colors.white,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: message.isUser ? const Radius.circular(20) : const Radius.circular(4),
                  bottomRight: message.isUser ? const Radius.circular(4) : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: message.isUser 
                  ? Text(
                      message.content,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    )
                  : MarkdownBody(
                      data: message.content,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          height: 1.4,
                        ),
                        h1: const TextStyle(
                          color: Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        h2: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        h3: const TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        listBullet: const TextStyle(
                          color: primaryOrange,
                          fontSize: 15,
                        ),
                        code: TextStyle(
                          backgroundColor: Colors.grey.shade100,
                          color: Colors.red.shade700,
                          fontSize: 14,
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        blockquote: TextStyle(
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                        strong: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        em: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.black87,
                        ),
                      ),
                    ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 12),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: primaryOrange,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.person_outline,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: softOrange, // 🎨 Orange très doux
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.smart_toy_outlined,
              size: 16,
              color: primaryOrange, // 🎨 Icône orange
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20).copyWith(
                bottomLeft: const Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(primaryOrange), // 🎨 Orange pour le loader
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'En cours de réflexion...',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSuggestions() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suggestions',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Consumer<UserService>(
            builder: (context, userService, child) {
              return Wrap(
                spacing: 8,
                                runSpacing: 8,
                children: [
                  _buildSuggestionChip(
                    '📋 Plan de consommation',
                    'Plan de consommation intélligent et détaullé pour un seuil ${userService.seuille_conso} kWh vs actuel ${userService.currentPower.toStringAsFixed(0)} kW : écart chiffré, 3 actions immédiates, objectif 7 jours. Max 200 mots bullet points.',
                  ),
                  _buildSuggestionChip(
                    '💰 Conseils d\'économie',
                    'Top 5 actions pour réduire ma facture avec estimation d\'économies en euros. Réponse directe, max 120 mots.',
                  ),
                  _buildSuggestionChip(
                    '📊 Bilan énergétique',
                    'Bilan aujourd\'hui : consommation vs objectif, tendance, alerte si dépassement. Chiffres précis, max 100 mots.',
                  ),
                  _buildSuggestionChip(
                    '⚡ Optimisation',
                    '3 optimisations prioritaires pour ma consommation actuelle avec impact estimé en %. Conseils pratiques, max 130 mots.',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String label, String message) {
    return InkWell(
      onTap: () => _sendMessage(message),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: softOrange, // 🎨 Background orange très doux
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: lightOrange.withOpacity(0.3)), // 🎨 Bordure orange claire
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: primaryOrange, // 🎨 Texte orange
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Écrivez votre message...',
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                  onSubmitted: _sendMessage,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Consumer<ChatbotService>(
              builder: (context, chatService, child) {
                return GestureDetector(
                  onTap: chatService.isTyping ? null : () => _sendMessage(_controller.text),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: chatService.isTyping ? Colors.grey[400] : primaryOrange, // 🎨 Orange pour le bouton
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: chatService.isTyping
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    
     _controller.clear();
    final userService = Provider.of<UserService>(context, listen: false);
    _chatbotService.processMessage(text, userService);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
