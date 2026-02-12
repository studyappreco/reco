import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _index = 0;

  // ✅ Start Your Journey -> go to Create Account page
  void _finishOnboarding() {
    context.go('/register');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _skip() {
    _controller.animateToPage(
      3,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <_OnboardData>[
        _OnboardData(
          title: "Feeling a bit lost\nin your studies?",
          subtitle:
          "You're not alone. Let's build a personalized plan to help you stay on track and reach your goals.",
          imageAsset: "assets/images/onboarding_1.png",
          imageHeight: 1000,

          ctaText: null,
        ),
        _OnboardData(
          title: "Not sure what\ncomes next?",
          subtitle:
          "RECO helps you understand your academic path and make confident decisions about your future semesters.",
          imageAsset: "assets/images/onboarding_2.png",
          imageHeight: 800,
          footerLine: "Build by students for students!",
          ctaText: null,
        ),
      _OnboardData(
        title: "Everything about your\nstudies, in one place!",
        subtitle:
        "Track your GPA, follow your progress, plan semesters, and explore courses — all clearly organized.",
        imageAsset: "assets/images/onboarding_3.png",
        imageHeight: 600,
        footerLine: "Review · Explore · Choose · Optimize",
        ctaText: null,
      ),
      _OnboardData(
        title: "Study smarter.\nGraduate with confidence.",
        subtitle:
        "With personalized insights and smart recommendations, RECO helps you stay on track and move forward faster.",
        imageAsset: "assets/images/onboarding_4.png",
        imageHeight: 1500,
        ctaText: "Start Your Journey!",
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: PageView.builder(
          controller: _controller,
          itemCount: pages.length,
          onPageChanged: (i) => setState(() => _index = i),
          itemBuilder: (context, i) {
            final p = pages[i];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // Skip button (hidden on last page)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (i != pages.length - 1)
                        TextButton(
                          onPressed: _skip,
                          child: const Text(
                            "Skip",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                    ],
                  ),

                  // Flexible image/circle stack for all pages
                  Flexible(
                    flex: 5,
                    child: Center(
                      child: Builder(
                        builder: (context) {
                          final isLast = i == pages.length - 1;
                          final double outerCircle = isLast ? 320 : 240;
                          final double innerCircle = isLast ? 230 : 170;
                          final double imageHeight = p.imageHeight ?? (isLast ? 260 : 200);
                          return Padding(
                            padding: EdgeInsets.only(top: isLast ? 24 : 0),
                            child: Image.asset(
                              p.imageAsset,
                              fit: BoxFit.contain,
                              height: imageHeight,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Dots
                  _DotsIndicator(count: pages.length, index: _index),

                  const SizedBox(height: 18),

                  // Title
                  Text(
                    p.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subtitle
                  Text(
                    p.subtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                      height: 1.35,
                    ),
                  ),

                  // ✅ Page 1 special bottom row (icons like reference)
                  if (i == 0) ...[
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        _FeatureIcon(label: "Set Goals", icon: Icons.adjust),
                        _FeatureIcon(label: "Track Progress", icon: Icons.show_chart),
                        _FeatureIcon(label: "Stay Organized", icon: Icons.book_outlined),
                      ],
                    ),
                  ] else if (p.footerLine != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F6FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        p.footerLine!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],

                  const Spacer(),

                  // CTA button only on last page
                  if (p.ctaText != null)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _finishOnboarding,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1677FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          p.ctaText!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OnboardData {
  final String title;
  final String subtitle;
  final String imageAsset;
  final double? imageHeight;
  final String? footerLine;
  final String? ctaText;

  _OnboardData({
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    this.imageHeight,
    this.footerLine,
    this.ctaText,
  });
}

class _DotsIndicator extends StatelessWidget {
  final int count;
  final int index;

  const _DotsIndicator({required this.count, required this.index});

  static const List<Color> activeColors = [
    Color(0xFFFFA76D), // orange (1st)
    Color(0xFFFFD600), // yellow (2nd)
    Color(0xFF4DD88A), // green (3rd)
    Color(0xFF4DA3FF), // blue (4th)
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 6,
          width: active ? 18 : 6,
          decoration: BoxDecoration(
            color: active ? activeColors[i % activeColors.length] : const Color(0xFFD6D9E0),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}

class _FeatureIcon extends StatelessWidget {
  final String label;
  final IconData icon;

  const _FeatureIcon({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFFFE7DB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFFFF7A45)),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}