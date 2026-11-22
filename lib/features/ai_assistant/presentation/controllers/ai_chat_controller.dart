import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/chat_message.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/constants/app_secrets.dart';
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
            'Hello! I am CARFIXZI AI Assistant powered by Groq. I can help answer questions regarding certified workshops in Sahiwal, vehicle troubleshooting, service booking guidelines, mobile wash procedures, and cash-on-service policies.\n\nHow can I help your vehicle today?',
        isUser: false,
        timestamp: DateTime.now(),
        suggestedActions: const [
          SuggestedAction(label: '📅 Book a Service Now', route: '/customer/booking'),
          SuggestedAction(label: '📍 Sahiwal Certified Workshops', route: '/customer/workshops'),
          SuggestedAction(label: '🧼 Doorstep Car Wash (Rs 800)', route: '/customer/wash-booking'),
          SuggestedAction(label: '🚨 Emergency Roadside Mechanic', route: '/customer/mobile-mechanic'),
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

    // Dynamically build smart actions based on user intent
    final lower = text.toLowerCase();
    final List<SuggestedAction> actions = [];
    if (lower.contains('wash') || lower.contains('clean') || lower.contains('detail')) {
      actions.add(const SuggestedAction(label: '🧼 Book Mobile Wash (Rs 800)', route: '/customer/wash-booking'));
    }
    if (lower.contains('emergency') || lower.contains('stuck') || lower.contains('puncture') || lower.contains('battery')) {
      actions.add(const SuggestedAction(label: '🚨 Call Emergency Mechanic', route: '/customer/mobile-mechanic'));
    }
    if (lower.contains('part') || lower.contains('filter') || lower.contains('pad') || lower.contains('oil') || lower.contains('price')) {
      actions.add(const SuggestedAction(label: '🛒 Browse Parts Catalog', route: '/customer/parts'));
    }
    // Always provide direct booking action
    actions.add(const SuggestedAction(label: '📅 Confirm & Book Service', route: '/customer/booking'));
    actions.add(const SuggestedAction(label: '📍 Select Workshop in Sahiwal', route: '/customer/workshops'));

    // 1. First attempt direct Groq Cloud API
    try {
      final groqResponse = await _queryGroq(text.trim());
      if (groqResponse != null && groqResponse.isNotEmpty) {
        messages.add(
          ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: groqResponse,
            isUser: false,
            timestamp: DateTime.now(),
            sources: const [
              SourceCitation(
                title: 'CARFIXZI Pilot Knowledge Base',
                type: 'ai_groq',
              ),
            ],
            suggestedActions: actions,
          ),
        );
        isLoading.value = false;
        return;
      }
    } catch (e) {
      debugPrint('Groq API direct query error: $e');
    }

    // 2. Fallback to Local Python FastAPI backend if available
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
          .timeout(const Duration(seconds: 8));

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
        return;
      }
    } catch (_) {}

    // 3. Fallback to offline platform knowledge base
    _handleFallback(
      'CARFIXZI Assistant is currently operating in offline mode. Here is verified help information.',
    );
    isLoading.value = false;
  }

  Future<String?> _queryGroq(String userPrompt) async {
    final uri = Uri.parse(AppSecrets.groqApiUrl);
    final response = await http
        .post(
          uri,
          headers: {
            'Authorization': 'Bearer ${AppSecrets.groqApiKey}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': AppSecrets.groqModel,
            'messages': [
              {
                'role': 'system',
                'content':
                    'You are CARFIXZI AI Assistant, the official intelligent automotive specialist for the CARFIXZI platform in Sahiwal, Pakistan. '
                    'You provide clear, accurate, concise, and helpful guidance for car and bike owners regarding: '
                    '1. Certified workshop repairs and diagnostics in Sahiwal (Apex GT Motorwerks, Royal Auto Detailing Hub, PakWheels Express Bay). '
                    '2. Doorstep mobile car and bike wash procedures and pricing (starting from Rs 800). '
                    '3. Emergency roadside mobile mechanic services (battery jumpstart Rs 1,200, tyre change Rs 1,500). '
                    '4. Genuine auto parts marketplace pricing in PKR (brake pads Rs 2,400-5,500, oil filters Rs 350-800, air filters Rs 450-1,200). '
                    '5. Transparent cash-on-delivery settlement policy (pay after service inspection). '
                    '6. Service booking guidance - help customers choose the right service and workshop. '
                    '7. Vehicle troubleshooting - diagnose common issues and recommend appropriate services. '
                    'When users ask about booking a service, provide workshop options with estimated pricing and ask if they want to proceed. '
                    'Be polite, friendly, and practical. Use formatting with bullet points where appropriate. Always mention prices in PKR.',
              },
              {
                'role': 'user',
                'content': userPrompt,
              },
            ],
            'temperature': 0.7,
            'max_tokens': 800,
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final choices = json['choices'] as List<dynamic>?;
      if (choices != null && choices.isNotEmpty) {
        final firstChoice = choices[0] as Map<String, dynamic>;
        final message = firstChoice['message'] as Map<String, dynamic>?;
        return message?['content'] as String?;
      }
    } else if (response.statusCode == 404 || response.statusCode == 400) {
      // Retry with fallback model if main model differs
      final fallbackResponse = await http
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer ${AppSecrets.groqApiKey}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': AppSecrets.groqFallbackModel,
              'messages': [
                {
                  'role': 'system',
                  'content': 'You are CARFIXZI AI Assistant for automotive services in Sahiwal, Pakistan.',
                },
                {
                  'role': 'user',
                  'content': userPrompt,
                },
              ],
              'temperature': 0.7,
            }),
          )
          .timeout(const Duration(seconds: 12));

      if (fallbackResponse.statusCode == 200) {
        final json = jsonDecode(utf8.decode(fallbackResponse.bodyBytes)) as Map<String, dynamic>;
        final choices = json['choices'] as List<dynamic>?;
        if (choices != null && choices.isNotEmpty) {
          final firstChoice = choices[0] as Map<String, dynamic>;
          final message = firstChoice['message'] as Map<String, dynamic>?;
          return message?['content'] as String?;
        }
      }
    }
    return null;
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

