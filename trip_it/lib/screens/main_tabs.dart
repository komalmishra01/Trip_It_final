import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'favorites_page.dart';
import 'profile_page.dart';
import 'cart_page.dart';

/// A simple Bottom Navigation container that hosts four pages:
/// Home, Favorites, Help & Support and Profile (Settings available as page too).
class MainTabs extends StatefulWidget {
  const MainTabs({super.key});

  @override
  State<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  int _index = 0;
  late final List<Widget> _pages;
  bool _routeInitDone = false;

  @override
  void initState() {
    super.initState();
    _pages = const <Widget>[
      HomeScreen(),
      FavoritesPage(),
      CartPage(),
      ProfilePage(),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_routeInitDone) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    int? tabIndex;
    if (args is Map) {
      final v = args['tab'];
      if (v is int) tabIndex = v;
    } else if (args is int) {
      tabIndex = args;
    }
    if (tabIndex != null && tabIndex >= 0 && tabIndex < 4) {
      _index = tabIndex;
    }
    _routeInitDone = true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_index != 0) {
          setState(() => _index = 0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: IndexedStack(index: _index, children: _pages),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite),
              label: 'Favourites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
        floatingActionButton: _index == 0
            ? null
            : null, // keep no FAB for other tabs; HomeScreen already has its own layout
      ),
    );
  }
}
