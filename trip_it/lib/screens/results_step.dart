import 'package:flutter/material.dart';
import '../services/suggestion_service.dart';
import '../services/firestore_service.dart';
import 'package_detail_screen.dart';

// Data model for results
class _Result {
  final String country;
  final String place;
  final String image;
  final double rating;
  final double price;
  const _Result(this.country, this.place, this.image, this.rating, this.price);
}

// ------------------------------------------------------------------
// RESULT STEP WIDGET
// ------------------------------------------------------------------

class ResultsStep extends StatelessWidget {
  final String? budget;
  final String? weather;
  final String? style;
  final String? query;
  final VoidCallback onModifyPreferences;

  const ResultsStep({
    super.key,
    this.budget,
    this.weather,
    this.style,
    this.query,
    required this.onModifyPreferences,
  });

  List<Map<String, dynamic>> _getProfileBadges() {
    final List<Map<String, dynamic>> badges = [];

    if (budget != null) {
      String budgetName = 'Budget';
      if (budget == 'budget_mid') budgetName = 'Comfort';
      if (budget == 'budget_high') budgetName = 'Luxury';
      badges.add({'label': budgetName, 'icon': Icons.attach_money});
    }

    if (weather != null) {
      String weatherName = 'Mild & Pleasant';
      if (weather == 'warm') weatherName = 'Sunny & Warm';
      if (weather == 'cool') weatherName = 'Cool & Crisp';
      if (weather == 'mild') weatherName = 'Mild & Pleasant';
      badges.add({'label': weatherName, 'icon': Icons.wb_sunny});
    }

    if (style != null) {
      String styleName = style!;
      if (style == 'relax') styleName = 'Relaxation';
      if (style == 'cultural') styleName = 'Cultural';
      if (style == 'heritage') styleName = 'Heritage';
      badges.add({'label': styleName, 'icon': Icons.account_balance});
    }

    return badges.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final profileBadges = _getProfileBadges();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F8),
      body: Stack(
        children: [
          _ResultsHeader(profileBadges: profileBadges),
          Padding(
            padding: const EdgeInsets.only(top: 230),
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: FirestoreService.instance.streamPackages(),
              builder: (context, snapshot) {
                final docs = snapshot.data ?? [];
                final ranked = _rankAndFilter(docs, budget: budget, weather: weather, style: style, query: query);
                final displayedDocs = ranked.take(5).toList();
                if (displayedDocs.isEmpty) {
                  final data = SuggestionService.filter(
                    budget: budget,
                    weather: weather,
                    style: style,
                    query: query,
                  );
                  final results = data.map((d) {
                    final country = (d['country'] ?? '') as String;
                    final name = (d['name'] ?? 'Unknown') as String;
                    final image = (d['image'] ?? '') as String;
                    final rating = d['rating'] is num ? (d['rating'] as num).toDouble() : 0.0;
                    final price = d['price'] is num ? (d['price'] as num).toDouble() : 0.0;
                    return _Result(country, name, image, rating, price);
                  }).toList();
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      ...results.take(3).map((r) => GestureDetector(
                            onTap: () {
                              final gallery = SuggestionService.galleryFor(r.place, r.image);
                              final base = r.price > 0 ? r.price : 1800.0;
                              final destination = {
                                'name': r.place,
                                'country': r.country,
                                'description': r.place,
                                'image': r.image,
                                'rating': r.rating,
                                'packages': [
                                  {
                                    'title': '${r.place} - Standard',
                                    'price': base,
                                    'days': 5,
                                    'people': '2-4 people',
                                    'includes': ['Hotel', 'Meals', 'Transport'],
                                  },
                                  {
                                    'title': '${r.place} - Premium',
                                    'price': (base * 1.2).roundToDouble(),
                                    'days': 7,
                                    'people': '2-4 people',
                                    'includes': ['Hotel', 'Meals', 'Transport'],
                                  },
                                ],
                                'gallery': gallery,
                              };
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PackageDetailScreen(destination: destination),
                                ),
                              );
                            },
                            child: _ResultTile(r: r),
                          )),
                      const SizedBox(height: 12),
                      _WhyBox(budget: budget, weather: weather, style: style),
                      const SizedBox(height: 120),
                    ],
                  );
                }
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    ...displayedDocs.map((m) {
                      final country = (m['destination'] as String?) ?? (m['country'] as String?) ?? '';
                      final name = (m['title'] as String?) ?? 'Unknown';
                      final image = (m['image'] as String?) ?? '';
                      final rating = ((m['rating'] as num?)?.toDouble()) ?? 0.0;
                      final price = ((m['price'] as num?)?.toDouble()) ?? 0.0;
                      final r = _Result(country, name, image, rating, price);
                      return GestureDetector(
                        onTap: () {
                          final gallery = (m['gallery'] as List?)?.cast<String>() ??
                              SuggestionService.galleryFor(r.place, r.image);
                          final base = r.price > 0 ? r.price : 1800.0;
                          final destination = {
                            'name': r.place,
                            'country': r.country,
                            'description': r.place,
                            'image': r.image,
                            'rating': r.rating,
                            'packages': [
                              {
                                'title': '${r.place} - Standard',
                                'price': base,
                                'days': 5,
                                'people': '2-4 people',
                                'includes': ['Hotel', 'Meals', 'Transport'],
                              },
                              {
                                'title': '${r.place} - Premium',
                                'price': (base * 1.2).roundToDouble(),
                                'days': 7,
                                'people': '2-4 people',
                                'includes': ['Hotel', 'Meals', 'Transport'],
                              },
                            ],
                            'gallery': gallery,
                          };
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PackageDetailScreen(destination: destination),
                            ),
                          );
                        },
                        child: _ResultTile(r: r),
                      );
                    }),
                    const SizedBox(height: 12),
                    _WhyBox(budget: budget, weather: weather, style: style),
                    const SizedBox(height: 120),
                  ],
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onModifyPreferences,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A8CFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 5,
                    shadowColor: Colors.blue.shade800,
                  ),
                  child: const Text(
                    'Modify Preferences',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Sub-widgets ---

class _ResultsHeader extends StatelessWidget {
  final List<Map<String, dynamic>> profileBadges;
  const _ResultsHeader({required this.profileBadges});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
        gradient: const LinearGradient(
          colors: [Color(0xFF00C6FF), Color(0xFF5F50F2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 40.0, bottom: 20),
            child: Column(
              children: [
                Text(
                  'Perfect for You!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Based on your preferences',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.star, color: Colors.yellow, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Your Travel Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: profileBadges.map((badge) {
                    return Column(
                      children: [
                        Icon(
                          badge['icon'] as IconData,
                          color: Colors.white,
                          size: 30,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          badge['label'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

List<Map<String, dynamic>> _rankAndFilter(List<Map<String, dynamic>> docs, {String? budget, String? weather, String? style, String? query}) {
  final qTokens = (query ?? '').trim().toLowerCase().split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
  final b = budget?.toLowerCase();
  final w = weather?.toLowerCase();
  final s = style?.toLowerCase();

  final scored = <MapEntry<Map<String, dynamic>, double>>[];
  for (final d in docs) {
    final tags = ((d['tags'] ?? []) as List).map((t) => (t as String).toLowerCase()).toSet();
    final price = ((d['price'] as num?)?.toDouble()) ?? 0.0;
    double score = 0.0;
    final rating = ((d['rating'] as num?)?.toDouble()) ?? 0.0;
    score += (rating / 5.0);

    if (w != null && w.isNotEmpty && tags.contains(w)) score += 1.5;
    if (s != null && s.isNotEmpty && tags.contains(s)) score += 1.5;
    if (b != null && b.isNotEmpty) {
      if (tags.contains(b)) score += 1.2;
      if (b == 'budget_low' && price <= 1200) score += 0.8;
      if (b == 'budget_mid' && price > 1200 && price <= 3000) score += 0.8;
      if (b == 'budget_high' && price > 3000) score += 0.8;
    }

    if (qTokens.isNotEmpty) {
      final name = ((d['title'] as String?) ?? '').toLowerCase();
      final country = ((d['destination'] as String?) ?? (d['country'] as String?) ?? '').toLowerCase();
      final text = '$name $country ${tags.join(' ')}';
      var matches = 0;
      for (final t in qTokens) {
        if (text.contains(t)) matches++;
      }
      score += (matches / qTokens.length) * 1.2;
      if (name.startsWith(qTokens.first)) score += 0.6;
    }

    scored.add(MapEntry(d, score));
  }

  scored.sort((a, b) {
    final s1 = b.value.compareTo(a.value);
    if (s1 != 0) return s1;
    final rA = ((a.key['rating'] as num?) ?? 0).toDouble();
    final rB = ((b.key['rating'] as num?) ?? 0).toDouble();
    return rB.compareTo(rA);
  });

  return scored.map((e) => e.key).toList();
}

class _ResultTile extends StatelessWidget {
  final _Result r;
  const _ResultTile({required this.r});

  @override
  Widget build(BuildContext context) {
    final matchText = r.rating >= 4.5 ? 'Perfect match' : 'Great choice';
    final matchColor = r.rating >= 4.5 ? Colors.green : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  r.image,
                  width: 110,
                  height: 110,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 110,
                    height: 110,
                    color: Colors.grey.shade300,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: matchColor,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        matchText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      r.country,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          r.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  r.place,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'An incredible destination matching your unique travel style.',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      'Starting From',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '\$${r.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4A8CFF),
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WhyBox extends StatelessWidget {
  final String? budget;
  final String? weather;
  final String? style;
  const _WhyBox({this.budget, this.weather, this.style});

  String _getReasonText(String type, String? selection) {
    if (selection == null) return '';
    switch (type) {
      case 'weather':
        final weatherPref = selection == 'mild'
            ? 'mild & pleasant'
            : (selection == 'warm' ? 'sunny & warm' : 'cool & crisp');
        return 'Perfect climate match for your $weatherPref preference';
      case 'style':
        final stylePref = selection;
        return 'Excellent options for $stylePref experiences';
      case 'budget':
        final budgetPref = selection == 'budget_low'
            ? 'budget traveler'
            : (selection == 'budget_mid'
                  ? 'comfort seeker'
                  : 'luxury explorer');
        return 'Fits within your $budgetPref range';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final reasons = [
      _getReasonText('weather', weather),
      _getReasonText('style', style),
      _getReasonText('budget', budget),
    ].where((s) => s.isNotEmpty).toList();

    if (reasons.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Why we recommend these destinations:',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 12),
          ...reasons.map((text) => _Bullet(text: text)),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet({required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2.0),
            child: Icon(
              Icons.check_box_outlined,
              color: Colors.green,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
