import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'splash.dart';
import 'login.dart';
import 'register.dart';
import 'landing_page.dart';
import 'detector.dart';
import 'hasil.dart';
import 'history.dart';
import 'info.dart';
import 'hasil_page.dart' hide HasilPage;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Melon Leaf Detector',
      home: SplashScreenWrapper(),
    );
  }
}

class SplashScreenWrapper extends StatefulWidget {
  const SplashScreenWrapper({super.key});

  @override
  State<SplashScreenWrapper> createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () async {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SplashScreen();
    } else {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return const MainNavigation();
      } else {
        return const LoginPage();
      }
    }
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    LandingPage(fullname: '', onTabChange: (int p1) {  },),
    const DetectorPage(),
    const HasilPage(),
    const HistoryPage(),
    const InfoPage(fullname: '', email: '', profileImageUrl: '',),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF064E3B);

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true, // biar tombol boleh overlap bawah
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      // Bottom nav custom
      bottomNavigationBar: Container(
        height: 72, // tinggi dikontrol manual agar tidak overflow
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Item kiri-kanan
            Positioned.fill(
              top: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.home_rounded, "Home", 0, primaryColor),
                  _buildNavItem(Icons.bar_chart_rounded, "Result", 2, primaryColor),
                  const SizedBox(width: 50), // untuk space tengah tombol kamera
                  _buildNavItem(Icons.history_rounded, "History", 3, primaryColor),
                  _buildNavItem(Icons.info_outline_rounded, "Info", 4, primaryColor),
                ],
              ),
            ),

            // Tombol kamera tengah
            Positioned(
              top: -32, // posisi lebih rendah, tapi tidak overflow
              child: GestureDetector(
                onTap: () => _onItemTapped(1),
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon, String label, int index, Color primaryColor) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? primaryColor : Colors.grey.shade700,
            size: isSelected ? 26 : 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? primaryColor : Colors.grey.shade700,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
