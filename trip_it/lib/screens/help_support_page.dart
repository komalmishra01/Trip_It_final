import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Help & Support',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('How can I change my booking?'),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('What is the cancellation policy?'),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Is my payment safe on TripIt?'),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('How do I update my personal details?'),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Other Ways to Reach Us',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('Email Support'),
                    SizedBox(height: 6),
                    Text('raval043@rku.ac.in'),
                    SizedBox(height: 4),
                    Text('krishna@rku.ac.in'),
                    SizedBox(height: 4),
                    Text('vramani@rku.ac.in'),

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
