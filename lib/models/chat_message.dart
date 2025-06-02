class UIChatMessage {  
  final String text;
  final bool isUser;
  final DateTime timestamp;
  
  UIChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}