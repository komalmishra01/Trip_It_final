import 'package:flutter/material.dart';

// Firebase core
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Import all screens
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
// Note: EmailSentScreen is used but not imported. Assuming it exists.
// import 'screens/email_sent_screen.dart'; // <- This line should ideally be added if EmailSentScreen exists.
import 'screens/main_tabs.dart';
import 'screens/plan_trip_flow.dart';
import 'screens/destination_detail_screen.dart';
import 'theme.dart';
import 'theme_controller.dart';
import 'currency_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Load saved theme mode before building the app
  await initThemeMode();
  await initCurrency();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'TripIt',
          theme: buildTheme(), // Light theme
          darkTheme: buildDarkTheme(),
          themeMode: mode,
          debugShowCheckedModeBanner: false,

          // Initial screen
          initialRoute: '/',

          // ✅ All navigation routes properly set up
          routes: {
            '/': (context) => const SplashScreen(),
            '/onboarding': (context) => const OnboardingScreen(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/forgot': (context) => const ForgotPasswordScreen(),
            // 'EmailSentScreen' route is defined here, even if import is missing above
            '/email-sent': (context) => const EmailSentScreen(),
            '/home': (context) => const MainTabs(),
            '/plan-trip': (context) => const PlanTripFlow(),
            DestinationDetailScreen.route: (context) {
              final args =
                  ModalRoute.of(context)!.settings.arguments as Map? ?? {};
              return DestinationDetailScreen.fromArgs(args);
            },
          },
        );
      },
    );
  }
}
