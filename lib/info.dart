import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'change_password.dart';
import 'login.dart';

class InfoPage extends StatefulWidget {
  final String fullname;
  final String email;
  final String profileImageUrl;

  const InfoPage({
    super.key,
    required this.fullname,
    required this.email,
    required this.profileImageUrl,
  });

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  File? _profileImage;
  String? fullNameFromDB;
  String? emailFromDB;
  String? profileImageFromDB;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Ambil data dari Firebase Realtime Database
  Future<void> _loadUserData() async {
    if (user == null) return;
    final ref = FirebaseDatabase.instance.ref("users/${user!.uid}");
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      setState(() {
        fullNameFromDB = data['fullName'] ?? widget.fullname;
        emailFromDB = data['email'] ?? widget.email;
        profileImageFromDB = data['profileImage'] ?? widget.profileImageUrl;
      });
    } else {
      setState(() {
        fullNameFromDB = widget.fullname;
        emailFromDB = widget.email;
        profileImageFromDB = widget.profileImageUrl;
      });
    }
  }

  /// Pilih gambar dari galeri
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
      await _uploadImage(File(pickedImage.path));
    }
  }

  /// Upload gambar profil ke Firebase Storage
  Future<void> _uploadImage(File imageFile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint("User belum login, upload dibatalkan");
      return;
    }

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child("profile_images/${user.uid}.jpg");

      // Upload ke Storage
      await storageRef.putFile(imageFile);

      // Ambil URL download
      final downloadUrl = await storageRef.getDownloadURL();
      debugPrint("Download URL berhasil: $downloadUrl");

      // Update di database
      final ref = FirebaseDatabase.instance.ref("users/${user.uid}");
      await ref.update({"profileImage": downloadUrl});

      debugPrint("Profile image berhasil disimpan di database!");

      setState(() {
        profileImageFromDB = downloadUrl;
      });
    } catch (e) {
      debugPrint("Error upload image: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF064E3B);

    final displayName = fullNameFromDB ?? widget.fullname;
    final displayEmail = emailFromDB ?? widget.email;
    final displayImage = _profileImage != null
        ? FileImage(_profileImage!)
        : (profileImageFromDB != null && profileImageFromDB!.isNotEmpty
        ? NetworkImage(profileImageFromDB!)
        : (widget.profileImageUrl.isNotEmpty
        ? NetworkImage(widget.profileImageUrl)
        : null)) as ImageProvider?;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Profile & Info", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: displayImage,
                          child: displayImage == null
                              ? const Icon(Icons.person, size: 60, color: Colors.grey)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child:
                            const Icon(Icons.edit, color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    displayName,
                    style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(displayEmail, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ChangePasswordPage()),
                      );
                    },
                    icon:
                    const Icon(Icons.lock_outline, color: Colors.white),
                    label: const Text("Change Password",
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildSectionTitle("Tentang Aplikasi", primaryColor),
            const SizedBox(height: 8),
            const Text(
              "This app helps detect melon leaf diseases using AI to support farmers’ crop health. "
                  "Our advanced technology analyzes leaf conditions and provides instant diagnosis with "
                  "treatment recommendations.",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle("Cara Menggunakan", primaryColor),
            const SizedBox(height: 8),
            _buildStep(Icons.camera_alt, "Step 1",
                "Take a photo of the melon leaf with the camera"),
            _buildStep(Icons.hourglass_empty, "Step 2",
                "Wait for the AI detection results"),
            _buildStep(Icons.medical_services, "Step 3",
                "Follow the treatment suggestions that appear"),
            const SizedBox(height: 20),
            _buildSectionTitle("Key Features", primaryColor),
            const SizedBox(height: 8),
            _buildFeature(Icons.bolt, "Real-time disease detection"),
            _buildFeature(Icons.medical_information, "Treatment recommendations"),
            _buildFeature(Icons.history, "History tracking"),
            _buildFeature(Icons.wifi_off, "Offline functionality"),
            const SizedBox(height: 20),
            _buildSectionTitle("Contact & Support", primaryColor),
            const SizedBox(height: 8),
            const Text(
              "Contact the development team for further assistance. We’re here to help you get the most out of your app.",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {},
                child:
                const Text("Contact Us", style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle("App Information", primaryColor),
            const SizedBox(height: 8),
            _buildInfoRow("Version", "1.2.0"),
            _buildInfoRow("Size", "45.2 MB"),
            _buildInfoRow("Last Updated", "November 15, 2025"),
            _buildInfoRow("Developer", "AgriTech Solutions"),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                          (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text("Logout",
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Text(title,
        style:
        TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color));
  }

  Widget _buildStep(IconData icon, String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal[700]),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.teal[700]),
          const SizedBox(width: 8),
          Expanded(child: Text(feature)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }
}
