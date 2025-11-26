import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const route = '/';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  StreamSubscription? _sub;
  @override
  void initState() {
    super.initState();
    _testPackagesFetch();
    _sub = AuthService.instance.authState().listen((user) {
      if (!mounted) return;
      if (user != null) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Responsive logo sizing: ~35% of screen width, clamped between 120 and 220
    final double logoSize = (() {
      final w = MediaQuery.of(context).size.width * 0.35;
      if (w < 120) return 120.0;
      if (w > 220) return 220.0;
      return w.toDouble();
    })();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: Gradients.splash),
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo
              SizedBox(
                width: logoSize,
                height: logoSize,
                child: Image.asset(
                  'assets/images/splash_logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.flight_takeoff, color: Colors.white, size: 80),
                ),
              ),
              const SizedBox(height: 20),
              const Text('TRIPIT', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: 2)),
              const SizedBox(height: 8),
              const Text('Dream. Plan. Explore.', style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

extension on _SplashScreenState {
  Future<void> _testPackagesFetch() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('packages')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();
      // ignore: avoid_print
      print('Packages fetched: ${snap.docs.length}');
    } catch (e, st) {
      // ignore: avoid_print
      print('Packages fetch error: $e\n$st');
    }
  }
}
