import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../shared/widgets/carfixzi_button.dart';
import '../../../../app/routes/app_routes.dart';

/// D02-D04: Onboarding Flow with 3-Slide Educational Carousel
class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'step': 'Step 1 of 3',
      'badge': 'VERIFIED WORKSHOPS',
      'title': 'Find Trusted Care\nNear You',
      'description':
          'Discover vetted automotive workshops and mobile detailing partners in your city with verified pricing and reviews.',
      'icon': Icons.location_on_rounded,
      'services': ['Repairs', 'Detailing', 'Mobile Wash'],
    },
    {
      'step': 'Step 2 of 3',
      'badge': 'RELIABLE MILESTONES',
      'title': 'Track Booking\nStatus & Progress',
      'description':
          'Follow service milestones from check-in to completion. Review quotes before work begins and confirm when satisfied.',
      'icon': Icons.track_changes_rounded,
      'services': ['Transparent Quotes', 'Milestone Updates', 'Verified Handover'],
    },
    {
      'step': 'Step 3 of 3',
      'badge': 'READY TO ROLL',
      'title': 'Drive with Total\nConfidence',
      'description':
          'Book certified workshop appointments, schedule mobile mechanic inspections, and order spare parts with cash-on-service.',
      'icon': Icons.verified_user_rounded,
      'services': ['Spare Parts', 'Cash on Service', 'AI Assistant Support'],
    },
  ];

  void _onNext() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Get.offNamed(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          _slides[_currentPage]['step'] as String,
          style: AppTypography.labelMedium.copyWith(color: AppColors.outline),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.offNamed(AppRoutes.login),
            child: Text(
              'Skip',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Illustration Container
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.1),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              slide['icon'] as IconData,
                              size: 64,
                              color: AppColors.primaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),

                        // Pill Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.tertiaryFixed,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text(
                            slide['badge'] as String,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.onTertiaryFixed,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Title
                        Text(
                          slide['title'] as String,
                          textAlign: TextAlign.center,
                          style: AppTypography.displayLarge.copyWith(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Description
                        Text(
                          slide['description'] as String,
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Feature Tag Row
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: (slide['services'] as List<String>).map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(9999),
                                border: Border.all(
                                  color: const Color.fromRGBO(45, 49, 66, 0.12),
                                ),
                              ),
                              child: Text(
                                tag,
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.darkSlate,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Pagination Dots & Navigation Controls
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Dot Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (idx) {
                      final isActive = idx == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.accentGold : AppColors.surfaceDim,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Primary Button
                  CarfixziButton(
                    text: _currentPage == 2 ? 'Get Started' : 'Continue',
                    onPressed: _onNext,
                    variant: _currentPage == 2 ? ButtonVariant.primary : ButtonVariant.secondary,
                  ),
                  const SizedBox(height: 12),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTypography.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () => Get.offNamed(AppRoutes.login),
                        child: Text(
                          'Log In',
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.primaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
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

