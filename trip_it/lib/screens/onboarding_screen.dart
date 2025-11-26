import 'package:flutter/material.dart';
import '../theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  static const route = '/onboarding';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  void _next() {
    if (_index < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _skip() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // prevent any white flash behind pages
      body: SafeArea(
        child: Stack(
          children: [
            // Pages
            PageView(
              controller: _controller,
              onPageChanged: (i) => setState(() => _index = i),
              children: const [
                _OnboardPage(
                  gradient: Gradients.onboardingBlue,
                  icon: Icons.place,
                  imagePath: 'assets/images/onboarding_1.png',
                  title: 'Discover Amazing Places',
                  description:
                      'Explore handpicked destinations around the world with personalized recommendations just for you.',
                ),
                _OnboardPage(
                  gradient: Gradients.onboardingGreen,
                  icon: Icons.event_available,
                  imagePath: 'assets/images/onboarding_2.png',
                  title: 'Plan Your Perfect Trip',
                  description:
                      'Get customized travel suggestions based on your budget, weather preferences, and travel style.',
                ),
                _OnboardPage(
                  gradient: Gradients.onboardingOrange,
                  icon: Icons.favorite,
                  imagePath: 'assets/images/onboarding_3.png',
                  title: 'Book With Confidence',
                  description:
                      'Save your favorite destinations and book amazing travel packages with just a few taps.',
                ),
              ],
            ),
            // Skip button on top-right
            Positioned(
              right: 12,
              top: 8,
              child: TextButton(
                onPressed: _skip,
                child: const Text(
                  'Skip',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
            // Bottom controls
            Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 4),
                    _ProgressPill(activeIndex: _index, count: 3),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: _next,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: const BoxDecoration(
                            color: Colors.white, // white button background
                            borderRadius: BorderRadius.all(Radius.circular(32)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _index < 2 ? 'Next' : 'Get Started',
                            style: const TextStyle(
                              color: Colors.black, // black text on white button
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final Gradient gradient;
  final IconData icon;
  final String imagePath;
  final String title;
  final String description;
  const _OnboardPage({
    required this.gradient,
    required this.icon,
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    // theme variable removed as it's unused in this widget
    // Responsive image card height: ~24% of screen height, clamped between 200 and 300
    final double cardHeight = (() {
      final h = MediaQuery.of(context).size.height * 0.24;
      if (h < 200) return 200.0;
      if (h > 300) return 300.0;
      return h.toDouble();
    })();
    return Container(
      decoration: BoxDecoration(gradient: gradient as LinearGradient),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Small circular icon near top
          Container(
            width: 70, // increased size
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 36, // increased icon size
            ),
          ),
          const SizedBox(height: 24),
          // Image card
          Container(
            width: double.infinity,
            height: cardHeight,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (_, __, ___) => Center(
                child: Icon(
                  Icons.image_not_supported,
                  color: Colors.grey.shade700,
                  size: 48,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Text card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

// _Dot removed because it's no longer referenced. The small progress dots
// are handled by _SmallDot and _ProgressPill already.

class _ProgressPill extends StatelessWidget {
  final int activeIndex;
  final int count;
  const _ProgressPill({required this.activeIndex, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          count,
          (i) => _SmallDot(active: i == activeIndex),
        ),
      ),
    );
  }
}

class _SmallDot extends StatelessWidget {
  final bool active;
  const _SmallDot({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? Colors.black : Colors.black26,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
