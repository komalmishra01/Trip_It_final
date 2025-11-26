import 'package:flutter/material.dart';

const Color _primaryBlue = Color(0xFF4A8CFF);

// Returns to the app root (Home) when user taps the button.
class BookingConfirmedScreen extends StatelessWidget {
  const BookingConfirmedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _primaryBlue,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Confirmation Circle and Icon
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                child: Icon(Icons.check, color: _primaryBlue, size: 80),
              ),
              const SizedBox(height: 32),

              // Confirmation Text
              const Text(
                'Booking Confirmed',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Aapki trip successfully book ho chuki hai.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 150),

              // 'Back to Home' Button
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextButton(
                  onPressed: () {
                    // Pop all routes until the first (root) route — returns to Home.
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _primaryBlue,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}