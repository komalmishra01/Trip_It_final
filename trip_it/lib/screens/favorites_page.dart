import 'package:flutter/material.dart';
import 'package_detail_screen.dart';
import '../services/suggestion_service.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

// Mock Data for the favorite destinations
class FavoriteDestination {
  final String title;
  final String country;
  final String category;
  final String image; // Network URL for placeholder image
  final double price;
  final double rating;
  final String description;

  FavoriteDestination({
    required this.title,
    required this.country,
    required this.category,
    required this.image,
    required this.price,
    required this.rating,
    required this.description,
  });
}

// (Removed old placeholder detail page; using shared DestinationDetailScreen instead.)

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  String _selectedCategory = 'All';

  List<FavoriteDestination> _mapDocsToFavorites(List<Map<String, dynamic>> docs) {
    final List<FavoriteDestination> out = [];
    for (final d in docs) {
      final name = (d['name'] as String?) ?? (d['id'] as String? ?? '');
      final match = SuggestionService.getDestinationByName(name ?? '');
      final image = (d['image'] as String?) ?? (match?['image'] as String?) ?? '';
      final rating = ((d['rating'] as num?)?.toDouble()) ?? ((match?['rating'] as num?)?.toDouble() ?? 4.5);
      final price = ((d['price'] as num?)?.toDouble()) ?? ((match?['price'] as num?)?.toDouble() ?? 0.0);
      final country = (d['country'] as String?) ?? (match?['country'] as String? ?? '');
      final desc = (d['description'] as String?) ?? (match?['description'] as String? ?? '');
      out.add(FavoriteDestination(
        title: name ?? 'Destination',
        country: country,
        category: 'All',
        image: image,
        price: price,
        rating: rating,
        description: desc,
      ));
    }
    return out;
  }

  // Gets unique categories for chips
  List<String> get _categories => const ['All'];

  // Filters favorites based on selected chip
  List<FavoriteDestination> _filteredFavorites(List<FavoriteDestination> list) {
    if (_selectedCategory == 'All') return list;
    return list.where((fav) => fav.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: Column(
        children: [
          Builder(builder: (context) {
            final user = AuthService.instance.currentUser;
            if (user == null) {
              return _buildHeader(context, 0);
            }
            return StreamBuilder<List<Map<String, dynamic>>>(
              stream: FirestoreService.instance.streamFavorites(user.uid),
              builder: (context, snapshot) {
                final count = (snapshot.data ?? []).length;
                return _buildHeader(context, count);
              },
            );
          }),

          // 2. Filtered Favorites List
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Builder(builder: (context) {
                final user = AuthService.instance.currentUser;
                if (user == null) {
                  return const Center(child: Text('Please sign in to view favorites'));
                }
                return StreamBuilder<List<Map<String, dynamic>>>(
                  stream: FirestoreService.instance.streamFavorites(user.uid),
                  builder: (context, snapshot) {
                    final docs = snapshot.data ?? [];
                    final favs = _mapDocsToFavorites(docs);
                    final list = _filteredFavorites(favs);
                    if (snapshot.connectionState == ConnectionState.waiting && list.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (list.isEmpty) {
                      return Center(
                        child: Text('No destinations saved in $_selectedCategory category.'),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 16.0),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        return _FavoriteCard(destination: list[index]);
                      },
                    );
                  },
                );
              }),
            ),
          ),

          // Space for the bottom navigation bar area (kept for final screen spacing)
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // --- Widget Builders for Design Matching ---

  Widget _buildHeader(BuildContext context, int count) {
    return Container(
      // Padding adjusted for status bar and content
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      decoration: const BoxDecoration(
        // Vibrant Pink/Magenta Gradient (Matched to image)
        gradient: LinearGradient(
          colors: [
            Color(0xFFFF3D68), // Bright Pink
            Color(0xFFE70F68), // Magenta
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        // Rounded bottom corners
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heart Icon (Top Left)
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.favorite, color: Colors.white, size: 30),
              // Optional: User Profile/Settings Icon could go here
            ],
          ),
          const SizedBox(height: 12),
          // Title
          const Text(
            'My Favorites',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          // Subtitle
          Text(
            '$count saved destinations',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 16),

          // Category Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((category) {
                // Determine label text (e.g., "All (3)")
                final labelText = category == 'All' ? 'All ($count)' : category;

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ActionChip(
                    label: Text(
                      labelText,
                      style: TextStyle(
                        color: _selectedCategory == category
                            ? Colors
                                  .white // White text for selected
                            : Colors.black87, // Dark text for unselected
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: _selectedCategory == category
                        ? const Color(0xFFF33383) // Selected Pink
                        : Colors.white, // White background for unselected
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Redesigned Favorite Card Widget (Matches Image) ---

// ...existing code...
class _FavoriteCard extends StatelessWidget {
  final FavoriteDestination destination;

  const _FavoriteCard({required this.destination});

  @override
  Widget build(BuildContext context) {
    // Helper that chooses asset or network based on the string
    Widget buildImage(String path) {
      final isNetwork = path.startsWith('http://') || path.startsWith('https://');
      if (isNetwork) {
        return Image.network(
          path,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 100,
            height: 100,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          ),
        );
      } else {
        return Image.asset(
          path,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 100,
            height: 100,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          ),
        );
      }
    }

    // Card ko InkWell se wrap karo taaki tap action add ho sake
    return InkWell(
      onTap: () {
        // Tap karne par Detail Page par navigate karega
        final gallery = SuggestionService.galleryFor(
          destination.title,
          destination.image,
        );

        final dest = {
          'name': destination.title,
          'country': destination.country,
          'description': destination.description,
          'image': destination.image,
          'rating': destination.rating,
          'packages': [
            {
              'title': '${destination.title} - Standard',
              'price': destination.price,
              'days': 5,
              'people': '2-4 people',
              'includes': ['Hotel', 'Meals', 'Transport'],
            },
            {
              'title': '${destination.title} - Premium',
              'price': destination.price + 500,
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
            builder: (_) => PackageDetailScreen(destination: dest),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Card(
        // Card looks like it has some margin and elevated
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Side: Image with Badge
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    buildImage(destination.image),
                    // 'Perfect Match' label (Matched to image)
                    Positioned(
                      top: 8,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50), // Green for the star/match
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.star, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Perfect match',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Right Side: Details Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Location & Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Location Pin and Country/City
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.grey,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              destination.country,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        // Rating
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber, // Orange/Amber star color
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${destination.rating}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Row 2: Title
                    Text(
                      destination.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Row 3: Description (Snippet)
                    Text(
                      destination.description,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Row 4: Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text(
                          'Starting From',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          // Price is blue in the original image
                          '\$${destination.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Color(0xFF4A8CFF),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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
    );
  }
}
// ...existing code...
