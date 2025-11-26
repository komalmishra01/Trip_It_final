import 'package:flutter/material.dart';
import 'checkout_screen.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/cart_service.dart';
import '../currency_controller.dart';

// Data model for a single item in the cart
class CartItem {
  final String title;
  final String
  description; // Renamed subtitle to description for better clarity, and updated initial data below
  final String image;
  final double price;
  int quantity;

  CartItem({
    required this.title,
    required this.description,
    required this.image,
    required this.price,
    this.quantity = 1,
  });
}

// Custom widget to display the cart item card, designed to match the provided image
class CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF4A8CFF);
    const Color deleteRed = Color(
      0xFFE53935,
    ); // A nice shade of red for the delete icon

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          16,
        ), // Slightly increased radius for modern look
      ),
      elevation: 4, // Added elevation for a floating card effect
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                item.image,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                // Placeholder/error handling
                errorBuilder: (_, __, ___) => Container(
                  width: 90,
                  height: 90,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.photo, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Text details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${Currency.formatINR(item.price)} per person',
                    style: const TextStyle(
                      color: primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            // Remove and Quantity controls
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Delete Icon Button
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline, color: deleteRed),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: 24,
                ),
                const SizedBox(
                  height: 25,
                ), // Spacing to separate delete and quantity
                // Quantity Controls
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Decrement Button
                    GestureDetector(
                      onTap: onDecrement,
                      child: Icon(
                        item.quantity > 1
                            ? Icons.remove_circle
                            : Icons.remove_circle_outline,
                        color: item.quantity > 1
                            ? Colors.grey.shade600
                            : Colors.grey.shade400,
                        size: 20,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    // Increment Button
                    GestureDetector(
                      onTap: onIncrement,
                      child: const Icon(
                        Icons.add_circle,
                        color: primaryBlue,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Main Cart Page
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  // Placeholder for navigating to Checkout, assuming it's a named route
  static const String routeName = '/cart';

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Define the primary color to be used globally in this screen
  static const Color primaryBlue = Color(0xFF4A8CFF);

  List<CartItem> _itemsFromDocs(List<Map<String, dynamic>> docs) {
    return docs.map((d) {
      return CartItem(
        title: (d['title'] as String?) ?? 'Item',
        description: (d['description'] as String?) ?? '',
        image: (d['image'] as String?) ?? '',
        price: ((d['price'] as num?)?.toDouble()) ?? 0.0,
        quantity: (d['quantity'] as int?) ?? 1,
      );
    }).toList();
  }

  // Calculated properties
  double subtotalOf(List<CartItem> items) =>
      items.fold(0, (s, it) => s + it.price * it.quantity);
  // Using the value from the image: $1,200
  static const double taxAndFees = 1200.0;
  double totalOf(List<CartItem> items) => subtotalOf(items) + taxAndFees;

  // State management methods
  void _removeItem(String id) {
    final user = AuthService.instance.currentUser;
    final uid = user?.uid;
    if (uid != null) {
      FirestoreService.instance.removeCartItem(uid, id);
    }
  }

  void _inc(String id) {
    final uid = AuthService.instance.currentUser?.uid;
    if (uid != null) {
      FirestoreService.instance.updateCartQuantity(uid, id, 1);
    }
  }

  void _dec(String id) {
    final uid = AuthService.instance.currentUser?.uid;
    if (uid != null) {
      FirestoreService.instance.updateCartQuantity(uid, id, -1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    return ValueListenableBuilder<String>(
      valueListenable: currencyController,
      builder: (context, code, _) {
        return Scaffold(
          backgroundColor:
              Colors.white, // Use white or very light background for the body
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/home', (route) => false),
            ),
            title: const Text(
              'My Cart',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              if (user != null)
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: FirestoreService.instance.streamCart(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      // Network/API error: only show local count
                      final localOnly = CartService.instance.items.fold<int>(
                        0,
                        (s, m) => s + ((m['quantity'] as int?) ?? 1),
                      );
                      return Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Text(
                          '$localOnly item',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      );
                    }
                    final remoteCount = (snapshot.data ?? []).fold<int>(
                      0,
                      (s, d) => s + ((d['quantity'] as int?) ?? 1),
                    );
                    return AnimatedBuilder(
                      animation: CartService.instance,
                      builder: (context, _) {
                        final localCount = CartService.instance.items.fold<int>(
                          0,
                          (s, m) => s + ((m['quantity'] as int?) ?? 1),
                        );
                        // Avoid double counting when logged-in: prefer remote if available
                        final count = remoteCount > 0
                            ? remoteCount
                            : localCount;
                        return Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Text(
                            '$count item',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        );
                      },
                    );
                  },
                ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.currency_exchange, color: Colors.black),
                initialValue: code,
                onSelected: (c) => setCurrencyPersisted(c),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'INR', child: Text('₹ INR')),
                  PopupMenuItem(value: 'USD', child: Text('\$ USD')),
                  PopupMenuItem(value: 'GBP', child: Text('£ GBP')),
                  PopupMenuItem(value: 'EUR', child: Text('€ EUR')),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              // Cart Items List
              Expanded(
                child: user == null
                    ? AnimatedBuilder(
                        animation: CartService.instance,
                        builder: (context, _) {
                          final items = CartService.instance.items
                              .map(
                                (m) => CartItem(
                                  title: (m['title'] as String?) ?? 'Item',
                                  description:
                                      (m['description'] as String?) ?? '',
                                  image: (m['image'] as String?) ?? '',
                                  price:
                                      ((m['price'] as num?)?.toDouble()) ?? 0.0,
                                  quantity: (m['quantity'] as int?) ?? 1,
                                ),
                              )
                              .toList();
                          if (items.isEmpty) {
                            return const Center(child: Text('Cart is empty'));
                          }
                          return ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, i) {
                              return CartItemCard(
                                item: items[i],
                                onRemove: () =>
                                    CartService.instance.removeAt(i),
                                onIncrement: () =>
                                    CartService.instance.increment(i),
                                onDecrement: () =>
                                    CartService.instance.decrement(i),
                              );
                            },
                          );
                        },
                      )
                    : StreamBuilder<List<Map<String, dynamic>>>(
                        stream: FirestoreService.instance.streamCart(user.uid),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            // Fallback to local items if remote stream fails
                            final localItems = CartService.instance.items
                                .map(
                                  (m) => CartItem(
                                    title: (m['title'] as String?) ?? 'Item',
                                    description:
                                        (m['description'] as String?) ?? '',
                                    image: (m['image'] as String?) ?? '',
                                    price:
                                        ((m['price'] as num?)?.toDouble()) ??
                                        0.0,
                                    quantity: (m['quantity'] as int?) ?? 1,
                                  ),
                                )
                                .toList();
                            if (localItems.isEmpty) {
                              return const Center(child: Text('Cart is empty'));
                            }
                            final expanded = <CartItem>[];
                            final sourceIndex = <int>[];
                            for (var si = 0; si < localItems.length; si++) {
                              final q = localItems[si].quantity;
                              for (var k = 0; k < q; k++) {
                                expanded.add(
                                  CartItem(
                                    title: localItems[si].title,
                                    description: localItems[si].description,
                                    image: localItems[si].image,
                                    price: localItems[si].price,
                                    quantity: 1,
                                  ),
                                );
                                sourceIndex.add(si);
                              }
                            }
                            return ListView.builder(
                              itemCount: expanded.length,
                              itemBuilder: (context, i) {
                                final src = sourceIndex[i];
                                return CartItemCard(
                                  item: expanded[i],
                                  onRemove: () {
                                    final q =
                                        (CartService
                                                .instance
                                                .items[src]['quantity']
                                            as int?) ??
                                        1;
                                    if (q > 1) {
                                      CartService.instance.decrement(src);
                                    } else {
                                      CartService.instance.removeAt(src);
                                    }
                                  },
                                  onIncrement: () =>
                                      CartService.instance.increment(src),
                                  onDecrement: () =>
                                      CartService.instance.decrement(src),
                                );
                              },
                            );
                          }
                          final docs = snapshot.data ?? [];
                          final items = _itemsFromDocs(docs);
                          if (snapshot.connectionState ==
                                  ConnectionState.waiting &&
                              items.isEmpty) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (docs.isEmpty) {
                            final localItems = CartService.instance.items
                                .map(
                                  (m) => CartItem(
                                    title: (m['title'] as String?) ?? 'Item',
                                    description:
                                        (m['description'] as String?) ?? '',
                                    image: (m['image'] as String?) ?? '',
                                    price:
                                        ((m['price'] as num?)?.toDouble()) ??
                                        0.0,
                                    quantity: (m['quantity'] as int?) ?? 1,
                                  ),
                                )
                                .toList();
                            if (localItems.isEmpty) {
                              return const Center(child: Text('Cart is empty'));
                            }
                            return ListView.builder(
                              itemCount: localItems.length,
                              itemBuilder: (context, i) {
                                return CartItemCard(
                                  item: localItems[i],
                                  onRemove: () =>
                                      CartService.instance.removeAt(i),
                                  onIncrement: () =>
                                      CartService.instance.increment(i),
                                  onDecrement: () =>
                                      CartService.instance.decrement(i),
                                );
                              },
                            );
                          }
                          return ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, i) {
                              final id = (docs[i]['id'] as String?) ?? '';
                              return CartItemCard(
                                item: items[i],
                                onRemove: () async {
                                  await FirestoreService.instance
                                      .removeCartItem(user.uid, id);
                                },
                                onIncrement: () => FirestoreService.instance
                                    .updateCartQuantity(user.uid, id, 1),
                                onDecrement: () => FirestoreService.instance
                                    .updateCartQuantity(user.uid, id, -1),
                              );
                            },
                          );
                        },
                      ),
              ),

              // Order Summary & Checkout (Bottom Container)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Order Summary',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subtotal Row
                    Builder(
                      builder: (context) {
                        if (user == null) {
                          return AnimatedBuilder(
                            animation: CartService.instance,
                            builder: (context, _) {
                              final items = CartService.instance.items
                                  .map(
                                    (m) => CartItem(
                                      title: (m['title'] as String?) ?? 'Item',
                                      description:
                                          (m['description'] as String?) ?? '',
                                      image: (m['image'] as String?) ?? '',
                                      price:
                                          ((m['price'] as num?)?.toDouble()) ??
                                          0.0,
                                      quantity: (m['quantity'] as int?) ?? 1,
                                    ),
                                  )
                                  .toList();
                              final sub = subtotalOf(items);
                              return _buildSummaryRow(
                                'Subtotal',
                                Currency.formatINR(sub),
                                isBold: false,
                              );
                            },
                          );
                        }
                        return StreamBuilder<List<Map<String, dynamic>>>(
                          stream: FirestoreService.instance.streamCart(
                            user.uid,
                          ),
                          builder: (context, snapshot) {
                            final items = _itemsFromDocs(snapshot.data ?? []);
                            double sub = subtotalOf(items);
                            if (items.isEmpty) {
                              final localItems = CartService.instance.items
                                  .map(
                                    (m) => CartItem(
                                      title: (m['title'] as String?) ?? 'Item',
                                      description:
                                          (m['description'] as String?) ?? '',
                                      image: (m['image'] as String?) ?? '',
                                      price:
                                          ((m['price'] as num?)?.toDouble()) ??
                                          0.0,
                                      quantity: (m['quantity'] as int?) ?? 1,
                                    ),
                                  )
                                  .toList();
                              sub = subtotalOf(localItems);
                            }
                            return _buildSummaryRow(
                              'Subtotal',
                              Currency.formatINR(sub),
                              isBold: false,
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 6),

                    // Taxes & Fees Row
                    _buildSummaryRow(
                      'Taxes & Fees',
                      Currency.formatINR(taxAndFees),
                      isBold: false,
                    ),

                    const Divider(height: 20, thickness: 1, color: Colors.grey),

                    // Total Row
                    Builder(
                      builder: (context) {
                        if (user == null) {
                          return AnimatedBuilder(
                            animation: CartService.instance,
                            builder: (context, _) {
                              final items = CartService.instance.items
                                  .map(
                                    (m) => CartItem(
                                      title: (m['title'] as String?) ?? 'Item',
                                      description:
                                          (m['description'] as String?) ?? '',
                                      image: (m['image'] as String?) ?? '',
                                      price:
                                          ((m['price'] as num?)?.toDouble()) ??
                                          0.0,
                                      quantity: (m['quantity'] as int?) ?? 1,
                                    ),
                                  )
                                  .toList();
                              final t = subtotalOf(items) + taxAndFees;
                              return _buildSummaryRow(
                                'Total',
                                Currency.formatINR(t),
                                isBold: true,
                                valueColor: primaryBlue,
                              );
                            },
                          );
                        }
                        return StreamBuilder<List<Map<String, dynamic>>>(
                          stream: FirestoreService.instance.streamCart(
                            user.uid,
                          ),
                          builder: (context, snapshot) {
                            final items = _itemsFromDocs(snapshot.data ?? []);
                            double sub = subtotalOf(items);
                            if (items.isEmpty) {
                              final localItems = CartService.instance.items
                                  .map(
                                    (m) => CartItem(
                                      title: (m['title'] as String?) ?? 'Item',
                                      description:
                                          (m['description'] as String?) ?? '',
                                      image: (m['image'] as String?) ?? '',
                                      price:
                                          ((m['price'] as num?)?.toDouble()) ??
                                          0.0,
                                      quantity: (m['quantity'] as int?) ?? 1,
                                    ),
                                  )
                                  .toList();
                              sub = subtotalOf(localItems);
                            }
                            final t = sub + taxAndFees;
                            return _buildSummaryRow(
                              'Total',
                              Currency.formatINR(t),
                              isBold: true,
                              valueColor: primaryBlue,
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Proceed to Checkout Button (Styled with Gradient as per image)
                    Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(
                          colors: [
                            primaryBlue,
                            Color(0xFF8AA4FF),
                          ], // Light gradient matching the visual
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryBlue.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextButton(
                        onPressed: () async {
                          final uid = AuthService.instance.currentUser?.uid;

                          // Helper to navigate to Checkout with a given map-like item
                          void _navigateWith(Map<String, dynamic> first) {
                            final destination = {
                              'name': first['destination'] ?? first['title'],
                            };
                            final package = {
                              'title': first['title'] ?? 'Package',
                              'price': (first['price'] ?? 0) as num,
                              'people': '1-2',
                            };
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => CheckoutScreen(
                                  destination: destination,
                                  package: package,
                                ),
                              ),
                            );
                          }

                          if (uid == null) {
                            final localItems = CartService.instance.items;
                            if (localItems.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Your cart is empty'),
                                ),
                              );
                              return;
                            }
                            _navigateWith(localItems.first);
                            return;
                          }

                          try {
                            final docs = await FirestoreService.instance
                                .streamCart(uid)
                                .first;
                            if (docs.isNotEmpty) {
                              _navigateWith(docs.first);
                              return;
                            }

                            // Fallback to local items if remote cart is empty
                            final localItems = CartService.instance.items;
                            if (localItems.isNotEmpty) {
                              _navigateWith(localItems.first);
                              return;
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Your cart is empty'),
                              ),
                            );
                          } catch (e) {
                            // On error, attempt to fallback to local items
                            final localItems = CartService.instance.items;
                            if (localItems.isNotEmpty) {
                              _navigateWith(localItems.first);
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Unable to proceed to checkout'),
                              ),
                            );
                          }
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Builder(
                          builder: (context) {
                            final user = AuthService.instance.currentUser;
                            if (user == null) {
                              return AnimatedBuilder(
                                animation: CartService.instance,
                                builder: (context, _) {
                                  final items = CartService.instance.items
                                      .map(
                                        (m) => CartItem(
                                          title:
                                              (m['title'] as String?) ?? 'Item',
                                          description:
                                              (m['description'] as String?) ??
                                              '',
                                          image: (m['image'] as String?) ?? '',
                                          price:
                                              ((m['price'] as num?)
                                                  ?.toDouble()) ??
                                              0.0,
                                          quantity:
                                              (m['quantity'] as int?) ?? 1,
                                        ),
                                      )
                                      .toList();
                                  final t = subtotalOf(items) + taxAndFees;
                                  return Text(
                                    'Proceed to Checkout - ${Currency.formatINR(t)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              );
                            }
                            return StreamBuilder<List<Map<String, dynamic>>>(
                              stream: FirestoreService.instance.streamCart(
                                user.uid,
                              ),
                              builder: (context, snapshot) {
                                final items = _itemsFromDocs(
                                  snapshot.data ?? [],
                                );
                                final t = subtotalOf(items) + taxAndFees;
                                return Text(
                                  'Proceed to Checkout - ${Currency.formatINR(t)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Bottom navigation is provided by MainTabs; do not render a second bar here.
          bottomNavigationBar: const SizedBox.shrink(),
        );
      },
    );
  }

  // Helper method for the Order Summary rows
  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  // Bottom navigation provided by MainTabs; local helper removed to avoid duplicate bars.
}
