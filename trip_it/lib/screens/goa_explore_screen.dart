// ...existing code...
import 'package:flutter/material.dart';

// Simple Goa explore screen showing Goa image and details
class GoaExploreScreen extends StatelessWidget {
  const GoaExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8FAEFF),
        elevation: 0,
        title: const Text('Goa, India', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/goa.jpg',
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _StatCard(value: '195', label: 'Countries', icon: Icons.flag),
              _StatCard(value: '2000+', label: 'Destinations', icon: Icons.map),
              _StatCard(value: '50K+', label: 'Happy Travelers', icon: Icons.people),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset('assets/images/goa.jpg', width: 100, height: 100, fit: BoxFit.cover),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: const [
                      Icon(Icons.flag, color: Colors.black54, size: 14),
                      SizedBox(width: 4),
                      Text('India', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      Spacer(),
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      SizedBox(width: 4),
                      Text('4.7', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ]),
                    const SizedBox(height: 6),
                    const Text('Goa', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 4),
                    const Text(
                      'Beautiful beaches and Portuguese heritage.\nPerfect for sun, sand and seafood.',
                      style: TextStyle(color: Colors.black54, fontSize: 12.5),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Text('Starting From ', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const Text('\$599', style: TextStyle(color: Color(0xFF2F6BFF), fontWeight: FontWeight.w800, fontSize: 15)),
                      const Spacer(),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 140),
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2F6BFF),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          child: const Text('Explore now'),
                        ),
                      ),
                    ])
                  ]),
                )
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

// Reuse stat card from explore screen
class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  const _StatCard({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 90,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: Colors.blueAccent, size: 22),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}