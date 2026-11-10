import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../domain/entities/chat_message.dart';
import '../controllers/ai_chat_controller.dart';
import '../../../auth/domain/contracts/auth_repository.dart';

/// Reusable AI Assistant Support Chat Screen (Shared by Customer, Partner, Admin, Super Admin)
/// Connects to GroqCloud via Python FastAPI proxy
class AiAssistantView extends StatefulWidget {
  const AiAssistantView({super.key});

  @override
  State<AiAssistantView> createState() => _AiAssistantViewState();
}

class _AiAssistantViewState extends State<AiAssistantView> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AiChatController _controller;

  @override
  void initState() {
    super.initState();
    // Register controller with DI if not already registered
    if (!Get.isRegistered<AiChatController>()) {
      _controller = Get.put(AiChatController(Get.find<AuthRepository>()));
    } else {
      _controller = Get.find<AiChatController>();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSend() {
    final query = _textController.text;
    if (query.trim().isNotEmpty) {
      _textController.clear();
      _controller.sendMessage(query);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.accentGold.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_rounded, color: AppColors.primaryContainer, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CARFIXZI Assistant', style: AppTypography.headlineSmall),
                Text('Grounded in Verified Public Records', style: AppTypography.bodySmall),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Messages List
            Expanded(
              child: Obx(() {
                final msgs = _controller.messages;
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: msgs.length,
                  itemBuilder: (context, index) {
                    final msg = msgs[index];
                    return _ChatBubble(message: msg);
                  },
                );
              }),
            ),

            // Loading Indicator
            Obx(() {
              if (!_controller.isLoading.value) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryContainer),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Consulting verified platform knowledge base...',
                      style: AppTypography.bodySmall.copyWith(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              );
            }),

            // Chat Input Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                border: const Border(
                  top: BorderSide(color: Color.fromRGBO(45, 49, 66, 0.08)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: AppTypography.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Ask about workshops, bookings or policies...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceContainerLow,
                      ),
                      onSubmitted: (_) => _onSend(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.send_rounded, size: 20),
                    onPressed: _onSend,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_rounded, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isUser
                        ? AppColors.primaryContainer
                        : (message.isError ? AppColors.warningContainer : AppColors.surfaceContainerLowest),
                    borderRadius: BorderRadius.circular(12),
                    border: isUser
                        ? null
                        : Border.all(color: const Color.fromRGBO(45, 49, 66, 0.08)),
                  ),
                  child: Text(
                    message.text,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isUser ? Colors.white : AppColors.onSurface,
                    ),
                  ),
                ),
                // Source citations
                if (message.sources != null && message.sources!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: message.sources!.map((s) {
                      return Chip(
                        label: Text(s.title),
                        backgroundColor: AppColors.surfaceContainerHigh,
                        labelStyle: AppTypography.labelSmall.copyWith(color: AppColors.primary),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                ],
                // Suggested in-app navigation routes
                if (message.suggestedActions != null && message.suggestedActions!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: message.suggestedActions!.map((a) {
                      return ActionChip(
                        label: Text(a.label),
                        backgroundColor: AppColors.tertiaryFixed,
                        labelStyle: AppTypography.labelSmall.copyWith(
                          color: AppColors.onTertiaryFixed,
                          fontWeight: FontWeight.w700,
                        ),
                        onPressed: () => Get.toNamed(a.route),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
