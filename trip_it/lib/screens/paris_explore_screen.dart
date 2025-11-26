import 'package:flutter/material.dart';

// Destination Data Model
class Destination {
  final String imageName;
  final String country;
  final String city;
  final String description;
  final String price;
  final String rating;
  final Color flagColor; // For 'Perfect Match' tag

  const Destination({
    required this.imageName,
    required this.country,
    required this.city,
    required this.description,
    required this.price,
    required this.rating,
    this.flagColor = Colors.transparent,
  });
}

// Reusable Destination Card Widget
class _DestinationCard extends StatelessWidget {
  final Destination destination;
  const _DestinationCard({required this.destination});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Left Image
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(destination.imageName, width: 100, height: 100, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            // Right Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      destination.flagColor != Colors.transparent
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: destination.flagColor, borderRadius: BorderRadius.circular(6)),
                              child: const Text('Perfect match', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            )
                          : const Icon(Icons.flag, color: Colors.black54, size: 14),
                      const SizedBox(width: 4),
                      Text(destination.country, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      const Spacer(),
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(destination.rating, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(destination.city, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(destination.description, style: const TextStyle(color: Colors.black54, fontSize: 12.5), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Starting From ', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text(destination.price, style: const TextStyle(color: Color(0xFF2F6BFF), fontWeight: FontWeight.w800, fontSize: 15)),
                      const Spacer(),
                      // FIX for Overflow
                      Flexible(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2F6BFF),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          ),
                          child: const Text('Explore now', style: TextStyle(fontSize: 12)),
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// Helper Class to define a pin's properties
class _MapPin {
  final int id;
  final double top; 
  final double left; 
  final Color color;
  final String destinationName;

  const _MapPin({required this.id, required this.top, required this.left, required this.color, required this.destinationName});
}

// Custom Widget for the Blue/Red Pin Icon Button
class _PinButton extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;
  const _PinButton({required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30, height: 30, 
        decoration: BoxDecoration(
          color: color, shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8, spreadRadius: 1)],
        ),
        child: const Icon(Icons.location_pin, color: Colors.white, size: 18),
      ),
    );
  }
}

// Stat Card Widget
class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatCard({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 90, margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.blueAccent, size: 22),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}


class ParisExploreScreen extends StatelessWidget {
  const ParisExploreScreen({super.key});

  // Paris Destination Data (with Perfect Match tag: green)
  static const Destination parisDestination = Destination(
    imageName: 'assets/images/paris.jpg', // ADD THIS IMAGE ASSET
    country: 'France',
    city: 'Paris',
    description: 'City of lights and romance, where timeless elegance meets romance.',
    price: '\$1899',
    rating: '4.7',
    flagColor: Color(0xFF1CB75A),
  );

  static const List<_MapPin> _mapPins = [
    _MapPin(id: 1, top: 150, left: 100, color: Colors.red, destinationName: "New York, USA"),
    _MapPin(id: 2, top: 130, left: 300, color: Colors.blue, destinationName: "Paris, France"),
    _MapPin(id: 3, top: 180, left: 450, color: Colors.blue, destinationName: "Beijing, China"),
    _MapPin(id: 4, top: 350, left: 550, color: Colors.blue, destinationName: "Sydney, Australia"),
  ];

  @override
  Widget build(BuildContext context) {
    const double mapImageAspectRatio = 600 / 400;
    void handlePinTap(String destination) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exploring: $destination'),
          duration: const Duration(milliseconds: 1500),
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
            Text("Explore The World", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
            Text("Tap On Pins To Discover Destinations", style: TextStyle(color: Colors.white70, fontSize: 12)),
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
            // World map with Pins
            LayoutBuilder(
              builder: (context, constraints) {
                final double mapWidth = constraints.maxWidth;
                final double mapHeight = mapWidth / mapImageAspectRatio;
                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: mapWidth,
                    height: mapHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset('assets/images/world_map.png', fit: BoxFit.cover),
                        ),
                        ..._mapPins.map((pin) {
                          return Positioned(
                            top: pin.top * (mapWidth / 600),
                            left: pin.left * (mapWidth / 600),
                            child: _PinButton(color: pin.color, onTap: () => handlePinTap(pin.destinationName)),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),
            
            // Stats Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _StatCard(value: '195', label: 'Countries', icon: Icons.flag),
                _StatCard(value: '2000+', label: 'Destinations', icon: Icons.map),
                _StatCard(value: '50K+', label: 'Happy Travelers', icon: Icons.people),
              ],
            ),

            const SizedBox(height: 24),

            // Paris Destination Card
            _DestinationCard(destination: parisDestination),
          ],
        ),
      ),
    );
  }
}