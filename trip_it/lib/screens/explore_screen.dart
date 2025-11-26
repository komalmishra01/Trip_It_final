import 'package:flutter/material.dart';
// 1. Import all destination screens
import 'world_map_widget.dart';
import '../services/suggestion_service.dart';
import 'package_detail_screen.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  // (map pins are provided by `WorldMapWidget` directly)

  @override
  Widget build(BuildContext context) {
    const double mapImageAspectRatio = 600 / 400;

    // 2. Handle map pin taps: search the in-memory catalog and open PackageDetailScreen
    void onMapPinTap(String destination) {
      // First try a smart search using the SuggestionService
      final results = SuggestionService.search(destination, limit: 1);
      if (results.isNotEmpty) {
        final dest = results.first;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PackageDetailScreen(destination: dest),
          ),
        );
        return;
      }

      // If search didn't match, try exact name lookup
      final loose = SuggestionService.getDestinationByName(destination);
      if (loose != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PackageDetailScreen(destination: loose),
          ),
        );
        return;
      }

      // Fallback: show a friendly message
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No package page found for "$destination"'),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF2F6BFF),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8FAEFF),
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Explore The World",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            Text(
              "Tap On Pins To Discover Destinations",
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final double mapWidth = constraints.maxWidth;
                final double mapHeight = mapWidth / mapImageAspectRatio;

                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: mapWidth,
                    height: mapHeight,
                    child: WorldMapWidget(
                      handlePinTap: (place) {
                        // Forward the map pin tap to the local handler that opens package pages
                        onMapPinTap(place);
                      },
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // 📊 Stats Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _StatCard(value: '195', label: 'Countries', icon: Icons.flag),
                _StatCard(
                  value: '2000+',
                  label: 'Destinations',
                  icon: Icons.map,
                ),
                _StatCard(
                  value: '50K+',
                  label: 'Happy Travelers',
                  icon: Icons.people,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 🗽 Destination Card (New York) - Keeping this static for the example
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Left Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        'assets/images/newyork.jpg',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Right Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.flag, color: Colors.black54, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'USA',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Spacer(),
                              Icon(Icons.star, color: Colors.amber, size: 16),
                              SizedBox(width: 4),
                              Text(
                                '4.7',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'New York',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'The city that never sleeps.\nWhere dazzling lights meet endless dreams.',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12.5,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text(
                                'Starting From ',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const Text(
                                '\$1999',
                                style: TextStyle(
                                  color: Color(0xFF2F6BFF),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                              const Spacer(),
                              Flexible(
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2F6BFF),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                  ),
                                  child: const Text(
                                    'Explore now',
                                    style: TextStyle(fontSize: 12),
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
            ),
          ],
        ),
      ),
    );
  }
}

// Pins are provided by `WorldMapWidget` — no local static pins required.

// Existing Stat Card Widget (Kept for completeness)
class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 90,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.blueAccent, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
