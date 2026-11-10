import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/chat_message.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../auth/domain/contracts/auth_repository.dart';

/// GetxController managing the GroqCloud grounded AI chat assistant
class AiChatController extends GetxController {
  final AuthRepository _authRepository;

  AiChatController(this._authRepository);

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorBanner = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Welcome message with suggested pilot questions
    messages.add(
      ChatMessage(
        id: 'welcome_01',
        text:
            'Hello! I am CARFIXZI Assistant. I can help answer questions regarding certified workshops in Sahiwal, service booking guidelines, mobile wash procedures, and cash-on-service policies.\n\nHow can I help your vehicle today?',
        isUser: false,
        timestamp: DateTime.now(),
        suggestedActions: const [
          SuggestedAction(label: 'Find Sahiwal Workshops', route: '/customer/workshops'),
          SuggestedAction(label: 'How Cash Payment Works', route: '/faq/cash-policy'),
          SuggestedAction(label: 'Mobile Wash Coverage', route: '/customer/wash-booking'),
        ],
      ),
    );
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );
    messages.add(userMsg);
    isLoading.value = true;
    errorBanner.value = '';

    try {
      final token = await _authRepository.getIdToken();
      final baseUrl = kIsWeb ? ApiEndpoints.webBaseApiUrl : ApiEndpoints.baseApiUrl;
      final uri = Uri.parse('$baseUrl${ApiEndpoints.aiChat}');

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'message': text.trim(),
              'locale': 'en',
            }),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final answer = data['answer'] as String? ?? 'I could not find an answer in verified records.';
        final rawSources = data['sources'] as List<dynamic>? ?? [];
        final sources = rawSources.map((s) {
          final m = s as Map<String, dynamic>;
          return SourceCitation(
            title: m['title'] ?? 'Verified Record',
            type: m['type'] ?? 'faq',
            route: m['route'],
          );
        }).toList();

        messages.add(
          ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: answer,
            isUser: false,
            timestamp: DateTime.now(),
            sources: sources.isNotEmpty ? sources : null,
          ),
        );
      } else if (response.statusCode == 429) {
        _handleFallback(
          'The AI assistant has reached its free-tier rate limit. Below are verified FAQs from the platform knowledge base.',
        );
      } else {
        _handleFallback(
          'Connecting to the local Python AI proxy at $baseUrl. Ensure FastAPI is running locally (python -m uvicorn app.main:app). Here is verified help information.',
        );
      }
    } catch (e) {
      _handleFallback(
        'Offline / Demo Mode: The Python FastAPI local service is currently not connected. Here are standard verified policies.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _handleFallback(String notice) {
    messages.add(
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text:
            '$notice\n\n📌 Quick Answers from Verified Pilot Policy:\n• Workshops: All workshops must be approved by regional Admin before appearing.\n• Payment: Pay in cash directly to the technician or workshop upon satisfactory completion.\n• Disputes: Open an in-app dispute within 48 hours for admin review.',
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
        suggestedActions: const [
          SuggestedAction(label: 'Browse Verified Workshops', route: '/customer/workshops'),
          SuggestedAction(label: 'Book Service', route: '/customer/booking'),
        ],
      ),
    );
  }
}
