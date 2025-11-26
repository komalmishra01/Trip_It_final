import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/cart_service.dart';
import 'settings_detailed.dart';
import 'help_detailed.dart';
import 'trip_history_page.dart';

// --- Color Palette and Constants ---
const Color primaryRed = Color(0xFFE53935);
const Color primaryPink = Color(0xFFFF4A8C);
const Color lightPink = Color(0xFFFF89B2);
const Color offWhiteBackground = Color(0xFFF6F6F8);

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;

  const _StatCard({
    required this.value,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentTripTile extends StatelessWidget {
  final String title;
  final String date;
  final String image;
  final int rating;

  const _RecentTripTile({
    required this.title,
    required this.date,
    required this.image,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    Widget leadingImage;
    if (image.isNotEmpty && image.startsWith('http')) {
      leadingImage = Image.network(
        image,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 60,
          height: 60,
          color: Colors.grey.shade300,
          child: const Icon(Icons.image, color: Colors.grey),
        ),
      );
    } else if (image.isNotEmpty) {
      leadingImage = Image.asset(
        image,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 60,
          height: 60,
          color: Colors.grey.shade300,
          child: const Icon(Icons.image, color: Colors.grey),
        ),
      );
    } else {
      leadingImage = Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.blue.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            title.isNotEmpty ? title[0] : '?',
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: leadingImage,
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(date, style: TextStyle(color: Colors.grey.shade600)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$rating',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.star, color: Color(0xFFFDD835), size: 18),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _displayName;
  String? _email;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      setState(() {
        _displayName = 'Guest';
        _email = null;
        _loading = false;
      });
      return;
    }

    String? name = user.displayName;
    if (name == null || name.isEmpty) {
      final data = await FirestoreService.instance.getUserProfile(user.uid);
      name = data?['displayName'] as String?;
    }
    setState(() {
      _displayName = name ?? user.email ?? 'User';
      _email = user.email;
      _loading = false;
    });
  }

  Widget _buildSettingsTile(IconData icon, String title, BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, color: Colors.black87),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          if (title == 'App Settings') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => const SettingsDetailed()),
            );
          } else if (title == 'Help & Support') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => const HelpDetailed()),
            );
          }
        },
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: primaryRed,
        boxShadow: [
          BoxShadow(
            color: primaryRed.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextButton.icon(
        icon: const Icon(Icons.logout, color: Colors.white),
        label: const Text(
          'Sign Out',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        onPressed: () async {
          // Clear any locally stored cart to avoid mixing states across users
          CartService.instance.clear();
          await AuthService.instance.signOut();
          // Replace current stack with the login screen
          if (!context.mounted) return;
          Navigator.pushReplacementNamed(context, '/login');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: offWhiteBackground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 180,
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
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white24,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _loading ? 'Loading…' : (_displayName ?? 'User'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _loading ? '' : (_email ?? ''),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.favorite_border,
                        color: Colors.white,
                        size: 28,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Transform.translate(
                offset: const Offset(0, -30),
                child: Builder(
                  builder: (context) {
                    final user = AuthService.instance.currentUser;
                    final stream = user == null
                        ? const Stream<List<Map<String, dynamic>>>.empty()
                        : FirestoreService.instance.streamBookings(user.uid);
                    return StreamBuilder<List<Map<String, dynamic>>>(
                      stream: stream,
                      builder: (context, snapshot) {
                        final bookings = snapshot.data ?? [];
                        final trips = bookings.length;
                        double avg = 0.0;
                        if (trips > 0) {
                          int count = 0;
                          for (final b in bookings) {
                            final r = b['rating'];
                            if (r is num) {
                              avg += r.toDouble();
                              count++;
                            }
                          }
                          if (count > 0) avg /= count;
                        }
                        final avgText = avg > 0 ? avg.toStringAsFixed(1) : '-';
                        return Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (c) => const TripHistoryPage(),
                                  ),
                                );
                              },
                              child: _StatCard(
                                value: trips.toString(),
                                label: 'Trips',
                                valueColor: primaryRed,
                              ),
                            ),
                            const SizedBox(width: 12),
                            _StatCard(
                              value: avgText,
                              label: 'Rating',
                              valueColor: const Color(0xFFFDD835),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Trips',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (c) => const TripHistoryPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'View all',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Builder(
                    builder: (context) {
                      final user = AuthService.instance.currentUser;
                      final stream = user == null
                          ? const Stream<List<Map<String, dynamic>>>.empty()
                          : FirestoreService.instance.streamBookings(user.uid);
                      return StreamBuilder<List<Map<String, dynamic>>>(
                        stream: stream,
                        builder: (context, snapshot) {
                          final list = (snapshot.data ?? []).take(3).toList();
                          if (snapshot.connectionState == ConnectionState.waiting && list.isEmpty) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (list.isEmpty) {
                            return Text(
                              'No recent trips found',
                              style: TextStyle(color: Colors.grey.shade600),
                            );
                          }
                          List<Widget> tiles = [];
                          for (final b in list) {
                            final title = (b['destination'] as String?) ?? 'Trip';
                            String dateText = 'Recent';
                            final createdAt = b['createdAt'];
                            if (createdAt is Timestamp) {
                              final dt = createdAt.toDate();
                              const months = [
                                'January','February','March','April','May','June','July','August','September','October','November','December'
                              ];
                              dateText = '${months[dt.month - 1]} ${dt.year}';
                            }
                            final rating = (b['rating'] is num) ? (b['rating'] as num).round() : 5;
                            final image = (b['image'] as String?) ?? (b['destinationImage'] as String?) ?? '';
                            tiles.add(_RecentTripTile(title: title, date: dateText, image: image, rating: rating));
                          }
                          return Column(children: tiles);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buildSettingsTile(Icons.settings, 'App Settings', context),
                  _buildSettingsTile(
                    Icons.help_outline,
                    'Help & Support',
                    context,
                  ),
                  const SizedBox(height: 24),
                  _buildSignOutButton(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const SizedBox.shrink(),
    );
  }
}
