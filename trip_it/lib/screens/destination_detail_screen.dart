import 'package:flutter/material.dart';

class DestinationDetailScreen extends StatelessWidget {
  static const route = '/destination';
  final String title;
  final String country;
  final String image;
  final double rating;
  final double price;
  final List<String> tags;

  const DestinationDetailScreen({
    super.key,
    required this.title,
    required this.country,
    required this.image,
    required this.rating,
    required this.price,
    this.tags = const [],
  });

  factory DestinationDetailScreen.fromArgs(Map args) {
    return DestinationDetailScreen(
      title: args['title'] as String,
      country: (args['country'] ?? '') as String,
      image: args['image'] as String,
      rating: (args['rating'] ?? 4.5 as num).toDouble(),
      price: (args['price'] ?? 0 as num).toDouble(),
      tags: (args['tags'] as List?)?.cast<String>() ?? const [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F8),
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              image,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(height: 200, color: Colors.grey.shade300),
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.place, size: 16, color: Colors.black54),
            const SizedBox(width: 6),
            Expanded(child: Text(country, style: const TextStyle(fontWeight: FontWeight.w600))),
            const Icon(Icons.star, size: 18, color: Colors.amber),
            const SizedBox(width: 4),
            Text(rating.toStringAsFixed(1)),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            const Spacer(),
            Text('\$${price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.indigo, fontSize: 18)),
          ]),
          const SizedBox(height: 12),
          if (tags.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags.map((t) => Chip(label: Text(t))).toList(),
            ),
          const SizedBox(height: 12),
          const Text('About', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            'Experience the best of this destination with curated stays, activities, and local experiences. '
            'This package includes recommendations for sights, dining, and travel tips to make your trip perfect.',
            style: const TextStyle(color: Colors.black87),
          ),
          const SizedBox(height: 16),
          const Text('What\'s included', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const _Bullet(text: 'Hotel and accommodation suggestions'),
          const _Bullet(text: 'Top attractions and activities'),
          const _Bullet(text: 'Local cuisine recommendations'),
          const _Bullet(text: 'Travel tips and best seasons'),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, shape: const StadiumBorder()),
              child: const Text('Add to Cart'),
            ),
          )
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ]),
    );
  }
}
