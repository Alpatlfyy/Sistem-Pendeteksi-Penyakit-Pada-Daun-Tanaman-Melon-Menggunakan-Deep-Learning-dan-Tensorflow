import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class LandingPage extends StatefulWidget {
  final String fullname;
  final Function(int) onTabChange; // 🔹 callback untuk pindah tab ke InfoPage
  const LandingPage({
    super.key,
    required this.fullname,
    required this.onTabChange,
  });

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  String profileImageUrl = '';
  String fullNameFromDB = '';
  String emailFromDB = '';

  final List<Map<String, String>> diseases = [
    {
      'name': 'Bercak Daun (Leaf Spot)',
      'desc':
      'Penyakit umum yang menyebabkan bercak coklat pada daun. Biasanya disebabkan oleh jamur atau bakteri yang tumbuh di kondisi lembap.',
      'image': 'assets/images/leaf_spot.jpg'
    },
    {
      'name': 'Busuk Daun (Leaf Blight)',
      'desc':
      'Daun berubah warna menjadi kuning lalu coklat dan kering. Dapat menyebabkan kehilangan hasil panen signifikan.',
      'image': 'assets/images/leaf_blight.jpeg'
    },
    {
      'name': 'Kutu Kebul (Kutu Kebul)',
      'desc':
      'Kutu kebul merupakan hama kecil berwarna putih yang biasanya menempel di bagian bawah daun. Serangga ini menghisap cairan daun sehingga menyebabkan daun menguning, layu, dan menurunkan hasil panen.',
      'image': 'assets/images/kutu_kebul.jpg'
    },
    {
      'name': 'Embun Tepung (Powdery Mildew)',
      'desc':
      'Lapisan putih seperti tepung menutupi daun dan menghambat proses fotosintesis tanaman.',
      'image': 'assets/images/powdery_mildew.jpg'
    },
    {
      'name': 'Daun Sehat',
      'desc':
      'Daun berwarna hijau segar tanpa gejala penyakit, menandakan kondisi tanaman optimal.',
      'image': 'assets/images/healthy_leaf.jpg'
    },
  ];

  @override
  void initState() {
    super.initState();
    _listenUserProfile(); // 🔹 gunakan listener agar update otomatis
  }

  /// 🔹 Listener data profil realtime
  void _listenUserProfile() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final ref = FirebaseDatabase.instance.ref("users/${user.uid}");

      ref.onValue.listen((event) {
        final data = event.snapshot.value;
        if (data != null && data is Map) {
          setState(() {
            fullNameFromDB = data['fullName'] ?? widget.fullname;
            emailFromDB = data['email'] ?? user.email ?? '';
            profileImageUrl = data['profileImage'] ?? '';
          });
        }
      });
    }
  }

  /// 🔹 Tampilkan detail penyakit
  void _showDiseaseDetail(Map<String, String> disease) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [Colors.green.shade50, Colors.green.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    disease['image']!,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 150,
                      color: Colors.green.shade100,
                      child: const Icon(Icons.image_not_supported,
                          color: Colors.white, size: 50),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  disease['name']!,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  disease['desc']!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Tutup',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 🔹 Ganti ke tab Info di navbar (bukan buka halaman baru)
  void _goToInfoPage() {
    widget.onTabChange(2); // misal tab ke-2 adalah info.dart
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔹 Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF064E3B), // hijau tua
                    Color(0xFF2E5E46),
                    Color(0xFF446C4C), // hijau medium
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Halo, ${fullNameFromDB.isNotEmpty ? fullNameFromDB : widget.fullname}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _goToInfoPage,
                        child: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.white24,
                          backgroundImage: profileImageUrl.isNotEmpty
                              ? NetworkImage(profileImageUrl)
                              : null,
                          child: profileImageUrl.isEmpty
                              ? const Icon(Icons.person,
                              color: Colors.white, size: 25)
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  const Center(
                    child: Column(
                      children: [
                        Icon(Icons.eco_rounded, color: Colors.white, size: 60),
                        SizedBox(height: 10),
                        Text(
                          'Leaf Disease Analyzer',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Analisis cerdas untuk mendeteksi berbagai penyakit daun menggunakan teknologi AI.',
                          textAlign: TextAlign.center,
                          style:
                          TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'Informasi tentang penyakit:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: diseases.map((disease) {
                  return GestureDetector(
                    onTap: () => _showDiseaseDetail(disease),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              disease['image']!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.green.shade50,
                                    child: const Icon(Icons.eco,
                                        color: Colors.green, size: 30),
                                  ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  disease['name']!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  disease['desc']!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
