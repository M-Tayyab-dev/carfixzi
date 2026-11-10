/// Chat Message model for GroqCloud AI Assistant
class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<SourceCitation>? sources;
  final List<SuggestedAction>? suggestedActions;
  final bool isError;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.sources,
    this.suggestedActions,
    this.isError = false,
  });
}

class SourceCitation {
  final String title;
  final String type; // 'faq', 'workshop', 'policy'
  final String? route;

  const SourceCitation({
    required this.title,
    required this.type,
    this.route,
  });
}

class SuggestedAction {
  final String label;
  final String route;

  const SuggestedAction({
    required this.label,
    required this.route,
  });
}
