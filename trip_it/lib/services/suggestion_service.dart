// ...existing code...
class SuggestionService {
  // In-memory catalog of destinations
  static final List<Map<String, dynamic>> destinations = [
    {
      'name': 'Hawa Mahal, Jaipur',
      'country': 'India',
      'tags': ['heritage', 'warm', 'cultural', 'budget_mid'],
      'price': 1300.0,
      'image': 'assets/images/rjbg.png',
      'rating': 4.7,
      'description': 'The land of kings, grand forts and vibrant traditions.',
      'gallery': ['assets/images/rj1.png', 'assets/images/rj2.png'],
    },
    {
      'name': 'Oia, Santorini',
      'country': 'Greece',
      'tags': ['relax', 'views', 'mild', 'budget_mid'],
      'price': 1860.0,
      'image': 'assets/images/santorini.png',
      'rating': 4.1,
      'description':
          'Stunning sunsets and white-washed buildings overlooking the Aegean Sea.',
      'gallery': [
        'assets/images/santorini_gal_1.jpg',
        'assets/images/santorini_gal_2.jpg',
      ],
    },
    {
      'name': 'Ubud Monkey Forest, Bali',
      'country': 'Indonesia',
      'tags': ['nature', 'cultural', 'warm', 'budget_mid'],
      'price': 1560.0,
      'image': 'assets/images/bali.jpg',
      'rating': 4.5,
      'description':
          "Lush tropical forests, spiritual retreats, and ancient temples.",
      'gallery': [
        'assets/images/bali_gal_1.jpg',
        'assets/images/bali_gal_2.jpg',
      ],
    },
    {
      'name': 'Giza Pyramids, Cairo',
      'country': 'Egypt',
      'tags': ['heritage', 'warm', 'budget_high'],
      'price': 3200.0,
      'image': 'assets/images/giza.png',
      'rating': 4.3,
      'description': 'Land of pyramids, pharaohs, and the Nile.',
      'gallery': [
        'assets/images/giza_gal_1.jpg',
        'assets/images/giza_gal_2.jpg',
      ],
    },
    {
      'name': 'Colosseum, Rome',
      'country': 'Italy',
      'tags': ['heritage', 'mild', 'cultural', 'budget_mid'],
      'price': 2100.0,
      'image': 'assets/images/rome.jpg',
      'rating': 4.6,
      'description': 'A city built on history, art, and delicious cuisine.',
      'gallery': [
        'assets/images/rome_gal_1.jpg',
        'assets/images/rome_gal_2.jpg',
      ],
    },
    {
      'name': 'Tokyo, Japan',
      'country': 'Japan',
      'tags': ['cultural', 'mild', 'views', 'budget_high'],
      'price': 3800.0,
      'image': 'assets/images/tokyo.jpg',
      'rating': 4.9,
      'description':
          'Ancient temples, tranquil bamboo forests, and geisha districts.',
      'gallery': [
        'assets/images/tokyo_gal_1.jpg',
        'assets/images/tokyo_gal_2.jpg',
      ],
    },
    {
      'name': 'Phu Quoc, Vietnam',
      'country': 'Vietnam',
      'tags': ['relax', 'warm', 'budget_low'],
      'price': 900.0,
      'image': 'assets/images/dest_vietnam.jpg',
      'rating': 4.2,
      'description': 'Idyllic beaches, clear waters, and affordable luxury.',
      'gallery': [
        'assets/images/dest_vietnam_gal_1.jpg',
        'assets/images/dest_vietnam_gal_2.jpg',
      ],
    },
    {
      'name': 'Kerala Backwaters, India',
      'country': 'India',
      'tags': ['relax', 'nature', 'warm', 'budget_mid'],
      'price': 1400.0,
      'image': 'assets/images/dest_bali.jpg',
      'rating': 4.4,
      'description': 'Lush backwaters, houseboats and tropical spice gardens.',
      'gallery': [
        'assets/images/bali_gal_1.jpg',
        'assets/images/bali_gal_2.jpg',
      ],
    },
    {
      'name': 'Kashi (Varanasi), India',
      'country': 'India',
      'tags': ['heritage', 'cultural', 'warm'],
      'price': 1100.0,
      'image': 'assets/images/hawa.jpg',
      'rating': 4.2,
      'description':
          'Ancient city on the Ganges, spiritual rituals and historic ghats.',
      'gallery': ['assets/images/rj1.png', 'assets/images/rj2.png'],
    },
    {
      'name': 'London, UK',
      'country': 'United Kingdom',
      'tags': ['heritage', 'views', 'cultural', 'budget_high'],
      'price': 2600.0,
      'image': 'assets/images/london.jpg',
      'rating': 4.6,
      'description':
          'Historic landmarks, theaters and cosmopolitan neighborhoods.',
      'gallery': ['assets/images/london.jpg', 'assets/images/rome_gal_2.jpg'],
    },
  ];

