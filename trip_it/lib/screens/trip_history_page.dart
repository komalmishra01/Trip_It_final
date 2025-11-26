// trip_history_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

// --- Color Palette and Constants (Same as profile_page.dart) ---
const Color primaryRed = Color(0xFFE53935);
const Color primaryPink = Color(0xFFFF4A8C);
const Color lightPink = Color(0xFFFF89B2);
const Color offWhiteBackground = Color(0xFFF6F6F8);
const Color accentYellow = Color(0xFFFDD835);
const Color cardColor = Colors.white;

// --- Dummy Data for Trip History ---
class Trip {
  final String title;
  final String date;
  final int rating;
  final Color imageColor;

  Trip({
    required this.title,
    required this.date,
    required this.rating,
    required this.imageColor,
  });
}

// Stream version so UI updates immediately when bookings change
Stream<List<Trip>> _streamTrips() {
  final user = AuthService.instance.currentUser;
  List<Trip> sample() => [
        Trip(title: 'Bali', date: 'Jan 2024', rating: 5, imageColor: Colors.blue.shade400),
        Trip(title: 'Paris', date: 'Mar 2024', rating: 4, imageColor: Colors.pink.shade300),
        Trip(title: 'Tokyo', date: 'Jun 2024', rating: 5, imageColor: Colors.indigo.shade400),
      ];
  if (user == null) return Stream.value(sample());
  return FirestoreService.instance.streamBookings(user.uid).map((list) {
    final trips = list.map((b) {
      final title = (b['destination'] as String?) ?? 'Trip';
      final createdAt = b['createdAt'];
      String date = 'Recent';
      if (createdAt is Timestamp) {
        final dt = createdAt.toDate();
        date = '${dt.month}/${dt.year}';
      }
      final r = b['rating'];
      final rating = (r is num) ? r.round() : 5;
      final color = Colors.blue.shade400;
      return Trip(title: title, date: date, rating: rating, imageColor: color);
    }).toList();
    return trips.isEmpty ? sample() : trips;
  });
}

// --- Trip History Page ---
class TripHistoryPage extends StatelessWidget {
  const TripHistoryPage({super.key});

  // Helper Widget for a single trip list item
  Widget _buildTripListItem(Trip trip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: trip.imageColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              trip.title.substring(0, 1),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          trip.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          trip.date,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: accentYellow, size: 18),
            const SizedBox(width: 4),
            Text(
              '${trip.rating}',
              style: const TextStyle(
                color: accentYellow,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        onTap: () {
          // Handle tap, e.g., navigate to trip details
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: offWhiteBackground,
      // --- AppBar (Pink Gradient Header) ---
      appBar: AppBar(
        title: const Text(
          'Trip History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryPink, lightPink],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),
      ),
      // --- Body Content (List of all trips) ---
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<Trip>>(
          stream: _streamTrips(),
          builder: (context, snapshot) {
            final data = snapshot.data ?? [];
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (data.isEmpty) {
              return Center(
                child: Text(
                  'No trip history found!',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                ),
              );
            }
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                return _buildTripListItem(data[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
