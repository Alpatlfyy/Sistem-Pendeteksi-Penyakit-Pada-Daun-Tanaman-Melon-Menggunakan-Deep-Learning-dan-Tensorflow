import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'login.dart';
import 'info.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String? fullName;
  String? email;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final ref = FirebaseDatabase.instance.ref().child('users/${user.uid}');
      final snapshot = await ref.get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          fullName = data['fullName'] ?? 'Nama Pengguna';
          email = data['email'] ?? user.email;
        });
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
      );
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Keluar'),
          content: const Text('Apakah Anda yakin ingin keluar dari akun Anda?'),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Keluar'),
              onPressed: () => _logout(context),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Akun Saya'),
        backgroundColor: const Color(0xFF064E3B),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildSectionHeader('Pengaturan Akun'),
          _buildMenuCard(
            icon: Icons.person_outline,
            text: 'Edit Profil',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Fitur ini belum tersedia.'),
              ));
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Lainnya'),
          _buildMenuCard(
            icon: Icons.info_outline,
            text: 'Info & Bantuan',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InfoPage()),
              );
            },
          ),
          _buildMenuCard(
            icon: Icons.logout,
            text: 'Keluar',
            textColor: Colors.red.shade700,
            iconColor: Colors.red.shade700,
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: Color(0xFFE0F2F1),
          child: Icon(Icons.person, size: 60, color: Color(0xFF064E3B)),
        ),
        const SizedBox(height: 16),
        Text(
          fullName ?? 'Memuat...',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email ?? 'Sedang mengambil data...',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF064E3B),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color textColor = const Color(0xFF1F2937),
    Color iconColor = const Color(0xFF064E3B),
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(text,
            style:
            TextStyle(color: textColor, fontWeight: FontWeight.w500)),
        trailing:
        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