  // Return destination by exact name (or null)
  static Map<String, dynamic>? getDestinationByName(String name) {
    try {
      return destinations.firstWhere(
        (d) => (d['name'] as String).toLowerCase() == name.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  // Lightweight search - returns up to [limit] best matches
  static List<Map<String, dynamic>> search(String query, {int limit = 6}) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    final tokens = q.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

    final scored = destinations.map((d) {
      final name = (d['name'] as String).toLowerCase();
      final country = (d['country'] as String).toLowerCase();
      final tags = ((d['tags'] as List).join(' ')).toLowerCase();
      final text = '$name $country $tags';
      var matches = 0;
      for (final t in tokens) {
        if (text.contains(t)) matches++;
      }
      double score = tokens.isEmpty ? 0.0 : (matches / tokens.length);
      if (name.startsWith(q)) score += 0.5;
      if (score > 1.0) score = 1.0;
      return {'data': d, 'score': score};
    }).toList();

    scored.sort(
      (a, b) => (b['score'] as double).compareTo(a['score'] as double),
    );
    return scored
        .take(limit)
        .map((e) => e['data'] as Map<String, dynamic>)
        .toList();
  }

  // Robust filter that always returns ranked results (never empty)
  static List<Map<String, dynamic>> filter({
    String? budget,
    String? weather,
    String? style,
    String? query,
  }) {
    // Build relevance score for every destination
    final qTokens = (query ?? '')
        .trim()
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();

    final scored = <MapEntry<Map<String, dynamic>, double>>[];

    for (final d in destinations) {
      final tags = ((d['tags'] ?? []) as List)
          .map((t) => (t as String).toLowerCase())
          .toSet();
      final price = (d['price'] as num).toDouble();
      double score = 0.0;

      // rating contributes (normalized)
      final rating = (d['rating'] as num).toDouble();
      score += (rating / 5.0) * 1.0;

      // weather match
      if (weather != null && weather.isNotEmpty) {
        if (tags.contains(weather.toLowerCase())) score += 1.5;
      }

      // style match
      if (style != null && style.isNotEmpty) {
        if (tags.contains(style.toLowerCase())) score += 1.5;
      }

      // budget match (using simple thresholds or tag)
      if (budget != null && budget.isNotEmpty) {
        final b = budget.toLowerCase();
        if (tags.contains(b)) score += 1.2;
        // fallback numeric
        if (b == 'budget_low' && price <= 1200) score += 0.8;
        if (b == 'budget_mid' && price > 1200 && price <= 3000) score += 0.8;
        if (b == 'budget_high' && price > 3000) score += 0.8;
      }

      // query tokens match
      if (qTokens.isNotEmpty) {
        final text =
            ('${d['name']} ${d['country']} ${(d['tags'] as List).join(' ')}')
                .toLowerCase();
        var matches = 0;
        for (final t in qTokens) {
          if (text.contains(t)) matches++;
        }
        score += (matches / qTokens.length) * 1.2;
        if ((d['name'] as String).toLowerCase().startsWith(qTokens.first))
          score += 0.6;
      }

      scored.add(MapEntry(d, score));
    }

    // sort by score desc, then rating desc
    scored.sort((a, b) {
      final s = b.value.compareTo(a.value);
      if (s != 0) return s;
      return ((b.key['rating'] as num).compareTo(a.key['rating'] as num));
    });

    // Collect ranked list
    final ranked = scored.map((e) => e.key).toList();

    // If ranking produced zero (shouldn't), fallback to top-rated destinations
    if (ranked.isEmpty) {
      final fallback = List<Map<String, dynamic>>.from(destinations)
        ..sort((a, b) => (b['rating'] as num).compareTo(a['rating'] as num));
      return fallback;
    }

    return ranked;
  }

  // Build up to 4 images for a destination (try related then fallbacks)
  static List<String> galleryFor(String name, String image) {
    final Set<String> imgs = {};
    if (image.isNotEmpty) imgs.add(image);

    final key = name.toLowerCase();
    for (final d in destinations) {
      final n = (d['name'] as String).toLowerCase();
      final c = (d['country'] as String).toLowerCase();
      if (n.contains(key) || c.contains(key) || key.contains(n)) {
        final img = d['image'] as String?;
        if (img != null && img.isNotEmpty) imgs.add(img);
        final gallery = (d['gallery'] as List?) ?? [];
        for (final g in gallery) {
          if (g is String && g.isNotEmpty) imgs.add(g);
        }
      }
    }

    final fallbacks = [
      'assets/images/rj1.png',
      'assets/images/rj2.png',
      'assets/images/dest_bali.jpg',
      'assets/images/dest_kyoto.jpg',
      'assets/images/dest_london.jpg',
      'assets/images/dest_santorini.jpg',
      'assets/images/giza.png',
    ];

    for (final f in fallbacks) {
      if (imgs.length >= 4) break;
      imgs.add(f);
    }

    return imgs.take(4).toList();
  }
}
// ...existing code...