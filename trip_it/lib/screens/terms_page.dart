import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        backgroundColor: Colors.blueAccent, // Trip It theme color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Terms & Conditions',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                'Last Updated: October 2025',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Welcome to Trip It! By using our app, you agree to the following Terms and Conditions. Please read them carefully.',
              ),
              SizedBox(height: 20),
              Text(
                '1. General Use',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 6),
              Text(
                'Trip It helps users plan, book, and manage trips. You must be 18+ or use it under parental guidance. Use the app only for legal purposes.',
              ),
              SizedBox(height: 16),
              Text(
                '2. Account and Registration',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 6),
              Text('• You may need an account to access features.'),
              Text('• Keep your login details secure.'),
              Text('• Inform us immediately of unauthorized account use.'),
              SizedBox(height: 16),
              Text(
                '3. Bookings and Payments',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 6),
              Text('• All bookings/payments must use valid methods.'),
              Text('• Prices, offers, and availability may change anytime.'),
              Text(
                '• Trip It is not responsible for third-party delays or errors.',
              ),
              SizedBox(height: 16),
              Text(
                '4. Cancellations and Refunds',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 6),
              Text(
                'Refunds depend on the travel provider’s policy. Review their terms before booking. Trip It assists in disputes but is not responsible for third-party decisions.',
              ),
              SizedBox(height: 16),
              Text(
                '5. User Conduct',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 6),
              Text(
                'Do not misuse the app (spam, fake bookings, harmful content). Use it responsibly and legally.',
              ),
              SizedBox(height: 16),
              Text(
                '6. Data and Privacy',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 6),
              Text(
                'Your data is collected to provide services. We follow our Privacy Policy to protect your information.',
              ),
              SizedBox(height: 16),
              Text(
                '7. Third-Party Services',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 6),
              Text(
                'Trip It may show links or info from third parties. We are not responsible for their content or performance.',
              ),
              SizedBox(height: 16),
              Text(
                '8. Limitation of Liability',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 6),
              Text(
                'We try to keep information accurate but cannot guarantee it. Not responsible for losses or damages from third parties or unexpected events.',
              ),
              SizedBox(height: 16),
              Text(
                '9. Modifications',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 6),
              Text(
                'We may update these Terms anytime. Continued use means you accept the latest version.',
              ),
              SizedBox(height: 16),
              Text(
                '10. Contact Us',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 6),
              Text('If you have questions, contact us at: support@tripit.com'),
              SizedBox(height: 30),
              Center(
                child: Text(
                  '© 2025 Trip It. All Rights Reserved.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
