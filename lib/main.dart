import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:device_preview/device_preview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';
import 'services/api_service.dart';
import 'services/data_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await ApiService.initToken();
    await DataStore.instance.init();
  } catch (e) {
    debugPrint('Initialization error: $e');
  }

  runApp(
    DevicePreview(
      enabled: kIsWeb,
      builder: (context) => const DanJonesApp(),
    ),
  );
}

class DanJonesApp extends StatelessWidget {
  const DanJonesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DanJones',
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF151515),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE4B53E),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.outfitTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // App Title
              Text(
                'DanJones',
                style: theme.textTheme.headlineLarge,
              ),
              const SizedBox(height: 16),
              // Subtitle / description
              Text(
                'Your ultimate mobile experience in black and gold.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 48),
              // Action buttons
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE4B53E),
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE4B53E),
                  side: const BorderSide(color: Color(0xFFE4B53E), width: 2),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Learn More',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
