import 'package:trip_it/screens/world_map_widget.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/suggestion_service.dart'; // <--- Using your provided service
import '../currency_controller.dart';
import 'plan_trip_flow.dart';
import 'package_detail_screen.dart';
import 'cart_page.dart' show CartPage;
import 'explore_screen.dart'; // <-- added import

// Data model for a place used in the popular list (Updated properties)
class _Place {
  final String title;
  final String image;
  final double rating;
  final double price;
  const _Place(this.title, this.image, this.rating, this.price);
}

// Data model for the recommendation cards (Added optional description)
class _Recommendation {
  final String title;
  final String subtitle;
  final String image;
  final double rating;
  final double price;
  final String? description;
  const _Recommendation(
    this.title,
    this.subtitle,
    this.image,
    this.rating,
    this.price, {
    this.description,
  });
}

// Small pill button used in the two-action row (Updated for image's gradient)
class _ActionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradientColors;
  final VoidCallback? onTap;
  const _ActionPill({
    required this.icon,
    required this.label,
    required this.gradientColors,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Destination List Item to precisely match the AI Recommendation card design.
class _AiRecommendationCard extends StatelessWidget {
  final _Recommendation recommendation;
  final String currencySymbol;
  final VoidCallback onTap;

  const _AiRecommendationCard({
    required this.recommendation,
    required this.currencySymbol,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                recommendation.image,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey.shade300,
                  child: const Center(child: Icon(Icons.error)),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        recommendation.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        recommendation.rating.toStringAsFixed(1),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.place,
                        size: 14,
                        color: theme.iconTheme.color?.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        recommendation.subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (recommendation.description != null)
                    Text(
                      recommendation.description!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 12.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  Text(
                    'Starting From',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: theme.textTheme.bodySmall?.color?.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                  Text(
                    Currency.formatINR(
                      recommendation.price,
                      code: currencyController.value,
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Color(0xFF2F6BFF),
                    ),
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

// Internal minimal search field with suggestions
class _HomeSearchField extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onSelected;
  const _HomeSearchField({required this.onSelected});

  @override
  State<_HomeSearchField> createState() => _HomeSearchFieldState();
}

class _HomeSearchFieldState extends State<_HomeSearchField> {
  final TextEditingController _ctl = TextEditingController();
  List<Map<String, dynamic>> _suggestions = [];

  void _onChanged(String v) {
    setState(() {
      _suggestions = SuggestionService.search(v, limit: 6);
    });
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      children: [
        TextField(
          controller: _ctl,
          onChanged: _onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor:
                theme.inputDecorationTheme.fillColor ??
                (theme.brightness == Brightness.dark
                    ? const Color(0xFF1E1E1E)
                    : cs.surface),
            hintText: 'Where would you like to go?',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
        if (_suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 6),
              ],
            ),
            child: ListView.separated(
              separatorBuilder: (_, __) => const Divider(height: 1),
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, i) {
                final item = _suggestions[i];
                return ListTile(
                  leading: const Icon(Icons.place_outlined),
                  title: Text(
                    item['name'] as String,
                    style: theme.textTheme.bodyLarge,
                  ),
                  subtitle: Text(
                    item['country'] as String,
                    style: theme.textTheme.bodyMedium,
                  ),
                  onTap: () {
                    _ctl.clear();
                    setState(() => _suggestions = []);
                    widget.onSelected(item);
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}

class _CurrencyPill extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  const _CurrencyPill({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: Colors.white,
          icon: const Icon(Icons.expand_more, color: Colors.black54),
          style: const TextStyle(color: Colors.black),
          onChanged: (v) => v == null ? null : onChanged(v),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_currencyIcon(e), size: 18),
                      const SizedBox(width: 6),
                      Text(e),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  IconData _currencyIcon(String c) {
    switch (c) {
      case 'INR':
        return Icons.currency_rupee;
      case 'USD':
        return Icons.attach_money;
      case 'GBP':
        return Icons.currency_pound;
      case 'EUR':
        return Icons.euro;
      default:
        return Icons.payments;
    }
  }
}

// --- Main HomeScreen Implementation ---

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const route = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currency = 'INR';
  final List<String> _currencies = const ['INR', 'USD', 'GBP', 'EUR'];
  final PageController _bannerCtrl = PageController(viewportFraction: 0.9);
  int _bannerIndex = 0;
  String? _displayName;

  final List<String> _banners = const [
    //slideshow imges
    'assets/images/slide3.jpg',
    'assets/images/slide2.jpg',
    'assets/images/slide1.png',
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    String? name = user.displayName;
    if (name == null || name.isEmpty) {
      final data = await FirestoreService.instance.getUserProfile(user.uid);
      name = data?['displayName'] as String?;
    }
    setState(() {
      _displayName = name ?? user.email ?? 'User';
    });
  }

  // ...existing code...
  // Updated popular list to match the image content (Bali, Paris, Tokyo, London)
  final List<_Place> _popular = const [
    _Place('Bali, Indonesia', 'assets/images/bali.jpg', 4.7, 1560),
    _Place('Tokyo, Japan', 'assets/images/japan.jpg', 4.5, 1890),
    _Place('London, UK', 'assets/images/london.jpg', 4.2, 1100),
  ]; // Vertical AI Recommendations (The list items at the bottom of the screen)
  final List<_Recommendation> _aiRecsVertical = const [
    _Recommendation(
      'Hawa Mahal,Jaipur',
      'India',
      'assets/images/hawa.jpg',
      4.7,
      1560,
      description:
          'the land of kings, grand forts, golden deserts, and vibrant traditions.a royal blend of majestic palaces, colorful culture, and timeless heritage....',
    ),
    _Recommendation(
      'Santorini',
      'Greece',
      'assets/images/santorini.png',
      4.8,
      2390,
      description:
          'Stunning sunsets and white-washed buildings overlooking the Aegean Sea.',
    ),
    _Recommendation(
      'Giza Plateau',
      'Egypt',
      'assets/images/giza.png',
      4.3,
      3200,
      description:
          'Land of pyramids, pharaohs, and the Nile, a journey through ancient history.',
    ),
  ];

  // Horizontal AI Recommendations (Small pills above the vertical list)
  final List<_Place> _aiRecsHorizontal = const [
    _Place('Kerala, India', 'assets/images/kerala.png', 4.6, 1300),
    _Place('Kashi, India', 'assets/images/kashi.png', 4.6, 2100),
    _Place('Tokyo, Japan', 'assets/images/tokyo.jpg', 4.5, 1890),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: currencyController,
      builder: (context, code, _) {
        final symbol = Currency.symbol(code);
        final theme = Theme.of(context);
        final cs = theme.colorScheme;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // --- Header Section (Gradient Background) ---
                SliverToBoxAdapter(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2F6BFF), Color(0xFF723BFF)],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(28),
                        bottomRight: Radius.circular(28),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.person, color: Colors.black54),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Welcome, ${_displayName ?? 'Guest'}',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            // ...existing code...
                            // Small logo (changed to open ExploreScreen on tap)
                            InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ExploreScreen(),
                                ),
                              ),
                              child: SizedBox(
                                width: 34,
                                height: 34,
                                child: Image.asset(
                                  'assets/images/splash_logo.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.travel_explore,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // ...existing code...                        const SizedBox(width: 8),
                            ValueListenableBuilder<String>(
                              valueListenable: currencyController,
                              builder: (context, code, _) {
                                return _CurrencyPill(
                                  value: code,
                                  items: _currencies,
                                  onChanged: (v) => setCurrencyPersisted(v),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Search with suggestions
                        _HomeSearchField(
                          onSelected: (item) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PlanTripFlow(
                                  initialQuery: item['name'] as String,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // --- Banner Carousel ---
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 220, // Adjusted height
                    child: PageView.builder(
                      controller: _bannerCtrl,
                      onPageChanged: (i) => setState(() => _bannerIndex = i),
                      itemCount: _banners.length,
                      itemBuilder: (_, i) => Padding(
                        padding: EdgeInsets.only(
                          left: i == 0 ? 16 : 8,
                          right: i == _banners.length - 1 ? 16 : 8,
                          top: 16,
                          bottom: 8,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                _banners[i],
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    Container(color: Colors.grey.shade300),
                              ),
                              // Gradient overlay for better text contrast
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black45.withValues(alpha: 0.6),
                                      Colors.black87,
                                    ],
                                    stops: const [0.0, 0.7, 1.0],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              Positioned(
                                left: 16,
                                bottom: 30,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Explore the world',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Best destinations for ${i + 3} days trip',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Banner Indicators
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _banners.length,
                        (i) => Container(
                          width: i == _bannerIndex ? 14 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: i == _bannerIndex
                                ? Colors.black87
                                : Colors.black26,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // --- Two Action Pills ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _ActionPill(
                            icon: Icons.route,
                            label: 'Plan Trip',
                            // Gradient matching the image's blue tone
                            gradientColors: const [
                              Color(0xFF86B9FF),
                              Color(0xFF2F6BFF),
                            ],
                            onTap: () => Navigator.pushNamed(
                              context,
                              PlanTripFlow.route,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionPill(
                            icon: Icons.star_border_rounded,
                            label: 'Top picks',
                            // Gradient matching the image's green tone
                            gradientColors: const [
                              Color(0xFF98E8AB),
                              Color(0xFF67B543),
                            ],
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CartPage(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // --- Popular Destinations Header ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                    child: Row(
                      children: [
                        const Text(
                          'Popular Destinations',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'See all',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // --- Popular Destinations Scroller ---
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 180,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (_, i) {
                        final p = _popular[i];
                        return InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _openPackageDetail(
                            context,
                            _buildArgsFromName(p.title, p.image),
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  p.image,
                                  width: 150,
                                  height: 180,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 150,
                                    height: 180,
                                    color: Colors.grey.shade300,
                                    child: const Center(
                                      child: Icon(Icons.error),
                                    ),
                                  ),
                                ),
                              ),
                              // Overlay for readability
                              Container(
                                width: 150,
                                height: 180,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black54,
                                    ],
                                    stops: [0.5, 1.0],
                                  ),
                                ),
                              ),
                              // Rating Pill (Top Right)
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black45,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        size: 14,
                                        color: Colors.amber,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        p.rating.toStringAsFixed(1),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Title and Price (Bottom Left)
                              Positioned(
                                left: 10,
                                bottom: 10,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '#${i + 1}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 130,
                                      child: Text(
                                        p.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      Currency.formatINR(p.price),
                                      style: const TextStyle(
                                        color: Color(0xFFC8E6FF),
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemCount: _popular.length,
                    ),
                  ),
                ),

                // --- AI Recommendations Header ---
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'AI Recommendations',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),

                // --- AI Recommendations Horizontal Scroller (Small Pills) ---
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 120,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (_, i) {
                        final p = _aiRecsHorizontal[i];
                        return InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {},
                          child: Container(
                            width: 100,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: cs.surface,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(
                                    p.image,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  p.title.split(',').first,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  p.title.split(',').last,
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemCount: _aiRecsHorizontal.length,
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: FirestoreService.instance.streamPackages(),
                    builder: (context, snapshot) {
                      final docs = snapshot.data ?? [];
                      final list = docs.isNotEmpty
                          ? docs
                          : _aiRecsVertical
                                .map(
                                  (r) => {
                                    'title': r.title,
                                    'destination': r.subtitle,
                                    'image': r.image,
                                    'rating': r.rating,
                                    'price': r.price,
                                    'description': r.description,
                                  },
                                )
                                .toList();
                      return ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: list.length,
                        itemBuilder: (context, i) {
                          final m = list[i];
                          final rec = _Recommendation(
                            (m['title'] as String?) ?? 'Package',
                            (m['destination'] as String?) ??
                                (m['country'] as String?) ??
                                '',
                            (m['image'] as String?) ?? '',
                            ((m['rating'] as num?)?.toDouble()) ?? 4.5,
                            ((m['price'] as num?)?.toDouble()) ?? 0.0,
                            description: m['description'] as String?,
                          );
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                            child: _AiRecommendationCard(
                              recommendation: rec,
                              currencySymbol: symbol,
                              onTap: () => _openPackageDetail(context, {
                                'title': rec.title,
                                'country': rec.subtitle,
                                'image': rec.image,
                                'rating': rec.rating,
                                'price': rec.price,
                                'tags': const <String>[],
                                'gallery': (m['gallery'] as List?)
                                    ?.cast<String>(),
                              }),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            ),
          ),
          // BottomNavigation is provided by MainTabs; remove duplicate here.
          bottomNavigationBar: const SizedBox.shrink(),
        );
      },
    );
  }

  void _openPackageDetail(BuildContext context, Map<String, dynamic> args) {
    final gallery =
        (args['gallery'] as List?)?.cast<String>() ??
        SuggestionService.galleryFor(
          args['title'] as String,
          args['image'] as String? ?? '',
        );

    final destination = {
      'name': args['title'] as String,
      'country': args['country'] as String? ?? '',
      'description':
          'Explore ${args['title']}. A curated package for travelers.',
      'image': args['image'] as String? ?? '',
      'rating': (args['rating'] ?? 4.5) as double,
      'packages': [
        {
          'title': '${args['title']} - Standard',
          'price': (args['price'] ?? 0) as num,
          'days': 5,
          'people': '2-4 people',
          'includes': ['Hotel', 'Meals', 'Transport'],
        },
        {
          'title': '${args['title']} - Premium',
          'price': ((args['price'] ?? 0) as num) + 500,
          'days': 7,
          'people': '2-4 people',
          'includes': ['Hotel', 'Meals', 'Transport', 'Tours'],
        },
      ],
      'gallery': gallery,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PackageDetailScreen(destination: destination),
      ),
    );
  }

  String _currencySymbol(String c) {
    switch (c) {
      case 'INR':
        return '₹';
      case 'USD':
        return '\$';
      case 'GBP':
        return '£';
      case 'EUR':
        return '€';
      default:
        return '';
    }
  }

  // Updated argument builder to handle the new _Place data structure
  Map<String, dynamic> _buildArgsFromName(String title, String fallbackImage) {
    // 1. Try to find a match in the richer SuggestionService data
    final match = SuggestionService.destinations.firstWhere(
      (d) =>
          (d['name'] as String).toLowerCase().startsWith(title.toLowerCase()),
      orElse: () => {},
    );
    if (match.isNotEmpty) {
      return {
        'title': match['name'],
        'country': match['country'] ?? '',
        'image': match['image'] ?? fallbackImage,
        'rating': (match['rating'] ?? 4.5) as num,
        'price': (match['price'] ?? 0) as num,
        'tags': (match['tags'] as List?)?.cast<String>() ?? const <String>[],
      };
    }

    // 2. Fallback to the local _popular list data
    final popularMatch = _popular.firstWhere(
      (p) => p.title.toLowerCase().startsWith(title.toLowerCase()),
      orElse: () => _Place(title, fallbackImage, 4.5, 0.0),
    );

    return {
      'title': popularMatch.title,
      'country': popularMatch.title.split(', ').last,
      'image': popularMatch.image,
      'rating': popularMatch.rating,
      'price': popularMatch.price,
      'tags': const <String>[],
    };
  }
}
