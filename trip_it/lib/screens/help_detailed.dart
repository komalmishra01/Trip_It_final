import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'terms_page.dart';

const Color primaryPink = Color(0xFFFF4A8C);
const Color offWhiteBackground = Color(0xFFF6F6F8);

class HelpDetailed extends StatelessWidget {
  const HelpDetailed({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: offWhiteBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('Help & Support'),
        backgroundColor: primaryPink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: const [
                  ListTile(
                    leading: Icon(Icons.question_mark_outlined),
                    title: Text(
                      'Frequently Asked Questions',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Quick answers to common questions'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // FAQ list
            Expanded(
              child: ListView(
                children: [
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text('How can I change my booking?'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {},
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: const Text('What is the cancellation policy?'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {},
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: const Text('Is my payment safe on TripIt?'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {},
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: const Text(
                            'How do I update my personal details?',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            'Other Ways to Reach Us',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.email_outlined),
                          title: const Text('Email Support'),
                          subtitle: const Text(
                            'raval043@rku.ac.in\nkmishra69@rku.ac.in',
                          ),
                          onTap: () async {
                            final uri = Uri(
                              scheme: 'mailto',
                              path: 'raval043@rku.ac.in,kmishra69@rku.ac.in',
                              query: Uri.encodeQueryComponent(
                                  'subject=TripIt Support&body=Please describe your issue'),
                            );
                            final ok = await launchUrl(uri);
                            if (!ok) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Could not open email app')),
                              );
                            }
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.info_outline),
                          title: const Text('Terms & Conditions'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (c) => const TermsPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
