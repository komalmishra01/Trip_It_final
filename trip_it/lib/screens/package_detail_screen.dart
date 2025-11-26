// package_detail_screen.dart

import 'package:flutter/material.dart';
import 'checkout_screen.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/cart_service.dart';
import 'favorites_page.dart';
import 'cart_page.dart' show CartPage;
import 'profile_page.dart';
import '../currency_controller.dart';

class PackageDetailScreen extends StatelessWidget {
  final Map<String, dynamic> destination;

  const PackageDetailScreen({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    // Extracting main data
    final String name = destination['name'] as String;
    final String country = destination['country'] as String;
    final String description = destination['description'] as String;
    final String image = destination['image'] as String;
    final double rating = ((destination['rating'] as num?)?.toDouble()) ?? 0.0;
    final List<Map<String, dynamic>> packages = ((destination['packages'] as List?) ?? const [])
        .map((e) => (e as Map).cast<String, dynamic>())
        .toList();
    final List<String> gallery = ((destination['gallery'] as List?) ?? const [])
        .cast<String>();

    return Scaffold(
      body: Stack(
        children: [
          // 1. Main Scrollable Content
          CustomScrollView(
            slivers: [
              _SliverHeader(
                name: name,
                country: country,
                image: image,
                rating: rating,
                gallery: gallery,
                description: description,
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Available Packages',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Displaying all packages
                        ...packages
                            .map(
                              (pkg) => _PackageTile(
                                package: pkg,
                                destination: destination,
                              ),
                            )
                            ,

                        const SizedBox(height: 20),
                        _BottomInfo(),
                        const SizedBox(
                          height: 60,
                        ), // Space for bottom navigation
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          ),

          // 2. Fixed Bottom Navigation Bar (Home, Favourites, Cart, Profile)
          Align(alignment: Alignment.bottomCenter, child: _BottomNavBar()),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------
// Sub-Widgets
// ------------------------------------------------------------------

// Header with Image, Gallery, Rating, and Back/Fav buttons
class _SliverHeader extends StatelessWidget {
  final String name;
  final String country;
  final String image;
  final double rating;
  final List<String> gallery;
  final String description;

  const _SliverHeader({
    required this.name,
    required this.country,
    required this.image,
    required this.rating,
    required this.gallery,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final uid = user?.uid;
    return SliverAppBar(
      expandedHeight: 400.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        titlePadding: EdgeInsets.zero,
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Main Image - support both asset and network images
            image.startsWith('http')
                ? Image.network(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: Colors.grey.shade300),
                  )
                : Image.asset(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: Colors.grey.shade300),
                  ),

            // Bottom Content Area
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              country,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              description.split('.').first,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Gallery Images
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: gallery.take(5).map((img) {
                        final widgetImg = img.startsWith('http')
                            ? Image.network(
                                img,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.blue.shade100,
                                ),
                              )
                            : Image.asset(
                                img,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.blue.shade100,
                                ),
                              );
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: widgetImg,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Available Packages',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Top Bar (Back and Heart)
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CircleIcon(
            icon: Icons.arrow_back,
            onTap: () => Navigator.pop(context),
          ),
          Builder(builder: (context) {
            if (uid == null) {
              return _CircleIcon(icon: Icons.favorite_border, onTap: () {});
            }
            return StreamBuilder<Set<String>>(
              stream: FirestoreService.instance.streamFavoriteIds(uid),
              builder: (context, snapshot) {
                final favs = snapshot.data ?? {};
                final isFav = favs.contains(name);
                return _CircleIcon(
                  icon: isFav ? Icons.favorite : Icons.favorite_border,
                  onTap: () {
                    final data = {
                      'name': name,
                      'country': country,
                      'image': image,
                      'rating': rating,
                      'description': description,
                    };
                    if (isFav) {
                      FirestoreService.instance.removeFavorite(uid, name);
                    } else {
                      FirestoreService.instance.setFavorite(uid, name, data);
                    }
                  },
                );
              },
            );
          }),
        ],
      ),
    );
  }
}

// Widget for a single package tile
class _PackageTile extends StatelessWidget {
  final Map<String, dynamic> package;
  final Map<String, dynamic> destination;

  const _PackageTile({required this.package, required this.destination});

  @override
  Widget build(BuildContext context) {
    final String title = (package['title'] as String?) ?? 'Package';
    final double price = ((package['price'] as num?)?.toDouble()) ?? 0.0;
    final int days = (package['days'] as int?) ?? 0;
    final String people = (package['people'] as String?) ?? '';
    final List<String> includes = ((package['includes'] as List?) ?? const [])
        .cast<String>();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A8CFF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('$days days', style: const TextStyle(color: Colors.grey)),
                const SizedBox(width: 16),
                const Icon(Icons.people_alt, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(people, style: const TextStyle(color: Colors.grey)),
                const Spacer(),
                const Text(
                  'per person',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const Divider(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: includes
                  .map(
                    (item) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check, color: Colors.green, size: 16),
                        const SizedBox(width: 4),
                        Text(item, style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final name = destination['name'] as String;
                      final image = destination['image'] as String? ?? '';
                      final id = '${name.toLowerCase()}-${title.toLowerCase()}'
                          .replaceAll(RegExp(r"[^a-z0-9]+"), "-")
                          .replaceAll(RegExp(r"-+"), "-");
                      final data = {
                        'title': title,
                        'description': people,
                        'image': image,
                        'price': price,
                        'destination': name,
                      };
                      CartService.instance.add(data);
                      final uid = AuthService.instance.currentUser?.uid;
                      if (uid != null) {
                        FirestoreService.instance.addOrIncrementCartItem(uid, id, data);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to cart')),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart_outlined),
                    label: const Text('Add to Cart'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4A8CFF),
                      side: const BorderSide(color: Color(0xFF4A8CFF)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to checkout with the destination and this package
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CheckoutScreen(
                            destination: destination,
                            package: package,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A8CFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Book Now'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Widget for the bottom info section (Best time, Currency)
class _BottomInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final code = currencyController.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Best time to visit',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Mar - Oct',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Currency', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(
                    code,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}

// Custom button for back/heart icon in the header
class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onTap,
      ),
    );
  }
}

// Fixed Bottom Navigation Bar
class _BottomNavBar extends StatelessWidget {
  void _go(BuildContext context, String label) {
    if (label == 'Home') {
      Navigator.popUntil(context, (r) => r.isFirst);
    } else if (label == 'Favourites') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesPage()));
    } else if (label == 'Cart') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage()));
    } else if (label == 'Profile') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(icon: Icons.home_outlined, label: 'Home', isSelected: true, onTap: () => _go(context, 'Home')),
          _NavItem(icon: Icons.favorite_border, label: 'Favourites', onTap: () => _go(context, 'Favourites')),
          _NavItem(icon: Icons.shopping_cart_outlined, label: 'Cart', onTap: () => _go(context, 'Cart')),
          _NavItem(icon: Icons.person_outline, label: 'Profile', onTap: () => _go(context, 'Profile')),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF4A8CFF) : Colors.grey,
            size: 26,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? const Color(0xFF4A8CFF) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
