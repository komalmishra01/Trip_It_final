import 'package:flutter/material.dart';
import 'edit_profile.dart';
import 'terms_page.dart';
import 'help_detailed.dart';
import '../theme_controller.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

const Color primaryPink = Color(0xFFFF4A8C);
const Color primaryRed = Color(0xFFE53935);
const Color offWhiteBackground = Color(0xFFF6F6F8);

class SettingsDetailed extends StatefulWidget {
  const SettingsDetailed({super.key});

  @override
  State<SettingsDetailed> createState() => _SettingsDetailedState();
}

class _SettingsDetailedState extends State<SettingsDetailed> {
  bool _isDark = themeController.value == ThemeMode.dark;
  bool _pushNotifs = true;
  bool _emailNotifs = false;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.onPrimary),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text('Settings', style: TextStyle(color: cs.onPrimary)),
        backgroundColor: cs.primary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.2 : 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _loading ? 'Loading…' : (_displayName ?? 'User'),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _loading ? '' : (_email ?? ''),
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) => const EditProfilePage(),
                        ),
                      );
                    },
                    child: Text('Edit Profile', style: TextStyle(color: cs.primary)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Theme Mode
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.2 : 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.light_mode_outlined, color: cs.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isDark
                          ? 'Theme Mode\nDark theme'
                          : 'Theme Mode\nLight theme',
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                    ),
                  ),
                  Switch(
                    value: _isDark,
                    onChanged: (v) async {
                      setState(() => _isDark = v);
                      await setThemeModePersisted(
                        v ? ThemeMode.dark : ThemeMode.light,
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Notification Preferences
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.2 : 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notification Preference',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.notifications, color: theme.iconTheme.color),
                          SizedBox(width: 8),
                          Text('Push Notifications', style: theme.textTheme.bodyMedium),
                        ],
                      ),
                      Switch(
                        value: _pushNotifs,
                        onChanged: (v) => setState(() => _pushNotifs = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.email_outlined, color: theme.iconTheme.color),
                          SizedBox(width: 8),
                          Text('Email Notifications', style: theme.textTheme.bodyMedium),
                        ],
                      ),
                      Switch(
                        value: _emailNotifs,
                        onChanged: (v) => setState(() => _emailNotifs = v),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Support & About
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.2 : 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.support_agent_outlined, color: theme.iconTheme.color),
                    title: Text('Support', style: theme.textTheme.bodyLarge),
                    subtitle: Text('Help Center', style: theme.textTheme.bodyMedium),
                    trailing: Icon(Icons.chevron_right, color: theme.iconTheme.color),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (c) => const HelpDetailed()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.info_outline, color: theme.iconTheme.color),
                    title: Text('About', style: theme.textTheme.bodyLarge),
                    subtitle: Text('Terms & Conditions', style: theme.textTheme.bodyMedium),
                    trailing: Icon(Icons.chevron_right, color: theme.iconTheme.color),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (c) => const TermsPage()),
                      );
                    },
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Sign Out Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.surface,
                foregroundColor: cs.error,
                side: BorderSide(color: cs.outline.withOpacity(0.3)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: Icon(Icons.logout, color: cs.error),
              label: const Text(
                'Sign Out',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),

            const SizedBox(height: 12),

            // Bottom mini nav - make icons navigate to main tabs
            Container(
              height: 62,
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(Icons.home_outlined, color: theme.iconTheme.color),
                    onPressed: () => Navigator.of(context)
                        .pushNamedAndRemoveUntil('/home', (route) => false, arguments: {'tab': 0}),
                  ),
                  IconButton(
                    icon: Icon(Icons.favorite_outline, color: theme.iconTheme.color),
                    onPressed: () => Navigator.of(context)
                        .pushNamedAndRemoveUntil('/home', (route) => false, arguments: {'tab': 1}),
                  ),
                  IconButton(
                    icon: Icon(Icons.shopping_cart_outlined, color: theme.iconTheme.color),
                    onPressed: () => Navigator.of(context)
                        .pushNamedAndRemoveUntil('/home', (route) => false, arguments: {'tab': 2}),
                  ),
                  IconButton(
                    icon: Icon(Icons.person, color: theme.iconTheme.color),
                    onPressed: () => Navigator.of(context)
                        .pushNamedAndRemoveUntil('/home', (route) => false, arguments: {'tab': 3}),
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
